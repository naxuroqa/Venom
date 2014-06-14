/*
 *    ContactStorage.vala
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
  public interface IContactStorage : GLib.Object {
    public abstract void load_contact_data(Contact c);
    public abstract void save_contact_data(Contact c);
  }

  public class SqliteContactStorage : IContactStorage, GLib.Object {
    private unowned Sqlite.Database db;
    private Sqlite.Statement insert_statement;
    private Sqlite.Statement select_statement;
    private static string QUERY_TABLE_CONTACTS = """
      CREATE TABLE IF NOT EXISTS Contacts (
        id  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key TEXT NOT NULL UNIQUE,
        note TEXT NOT NULL,
        alias TEXT NOT NULL,
        isblocked INTEGER DEFAULT 0,
        ingroup TEXT NOT NULL
      );
    """;
    private enum ContactColumn {
      ID,
      KEY,
      NOTE,
      ALIAS,
      ISBLOCKED,
      GROUP
    }
    private static string TABLE_KEY = "$KEY";
    private static string TABLE_NOTE = "$NOTE";
    private static string TABLE_ALIAS = "$ALIAS";
    private static string TABLE_ISBLOCKED = "$ISBLOCKED";
    private static string TABLE_GROUP = "$GROUP";

    private static string STATEMENT_INSERT_CONTACTS = "INSERT OR REPLACE INTO Contacts (key, note, alias, isblocked, ingroup) VALUES (%s, %s, %s, %s, %s);".printf(TABLE_KEY, TABLE_NOTE, TABLE_ALIAS, TABLE_ISBLOCKED, TABLE_GROUP);
    private static string STATEMENT_SELECT_CONTACTS = "SELECT * FROM Contacts WHERE key = %s".printf(TABLE_KEY);

    public void load_contact_data(Contact c) {
      string key = Tools.bin_to_hexstring(c.public_key);

      try {
        SqliteTools.put_text(select_statement, TABLE_KEY, key);
      } catch (SqliteStatementError e) {
        stderr.printf("Error retrieving contact from sqlite database: %s\n", e.message);
        return;
      }

      if(select_statement.step () == Sqlite.ROW) {
        c.note       = select_statement.column_text(ContactColumn.NOTE);
        c.alias      = select_statement.column_text(ContactColumn.ALIAS);
        c.is_blocked = select_statement.column_int (ContactColumn.ISBLOCKED) != 0;
        c.group      = select_statement.column_text(ContactColumn.GROUP);
      }

      select_statement.reset ();
    }
    public void save_contact_data(Contact c) {
      string key = Tools.bin_to_hexstring(c.public_key);

      try {
        SqliteTools.put_text(insert_statement,  TABLE_KEY,       key);
        SqliteTools.put_text(insert_statement,  TABLE_NOTE,      c.note);
        SqliteTools.put_text(insert_statement,  TABLE_ALIAS,     c.alias);
        SqliteTools.put_int (insert_statement,  TABLE_ISBLOCKED, c.is_blocked ? 1 : 0);
        SqliteTools.put_text(insert_statement,  TABLE_GROUP,     c.group);
      } catch (SqliteStatementError e) {
        stderr.printf(_("Error writing contact to sqlite database: %s\n"), e.message);
        return;
      }

      insert_statement.step();
      insert_statement.reset();
    }

    public SqliteContactStorage( Sqlite.Database db ) throws SqliteDbError {
      this.db = db;

      string errmsg;

      //create table and index if needed
      if(db.exec (QUERY_TABLE_CONTACTS, null, out errmsg) != Sqlite.OK) {
        throw new SqliteDbError.QUERY(_("Error creating contacts table: %s\n"), errmsg);
      }

      //prepare insert statement for adding new history messages
      if(db.prepare_v2 (STATEMENT_INSERT_CONTACTS, STATEMENT_INSERT_CONTACTS.length, out insert_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY(_("Error creating contacts insert statement: %d: %s\n"), db.errcode (), db.errmsg());
      }

      //prepare select statement to get history. Will execute on indexed data
      if(db.prepare_v2 (STATEMENT_SELECT_CONTACTS, STATEMENT_SELECT_CONTACTS.length, out select_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY(_("Error creating contacts select statement: %d: %s\n"), db.errcode (), db.errmsg());
      }
    }
  }
}
