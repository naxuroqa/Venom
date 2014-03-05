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
    public abstract void on_message(Contact c, string message, bool issender);
    public abstract GLib.List<Message>? retrieve_history(Contact c);
    public abstract void delete_history(Contact c);
    public abstract void connect_to(ToxSession session);
    public abstract void disconnect_from(ToxSession session);
  }

  public class DummyStorage : ILocalStorage, GLib.Object {
    public void on_message(Contact c, string message, bool issender) {}
    public GLib.List<Message>? retrieve_history(Contact c) { return null; }
    public void delete_history(Contact c) {}
    public void connect_to(ToxSession session) {}
    public void disconnect_from(ToxSession session) {}
  }

  public class LocalStorage : ILocalStorage, GLib.Object {
    private unowned ToxSession session;

    private Sqlite.Database db;

    private Sqlite.Statement prepared_insert_statement;

    private Sqlite.Statement prepared_select_statement;

    public LocalStorage() {
      init_db ();
      stdout.printf ("SQLite database created.\n");
    }
    
    ~LocalStorage() {
      stdout.printf ("SQLite database closed.\n");
    }

    public void connect_to(ToxSession session) {
      this.session = session;
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

      int param_position = prepared_insert_statement.bind_parameter_index ("$USER");
      assert (param_position > 0);
      string myId = Tools.bin_to_hexstring(session.get_address());
      prepared_insert_statement.bind_text(param_position, myId);

      param_position = prepared_insert_statement.bind_parameter_index ("$CONTACT");
      assert (param_position > 0);
      string cId = Tools.bin_to_hexstring(c.public_key);
      prepared_insert_statement.bind_text(param_position, cId);

      param_position = prepared_insert_statement.bind_parameter_index ("$MESSAGE");
      assert (param_position > 0);
      prepared_insert_statement.bind_text(param_position, message);

      param_position = prepared_insert_statement.bind_parameter_index ("$TIME");
      assert (param_position > 0);
      DateTime nowTime = new DateTime.now_utc();
      prepared_insert_statement.bind_int64(param_position, nowTime.to_unix());

      param_position = prepared_insert_statement.bind_parameter_index ("$SENDER");
      assert (param_position > 0);
      prepared_insert_statement.bind_int(param_position, issender?1:0);

      prepared_insert_statement.step ();

      prepared_insert_statement.reset ();
    }

    public GLib.List<Message>? retrieve_history(Contact c) {
      int param_position = prepared_select_statement.bind_parameter_index ("$USER");
      assert (param_position > 0);
      string myId = Tools.bin_to_hexstring(session.get_address());
      prepared_select_statement.bind_text(param_position, myId);

      param_position = prepared_select_statement.bind_parameter_index ("$CONTACT");
      assert (param_position > 0);
      string cId = Tools.bin_to_hexstring(c.public_key);
      prepared_select_statement.bind_text(param_position, cId);

      param_position = prepared_select_statement.bind_parameter_index ("$OLDEST");
      assert (param_position > 0);
      DateTime earliestTime = new DateTime.now_utc();
      earliestTime = earliestTime.add_days (-VenomSettings.instance.days_to_log);
      prepared_select_statement.bind_int64(param_position, earliestTime.to_unix());

      List<Message> messages = new List<Message>();

      while (prepared_select_statement.step () == Sqlite.ROW) {
        string message = prepared_select_statement.column_text(3);
        int64 timestamp = prepared_select_statement.column_int64(4);
        bool issender = prepared_select_statement.column_int(5) != 0;
        DateTime send_time = new DateTime.from_unix_utc (timestamp);
        Message mess;
        if(issender) {
          mess = new Message.outgoing(User.instance.user, c, message, send_time);
        } else {
          mess = new Message.incoming(c, message, send_time);
        }
        messages.append(mess);
      }

      prepared_select_statement.reset ();
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
      const string prepared_insert_str = "INSERT INTO History (userHash, contactHash, message, timestamp, issent) VALUES ($USER, $CONTACT, $MESSAGE, $TIME, $SENDER);";
      ec = db.prepare_v2 (prepared_insert_str, prepared_insert_str.length, out prepared_insert_statement);
      if (ec != Sqlite.OK) {
        stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        return -1;
      }

      //prepare select statement to get history. Will execute on indexed data
      const string prepared_select_str = "SELECT * FROM History WHERE userHash = $USER AND contactHash = $CONTACT AND timestamp > $OLDEST;";
      ec = db.prepare_v2 (prepared_select_str, prepared_select_str.length, out prepared_select_statement);
      if (ec != Sqlite.OK) {
        stderr.printf ("Error: %d: %s\n", db.errcode (), db.errmsg ());
        return -1;
      }
      return 0;
    }


  }
}
