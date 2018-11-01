/*
 *    MessageDatabase.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  public class SqliteMessageDatabase : IMessageDatabase, Object {
    private enum HistoryColumn {
      ID,
      USER,
      CONTACT,
      MESSAGE,
      TIME,
      SENDER
    }

    private const string TABLE_USER = "$USER";
    private const string TABLE_CONTACT = "$CONTACT";
    private const string TABLE_MESSAGE = "$MESSAGE";
    private const string TABLE_TIME = "$TIME";
    private const string TABLE_SENDER = "$SENDER";

    private string STATEMENT_INSERT_HISTORY = "INSERT INTO History (userHash, contactHash, message, timestamp, issent) VALUES (%s, %s, %s, %s, %s);".printf(TABLE_USER, TABLE_CONTACT, TABLE_MESSAGE, TABLE_TIME, TABLE_SENDER);
    private string STATEMENT_SELECT_HISTORY = "SELECT * FROM History WHERE userHash = %s AND contactHash = %s;".printf(TABLE_USER, TABLE_CONTACT);
    private string STATEMENT_SANITIZE_DATABASE = "DELETE FROM History WHERE timestamp < %s;".printf(TABLE_TIME);

    private const string QUERY_TABLE_HISTORY = """
      CREATE TABLE IF NOT EXISTS History (
        id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        userHash    TEXT                              NOT NULL,
        contactHash TEXT                              NOT NULL,
        message     TEXT                              NOT NULL,
        timestamp   INTEGER                           NOT NULL,
        issent      INTEGER                           NOT NULL
      );
      """;

    private ILogger logger;

    private IDatabaseStatement insertStatement;
    private IDatabaseStatement selectStatement;
    private IDatabaseStatement sanitizeStatement;

    public SqliteMessageDatabase(IDatabaseStatementFactory statementFactory, ILogger logger) throws DatabaseStatementError {
      this.logger = logger;

      statementFactory
          .create_statement(QUERY_TABLE_HISTORY)
          .step();

      insertStatement = statementFactory.create_statement(STATEMENT_INSERT_HISTORY);
      selectStatement = statementFactory.create_statement(STATEMENT_SELECT_HISTORY);
      sanitizeStatement = statementFactory.create_statement(STATEMENT_SANITIZE_DATABASE);
      logger.d("SqliteMessageDatabase created.");
    }

    ~SqliteMessageDatabase() {
      logger.d("SqliteMessageDatabase destroyed.");
    }

    public void insertMessage(string userId, string contactId, string message, DateTime time, bool outgoing) {
      try {
        insertStatement.builder()
            .bind_text(TABLE_USER, userId)
            .bind_text(TABLE_CONTACT, contactId)
            .bind_text(TABLE_MESSAGE, message)
            .bind_int64(TABLE_TIME, time.to_unix())
            .bind_bool(TABLE_SENDER, outgoing)
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Error writing message to database: " + e.message);
      } finally {
        insertStatement.reset();
      }
    }

    public List<ILoggedMessage> retrieveMessages(string userId, string contactId, ILoggedMessageFactory messageFactory) {
      var messages = new List<ILoggedMessage>();
      try {
        selectStatement.builder()
            .bind_text(TABLE_USER, userId)
            .bind_text(TABLE_CONTACT, contactId);

        while (selectStatement.step() == DatabaseResult.ROW) {
          var messageString = selectStatement.column_text(HistoryColumn.MESSAGE);
          var timestamp = selectStatement.column_int64(HistoryColumn.TIME);
          var outgoing = selectStatement.column_bool(HistoryColumn.SENDER);
          var sendTime = new DateTime.from_unix_local(timestamp);
          var message = messageFactory.createLoggedMessage(userId, contactId, messageString, sendTime, outgoing);
          messages.append(message);
        }
      } catch (DatabaseStatementError e) {
        logger.e("Error retrieving messages from database: " + e.message);
      } finally {
        selectStatement.reset();
      }
      return messages;
    }

    public void deleteMessagesBefore(DateTime date) {
      try {
        sanitizeStatement.builder()
            .bind_int64(TABLE_TIME, date.to_unix())
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Error sanitizing database: " + e.message);
      } finally {
        sanitizeStatement.reset();
      }
    }
  }
}
