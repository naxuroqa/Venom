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
  public interface ILocalStorage : GLib.Object {
    public abstract string myId {get; set;}
    public abstract void on_message(Contact c, string message, bool issender);
    public abstract GLib.List<Message>? retrieve_history(Contact c);
    public abstract void delete_history(Contact c);
    public abstract void connect_to(ToxSession session);
    public abstract void disconnect_from(ToxSession session);
  }

  public class DummyStorage : ILocalStorage, GLib.Object {
    public string myId {get; set;}
    public void on_message(Contact c, string message, bool issender) {}
    public GLib.List<Message>? retrieve_history(Contact c) { return null; }
    public void delete_history(Contact c) {}
    public void connect_to(ToxSession session) {}
    public void disconnect_from(ToxSession session) {}
  }


  public class LocalStorage : ILocalStorage, GLib.Object {
    public string myId {get; set;}

    public enum HistoryColumn {
      ID,
      USER,
      CONTACT,
      MESSAGE,
      TIME,
      SENDER
    }

    private Sqlite.Database db;
    private Sqlite.Statement insert_statement;
    private Sqlite.Statement select_statement;

    private static string TABLE_USER = "$USER";
    private static string TABLE_CONTACT = "$CONTACT";
    private static string TABLE_MESSAGE = "$MESSAGE";
    private static string TABLE_TIME = "$TIME";
    private static string TABLE_SENDER = "$SENDER";
    private static string TABLE_OLDEST = "$OLDEST";

    private static string STATEMENT_INSERT = "INSERT INTO History (userHash, contactHash, message, timestamp, issent) VALUES (%s, %s, %s, %s, %s);".printf(TABLE_USER, TABLE_CONTACT, TABLE_MESSAGE, TABLE_TIME, TABLE_SENDER);
    private static string STATEMENT_SELECT = "SELECT * FROM History WHERE userHash = %s AND contactHash = %s AND timestamp > %s;".printf(TABLE_USER, TABLE_CONTACT, TABLE_OLDEST);

    public LocalStorage() {
      init_db ();
      stdout.printf ("SQLite database created.\n");
    }
    
    ~LocalStorage() {
      stdout.printf ("SQLite database closed.\n");
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
      } catch (SqliteError e) {
        stderr.printf("Error writing message to sqlite database: %s\n", e.message);
        return;
      }

      insert_statement.step();
      insert_statement.reset();
    }

    public GLib.List<Message>? retrieve_history(Contact c) {
      string cId = Tools.bin_to_hexstring(c.public_key);
      DateTime earliestTime = new DateTime.now_utc();
      earliestTime = earliestTime.add_days(-Settings.instance.days_to_log);
      try {
        SqliteTools.put_text(select_statement , TABLE_USER,    myId);
        SqliteTools.put_text(select_statement , TABLE_CONTACT, cId);
        SqliteTools.put_int64(select_statement, TABLE_OLDEST,  earliestTime.to_unix()); 
      } catch (SqliteError e) {
        stderr.printf("Error retrieving logs from sqlite database: %s\n", e.message);
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

    public void delete_history(Contact c) {
      //TODO
    }

    private int init_db() {

      string errmsg;

      // Open/Create a database:
      string filepath = ResourceFactory.instance.db_filename;
      File file = File.new_for_path(filepath);
      if(file.query_exists()) {
        GLib.FileUtils.chmod(filepath, 0600);
      } else {
        try{
          file.create(GLib.FileCreateFlags.PRIVATE);
        } catch (Error e) {
        }
      }
      int ec = Sqlite.Database.open (filepath, out db);
      if (ec != Sqlite.OK) {
        stderr.printf ("Can't open database: %d: %s\n", db.errcode (), db.errmsg ());
        return -1;
      }

      //create table and index if needed
      const string query = """
      CREATE TABLE IF NOT EXISTS History (
        id  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        userHash  TEXT  NOT NULL,
        contactHash TEXT  NOT NULL,
        message TEXT  NOT NULL,
        timestamp INTEGER NOT NULL,
        issent INTEGER NOT NULL
      );
      """;

      ec = db.exec (query, null, out errmsg);
      if (ec != Sqlite.OK) {
        stderr.printf ("Error: %s\n", errmsg);
        return -1;
      }

      const string index_query = """
        CREATE UNIQUE INDEX IF NOT EXISTS main_index ON History (userHash, contactHash, timestamp);
      """;

      ec = db.exec (index_query, null, out errmsg);
      if (ec != Sqlite.OK) {
        stderr.printf ("Error: %s\n", errmsg);
        return -1;
      }

      //prepare insert statement for adding new history messages
      ec = db.prepare_v2 (STATEMENT_INSERT, STATEMENT_INSERT.length, out insert_statement);
      if (ec != Sqlite.OK) {
        stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        return -1;
      }

      //prepare select statement to get history. Will execute on indexed data
      ec = db.prepare_v2 (STATEMENT_SELECT, STATEMENT_SELECT.length, out select_statement);
      if (ec != Sqlite.OK) {
        stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        return -1;
      }
      return 0;
    }


  }
}
