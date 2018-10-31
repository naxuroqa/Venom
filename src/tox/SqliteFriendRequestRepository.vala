/*
 *    FriendRequestRepository.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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
  public class SqliteFriendRequestRepository : IFriendRequestRepository, Object {
    private const string CREATE_TABLE_FRIEND_REQUESTS = """
      CREATE TABLE IF NOT EXISTS friend_requests (
        id        INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key       TEXT                              NOT NULL,
        message   TEXT                              NOT NULL,
        timestamp INT64                             NOT NULL
      );
    """;

    private enum FriendRequestColumn { ID, KEY, MESSAGE, TIMESTAMP}

    private ILogger logger;
    private SqliteStatementFactory statement_factory;

    public SqliteFriendRequestRepository(IDatabaseStatementFactory statement_factory, ILogger logger) throws DatabaseStatementError {
      this.logger = logger;
      this.statement_factory = (SqliteStatementFactory) statement_factory;

      statement_factory
          .create_statement(CREATE_TABLE_FRIEND_REQUESTS)
          .step();

      logger.d("SqliteFriendRequestRepository created.");
    }

    ~SqliteFriendRequestRepository() {
      logger.d("SqliteFriendRequestRepository destroyed.");
    }
    public void create(FriendRequest friend_request) {
      statement_factory.create_statement(
        """
        INSERT INTO friend_requests (key, message, timestamp)
        VALUES ($KEY, $MESSAGE, $TIMESTAMP);
        """).builder()
        .bind_text("$KEY", friend_request.id)
        .bind_text("$MESSAGE", friend_request.message)
        .bind_int64("$TIMESTAMP", friend_request.timestamp.to_unix())
        .step();
      friend_request.db_id = (int) statement_factory.last_insert_rowid();
    }
    public void delete(FriendRequest friend_request) {
      statement_factory.create_statement(
        """
        DELETE FROM friend_requests
        WHERE id=$ID;
        """).builder()
        .bind_int("$ID", friend_request.db_id)
        .step();
    }
    public Gee.Iterable<FriendRequest> query_all() {
      var list = new Gee.LinkedList<FriendRequest>();
      var query_stmt = statement_factory.create_statement("SELECT * FROM friend_requests;");
      while (query_stmt.step() == DatabaseResult.ROW) {
        var friend_request = new FriendRequest.empty();
        friend_request.db_id = query_stmt.column_int(FriendRequestColumn.ID);
        friend_request.id = query_stmt.column_text(FriendRequestColumn.KEY);
        friend_request.message = query_stmt.column_text(FriendRequestColumn.MESSAGE);
        friend_request.timestamp = new DateTime.from_unix_local(query_stmt.column_int64(FriendRequestColumn.TIMESTAMP));
        list.add(friend_request);
      }
      return list;
    }
  }
}
