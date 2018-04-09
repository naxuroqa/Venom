/*
 *    SqliteDhtNodeDatabase.vala
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
  public class SqliteDhtNodeDatabase : IDhtNodeDatabase, Object {
    private const string CREATE_TABLE_NODES = """
      CREATE TABLE IF NOT EXISTS Nodes (
        id        INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key       TEXT                              NOT NULL UNIQUE,
        address   TEXT                              NOT NULL,
        port      INTEGER                           NOT NULL,
        isblocked INTEGER                           NOT NULL,
        owner     TEXT                              NOT NULL,
        location  TEXT                              NOT NULL
      );
    """;
    private enum NodeColumn {
      ID,
      KEY,
      ADDRESS,
      PORT,
      ISBLOCKED,
      OWNER,
      LOCATION
    }

    private const string TABLE_KEY = "$KEY";
    private const string TABLE_ADDRESS = "$ADDRESS";
    private const string TABLE_PORT = "$PORT";
    private const string TABLE_ISBLOCKED = "$ISBLOCKED";
    private const string TABLE_OWNER = "$OWNER";
    private const string TABLE_LOCATION = "$LOCATION";

    private static string STATEMENT_INSERT_NODE = "INSERT OR REPLACE INTO Nodes (key, address, port, isblocked, owner, location) VALUES (%s, %s, %s, %s, %s, %s);".printf(TABLE_KEY, TABLE_ADDRESS, TABLE_PORT, TABLE_ISBLOCKED, TABLE_OWNER, TABLE_LOCATION);
    private static string STATEMENT_SELECT_NODES = "SELECT * FROM Nodes";
    private static string STATEMENT_DELETE_NODE = "DELETE FROM Nodes WHERE key = %s".printf(TABLE_KEY);

    private IDatabaseStatement insertStatement;
    private IDatabaseStatement selectStatement;
    private IDatabaseStatement deleteStatement;

    private ILogger logger;

    public SqliteDhtNodeDatabase(IDatabaseStatementFactory statementFactory, ILogger logger) throws DatabaseStatementError {
      this.logger = logger;

      statementFactory
          .createStatement(CREATE_TABLE_NODES)
          .step();

      insertStatement = statementFactory.createStatement(STATEMENT_INSERT_NODE);
      selectStatement = statementFactory.createStatement(STATEMENT_SELECT_NODES);
      deleteStatement = statementFactory.createStatement(STATEMENT_DELETE_NODE);

      logger.d("SqliteDhtNodeDatabase created.");
    }

    ~SqliteDhtNodeDatabase() {
      logger.d("SqliteDhtNodeDatabase destroyed.");
    }

    public List<IDhtNode> getDhtNodes(IDhtNodeFactory nodeFactory) {
      var dhtNodes = new List<IDhtNode>();
      try {
        while (selectStatement.step() == DatabaseResult.ROW) {
          var key = selectStatement.column_text(NodeColumn.KEY);
          var address = selectStatement.column_text(NodeColumn.ADDRESS);
          var port = selectStatement.column_int(NodeColumn.PORT);
          var isBlocked = selectStatement.column_bool(NodeColumn.ISBLOCKED);
          var owner = selectStatement.column_text(NodeColumn.OWNER);
          var location = selectStatement.column_text(NodeColumn.LOCATION);
          var node = nodeFactory.createDhtNode(key, address, port, isBlocked, owner, location);
          dhtNodes.append(node);
        }
      } catch (DatabaseStatementError e) {
        logger.e("Could not read dht node from database: " + e.message);
      } finally {
        selectStatement.reset();
      }
      return dhtNodes;
    }

    public void insertDhtNode(string key, string address, uint port, bool isBlocked, string owner, string location) {
      try {
        insertStatement.builder()
            .bind_text(TABLE_KEY, key)
            .bind_text(TABLE_ADDRESS, address)
            .bind_int(TABLE_PORT, (int) port)
            .bind_bool(TABLE_ISBLOCKED, isBlocked)
            .bind_text(TABLE_OWNER, owner)
            .bind_text(TABLE_LOCATION, location)
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Could not insert Dht Node into database: " + e.message);
      } finally {
        insertStatement.reset();
      }
    }

    public void deleteDhtNode(string key) {
      try {
        deleteStatement.builder()
            .bind_text(TABLE_KEY, key)
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Could not delete Dht Node in database: " + e.message);
      } finally {
        deleteStatement.reset();
      }
    }
  }
}
