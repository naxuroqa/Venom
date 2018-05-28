/*
 *    ContactDatabase.vala
 *
 *    Copyright (C) 2013-2017  Venom authors and contributors
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
  public class SqliteContactDatabase : IContactDatabase, Object {
    private const string QUERY_TABLE_CONTACTS = """
      CREATE TABLE IF NOT EXISTS Contacts (
        id        INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key       TEXT                              NOT NULL UNIQUE,
        note      TEXT                              NOT NULL,
        alias     TEXT                              NOT NULL,
        isblocked INTEGER                           NOT NULL,
        ingroup   TEXT                              NOT NULL
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

    private const string TABLE_KEY = "$KEY";
    private const string TABLE_NOTE = "$NOTE";
    private const string TABLE_ALIAS = "$ALIAS";
    private const string TABLE_ISBLOCKED = "$ISBLOCKED";
    private const string TABLE_GROUP = "$GROUP";

    private static string STATEMENT_INSERT_CONTACT = "INSERT OR REPLACE INTO Contacts (key, note, alias, isblocked, ingroup) VALUES (%s, %s, %s, %s, %s);".printf(TABLE_KEY, TABLE_NOTE, TABLE_ALIAS, TABLE_ISBLOCKED, TABLE_GROUP);
    private static string STATEMENT_SELECT_CONTACT = "SELECT * FROM Contacts WHERE key = %s".printf(TABLE_KEY);
    private static string STATEMENT_DELETE_CONTACT = "DELETE FROM Contacts WHERE key = %s".printf(TABLE_KEY);

    private IDatabaseStatement insertStatement;
    private IDatabaseStatement selectStatement;
    private IDatabaseStatement deleteStatement;
    private ILogger logger;

    public SqliteContactDatabase(IDatabaseStatementFactory statementFactory, ILogger logger) throws DatabaseStatementError {
      this.logger = logger;
      statementFactory
          .createStatement(QUERY_TABLE_CONTACTS)
          .step();

      insertStatement = statementFactory.createStatement(STATEMENT_INSERT_CONTACT);
      selectStatement = statementFactory.createStatement(STATEMENT_SELECT_CONTACT);
      deleteStatement = statementFactory.createStatement(STATEMENT_DELETE_CONTACT);

      logger.d("SqliteContactDatabase created.");
    }

    ~SqliteContactDatabase() {
      logger.d("SqliteContactDatabase destroyed.");
    }

    public void loadContactData(string userId, IContactData contactData) {
      try {
        selectStatement.bind_text(TABLE_KEY, userId);

        if (selectStatement.step() == Sqlite.ROW) {
          var note = selectStatement.column_text(ContactColumn.NOTE);
          var alias = selectStatement.column_text(ContactColumn.ALIAS);
          var isBlocked = selectStatement.column_bool(ContactColumn.ISBLOCKED);
          var group = selectStatement.column_text(ContactColumn.GROUP);
          contactData.saveContactData(note, alias, isBlocked, group);
        }
      } catch (DatabaseStatementError e) {
        logger.e("Error reading contact information from sqlite database: " + e.message);
      }

      selectStatement.reset();
    }

    public void saveContactData(string userId, string note, string alias, bool isBlocked, string group) {
      try {
        insertStatement.builder()
            .bind_text(TABLE_KEY, userId)
            .bind_text(TABLE_NOTE, note)
            .bind_text(TABLE_ALIAS, alias)
            .bind_bool(TABLE_ISBLOCKED, isBlocked)
            .bind_text(TABLE_GROUP, group)
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Error writing contact information to sqlite database: " + e.message);
      } finally {
        insertStatement.reset();
      }
    }

    public void deleteContactData(string userId) {
      try {
        deleteStatement.builder()
            .bind_text(TABLE_KEY, userId)
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Error deleting contact information in sqlite database: " + e.message);
      } finally {
        deleteStatement.reset();
      }
    }

  }
}
