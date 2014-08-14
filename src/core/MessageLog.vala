/*
 *    LocalStorage.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
 *
 *    This file is part of Venom.
 *
 *    Venom is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Venom is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Venom.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Venom {
  public interface IMessageLog : GLib.Object {
    public abstract string myId {get; set;}
    public abstract void on_message(Contact c, string message, bool issender);
    public abstract GLib.List<Message>? retrieve_history(Contact c);
    public abstract void sanitize_database();
    public abstract void connect_to(ToxSession session);
    public abstract void disconnect_from(ToxSession session);
  }

  public class DummyMessageLog : IMessageLog, GLib.Object {
    public string myId {get; set;}
    public void on_message(Contact c, string message, bool issender) {}
    public GLib.List<Message>? retrieve_history(Contact c) { return null; }
    public void sanitize_database() {}
    public void connect_to(ToxSession session) {}
    public void disconnect_from(ToxSession session) {}
  }


  public class SqliteMessageLog : IMessageLog, GLib.Object {
    public string myId {get; set;}

    public enum HistoryColumn {
      ID,
      USER,
      CONTACT,
      MESSAGE,
      TIME,
      SENDER
    }

    private unowned Sqlite.Database db;
    private Sqlite.Statement insert_statement;
    private Sqlite.Statement select_statement;
    private Sqlite.Statement delete_statement;

    private static string TABLE_USER = "$USER";
    private static string TABLE_CONTACT = "$CONTACT";
    private static string TABLE_MESSAGE = "$MESSAGE";
    private static string TABLE_TIME = "$TIME";
    private static string TABLE_SENDER = "$SENDER";

    private static string STATEMENT_INSERT_HISTORY = "INSERT INTO History (userHash, contactHash, message, timestamp, issent) VALUES (%s, %s, %s, %s, %s);".printf(TABLE_USER, TABLE_CONTACT, TABLE_MESSAGE, TABLE_TIME, TABLE_SENDER);
    private static string STATEMENT_SELECT_HISTORY = "SELECT * FROM History WHERE userHash = %s AND contactHash = %s;".printf(TABLE_USER, TABLE_CONTACT);
    private static string STATEMENT_SANITIZE_DATABASE = "DELETE FROM History WHERE timestamp < %s;".printf(TABLE_TIME);

    private static string QUERY_TABLE_HISTORY = """
      CREATE TABLE IF NOT EXISTS History (
        id  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        userHash  TEXT  NOT NULL,
        contactHash TEXT  NOT NULL,
        message TEXT  NOT NULL,
        timestamp INTEGER NOT NULL,
        issent INTEGER NOT NULL
      );
    """;

    public SqliteMessageLog(Sqlite.Database db) throws SqliteDbError {
      this.db = db;
      init_db();
      sanitize_database();
      Logger.log(LogLevel.DEBUG, "SQLite database created.");
    }
    
    ~LocalStorage() {
      Logger.log(LogLevel.DEBUG, "SQLite database closed.");
    }

    public void connect_to(ToxSession session) {
      session.on_own_message.connect(on_outgoing_message);
      session.on_friend_message.connect(on_incoming_message);
    }

    public void disconnect_from(ToxSession session) {
      session.on_own_message.disconnect(on_outgoing_message);
      session.on_friend_message.disconnect(on_incoming_message);
    }

    private void on_incoming_message(Contact c, string message) {
      on_message(c, message, false);
    }

    private void on_outgoing_message(Contact c, string message) {
      on_message(c, message, true);
    }

    public void on_message(Contact c, string message, bool issender) {
      string cId = Tools.bin_to_hexstring(c.public_key);
      DateTime nowTime = new DateTime.now_utc();

      try {
        SqliteTools.put_text(insert_statement,  TABLE_USER,    myId);
        SqliteTools.put_text(insert_statement,  TABLE_CONTACT, cId);
        SqliteTools.put_text(insert_statement,  TABLE_MESSAGE, message);
        SqliteTools.put_int64(insert_statement, TABLE_TIME,    nowTime.to_unix());
        SqliteTools.put_int(insert_statement,   TABLE_SENDER,  issender ? 1 : 0);
      } catch (SqliteStatementError e) {
        Logger.log(LogLevel.ERROR, "Error writing message to sqlite database: " + e.message);
        return;
      }

      insert_statement.step();
      insert_statement.reset();
    }

    public GLib.List<Message>? retrieve_history(Contact c) {
      string cId = Tools.bin_to_hexstring(c.public_key);
      try {
        SqliteTools.put_text(select_statement , TABLE_USER,    myId);
        SqliteTools.put_text(select_statement , TABLE_CONTACT, cId);
      } catch (SqliteStatementError e) {
        Logger.log(LogLevel.ERROR, "Error retrieving logs from sqlite database: " + e.message);
        return null;
      }

      List<Message> messages = new List<Message>();

      while (select_statement.step () == Sqlite.ROW) {
        string message = select_statement.column_text(HistoryColumn.MESSAGE);
        int64 timestamp = select_statement.column_int64(HistoryColumn.TIME);
        bool issender = select_statement.column_int(HistoryColumn.SENDER) != 0;

        DateTime send_time = new DateTime.from_unix_utc (timestamp);
        if(issender) {
          messages.append(new Message.outgoing(c, message, send_time));
        } else {
          messages.append(new Message.incoming(c, message, send_time));
        }
      }

      select_statement.reset ();
      return messages;
    }

    public void sanitize_database() {
      if(Settings.instance.log_indefinitely) {
        return;
      }
      Logger.log(LogLevel.INFO, "Sanitizing database...");
      DateTime timestamp = new DateTime.now_utc().add_days(-Settings.instance.days_to_log);
      try {
        SqliteTools.put_int64(delete_statement, TABLE_TIME, timestamp.to_unix());
      } catch (SqliteStatementError e) {
        Logger.log(LogLevel.ERROR, "Error sanitizing sqlite database: " + e.message);
        return;
      }

      delete_statement.step();
      delete_statement.reset();
    }

    private void init_db() throws SqliteDbError {
      string errmsg;

      //create table and index if needed
      if (db.exec (QUERY_TABLE_HISTORY, null, out errmsg) != Sqlite.OK) {
        throw new SqliteDbError.QUERY("Error creating message log table: %s\n", errmsg);
      }

      //prepare insert statement for adding new history messages
      if (db.prepare_v2 (STATEMENT_INSERT_HISTORY, STATEMENT_INSERT_HISTORY.length, out insert_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY("Error creating message insert statement: %d: %s\n", db.errcode (), db.errmsg());
      }

      //prepare select statement to get history. Will execute on indexed data
      if (db.prepare_v2 (STATEMENT_SELECT_HISTORY, STATEMENT_SELECT_HISTORY.length, out select_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY("Error creating message select statement: %d: %s\n", db.errcode (), db.errmsg());
      }

      //prepare delete statement
      if (db.prepare_v2 (STATEMENT_SANITIZE_DATABASE, STATEMENT_SANITIZE_DATABASE.length, out delete_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY("Error creating message delete statement: %d: %s\n", db.errcode (), db.errmsg());
      }
    }


  }
}
