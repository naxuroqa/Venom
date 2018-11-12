/*
 *    SqliteDhtNodeRepository.vala
 *
 *    Copyright (C) 2017-2018 Venom authors and contributors
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
  public class SqliteDhtNodeRepository : DhtNodeRepository, Object {
    private const string CREATE_TABLE_NODES = """
      CREATE TABLE IF NOT EXISTS nodes (
        id        INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key       TEXT                              NOT NULL,
        address   TEXT                              NOT NULL,
        port      INTEGER                           NOT NULL,
        isblocked INTEGER                           NOT NULL,
        owner     TEXT                              NOT NULL,
        location  TEXT                              NOT NULL
      );
    """;
    private enum NodeColumn { ID, KEY, ADDRESS, PORT, ISBLOCKED, OWNER, LOCATION }

    private Logger logger;
    private SqliteStatementFactory statementFactory;

    public SqliteDhtNodeRepository(DatabaseStatementFactory statementFactory, Logger logger) throws DatabaseStatementError {
      this.logger = logger;
      this.statementFactory = (SqliteStatementFactory) statementFactory;

      statementFactory
          .create_statement(CREATE_TABLE_NODES)
          .step();

      logger.d("SqliteDhtNodeRepository created.");
    }

    ~SqliteDhtNodeRepository() {
      logger.d("SqliteDhtNodeRepository destroyed.");
    }

    public void create(DhtNode node) {
      var query_stmt = statementFactory.create_statement(
        """
        SELECT (id) FROM nodes
        WHERE key=$KEY AND address=$ADDRESS AND port=$PORT;
        """);
      query_stmt.builder()
        .bind_text("$KEY", node.pub_key)
        .bind_text("$ADDRESS", node.host)
        .bind_int("$PORT", (int) node.port);

      if (query_stmt.step() == DatabaseResult.ROW) {
        logger.d("Dht Node with key/address/port already known, ignoring.");
        node.id = query_stmt.column_int(0);
      } else {
        statementFactory.create_statement(
          """
          INSERT INTO nodes (key, address, port, isblocked, owner, location)
          VALUES ($KEY, $ADDRESS, $PORT, $ISBLOCKED, $OWNER, $LOCATION);
          """).builder()
          .bind_text("$KEY", node.pub_key)
          .bind_text("$ADDRESS", node.host)
          .bind_int("$PORT", (int) node.port)
          .bind_bool("$ISBLOCKED", node.is_blocked)
          .bind_text("$OWNER", node.maintainer)
          .bind_text("$LOCATION", node.location)
          .step();
        node.id = (int) statementFactory.last_insert_rowid();
      }

    }
    public void read(DhtNode node) {
      var query_stmt = statementFactory.create_statement(
        """
        SELECT * FROM nodes
        WHERE id=$ID;
        """
      );
      query_stmt.bind_int("$ID", node.id);
      if (query_stmt.step() == DatabaseResult.ROW) {
        node.pub_key = query_stmt.column_text(NodeColumn.KEY);
        node.host = query_stmt.column_text(NodeColumn.ADDRESS);
        node.port = query_stmt.column_int(NodeColumn.PORT);
        node.is_blocked = query_stmt.column_bool(NodeColumn.ISBLOCKED);
        node.maintainer = query_stmt.column_text(NodeColumn.OWNER);
        node.location = query_stmt.column_text(NodeColumn.LOCATION);
      } else {
        logger.e("Can not find dht node with id %i".printf(node.id));
      }
    }
    public void update(DhtNode node) {
      statementFactory.create_statement(
        """
        UPDATE nodes
        SET key=$KEY, address=$ADDRESS, port=$PORT, isblocked=$ISBLOCKED, owner=$OWNER, location=$LOCATION
        WHERE id=$ID;
        """).builder()
        .bind_int("$ID", node.id)
        .bind_text("$KEY", node.pub_key)
        .bind_text("$ADDRESS", node.host)
        .bind_int("$PORT", (int) node.port)
        .bind_bool("$ISBLOCKED", node.is_blocked)
        .bind_text("$OWNER", node.maintainer)
        .bind_text("$LOCATION", node.location)
        .step();
    }
    public void delete(DhtNode node) {
      statementFactory.create_statement(
        """
        DELETE FROM nodes
        WHERE id=$ID;
        """).builder()
        .bind_int("$ID", node.id)
        .step();
    }
    public Gee.Iterable<DhtNode> query_all() {
      var list = new Gee.LinkedList<DhtNode>();
      var query_stmt = statementFactory.create_statement("SELECT * FROM nodes;");
      while (query_stmt.step() == DatabaseResult.ROW) {
        var node = new DhtNode();
        node.id = query_stmt.column_int(NodeColumn.ID);
        node.pub_key = query_stmt.column_text(NodeColumn.KEY);
        node.host = query_stmt.column_text(NodeColumn.ADDRESS);
        node.port = query_stmt.column_int(NodeColumn.PORT);
        node.is_blocked = query_stmt.column_bool(NodeColumn.ISBLOCKED);
        node.maintainer = query_stmt.column_text(NodeColumn.OWNER);
        node.location = query_stmt.column_text(NodeColumn.LOCATION);
        list.add(node);
      }
      return list;
    }
  }
}
