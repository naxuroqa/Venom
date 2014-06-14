/*
 *    DhtNodeStorage.vala
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

  public interface IDhtNodeStorage : GLib.Object {
    public abstract DhtNode[] get_dht_nodes();
    public abstract void save_dht_node(DhtNode node);
  }

  public class DummyDhtNodeStorage : IDhtNodeStorage, GLib.Object {
    public DhtNode[] get_dht_nodes() {
      DhtNode[] nodes = {};
      nodes += new DhtNode.ipv4(
        "192.254.75.98",
        "951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F",
        33445,
        false,
        "stqism",
        "US"
      );
      nodes += new DhtNode.ipv6(
        "2607:5600:284::2",
        "951C88B7E75C867418ACDB5D273821372BB5BD652740BCDF623A4FA293E75D2F",
        33445,
        false,
        "stqism",
        "US"
      );
      nodes += new DhtNode.ipv4(
        "37.187.46.132",
        "A9D98212B3F972BD11DA52BEB0658C326FCCC1BFD49F347F9C2D3D8B61E1B927",
        33445,
        false,
        "mouseym",
        "FR"
      );
      nodes += new DhtNode.ipv6(
        "2001:41d0:0052:0300::0507",
        "A9D98212B3F972BD11DA52BEB0658C326FCCC1BFD49F347F9C2D3D8B61E1B927",
        33445,
        false,
        "mouseym",
        "FR"
      );
      nodes += new DhtNode.ipv4(
        "54.199.139.199",
        "7F9C31FE850E97CEFD4C4591DF93FC757C7C12549DDD55F8EEAECC34FE76C029",
        33445,
        false,
        "aitjcize",
        "JP"
      );
      nodes += new DhtNode.ipv4(
        "109.169.46.133",
        "7F31BFC93B8E4016A902144D0B110C3EA97CB7D43F1C4D21BCAE998A7C838821",
        33445,
        false,
        "astonex",
        "UK"
      );
      return nodes;
    }
    public void save_dht_node(DhtNode node) {}
  }

  public class SqliteDhtNodeStorage : IDhtNodeStorage, GLib.Object {
    private unowned Sqlite.Database db;
    private Sqlite.Statement insert_statement;
    private Sqlite.Statement select_statement;
    private static string QUERY_TABLE_NODES = """
      CREATE TABLE IF NOT EXISTS Nodes (
        id         INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key        TEXT NOT NULL,
        host       TEXT NOT NULL,
        isipv6     INTEGER,
        port       INTEGER,
        maintainer TEXT NOT NULL,
        location   TEXT NOT NULL,
        isblocked  INTEGER DEFAULT 0
      );
    """;
    private enum NodeColumn {
      ID,
      KEY,
      HOST,
      ISIPV6,
      PORT,
      MAINTAINER,
      LOCATION,
      ISBLOCKED
    }
    private static string TABLE_KEY = "$KEY";
    private static string TABLE_HOST = "$HOST";
    private static string TABLE_ISIPV6 = "$ISIPV6";
    private static string TABLE_PORT = "$PORT";
    private static string TABLE_MAINTAINER = "$MAINTAINER";
    private static string TABLE_LOCATION = "$LOCATION";
    private static string TABLE_ISBLOCKED = "$ISBLOCKED";

    private static string STATEMENT_INSERT_NODES = "INSERT INTO Nodes (key, host, isipv6, port, maintainer, location, isblocked) VALUES (%s, %s, %s, %s, %s, %s, %s);".printf(TABLE_KEY, TABLE_HOST, TABLE_ISIPV6, TABLE_PORT, TABLE_MAINTAINER, TABLE_LOCATION, TABLE_ISBLOCKED);
    private static string STATEMENT_SELECT_NODES = "SELECT * FROM Nodes";

    public DhtNode[] get_dht_nodes() {
      DhtNode[] nodes = {};

      while(select_statement.step () == Sqlite.ROW) {
        string key   = select_statement.column_text(NodeColumn.KEY);
        string host  = select_statement.column_text(NodeColumn.HOST);
        bool is_ipv6 = select_statement.column_int(NodeColumn.ISIPV6) != 0;
        uint16 port  = (uint16) select_statement.column_int(NodeColumn.PORT);
        string maintainer = select_statement.column_text(NodeColumn.MAINTAINER);
        string location   = select_statement.column_text(NodeColumn.LOCATION);
        bool is_blocked   = select_statement.column_int(NodeColumn.ISBLOCKED) != 0;

        if(is_ipv6) {
          nodes += new DhtNode.ipv6(host, key, port, is_blocked, maintainer, location);
        } else {
          nodes += new DhtNode.ipv4(host, key, port, is_blocked, maintainer, location);
        }
      }

      select_statement.reset ();
      return nodes;
    }

    public void save_dht_node(DhtNode node) {
      string key = Tools.bin_to_hexstring(node.pub_key);

      try {
        SqliteTools.put_text(insert_statement,  TABLE_KEY,     key);
        SqliteTools.put_text(insert_statement,  TABLE_HOST,    node.host);
        SqliteTools.put_int (insert_statement,  TABLE_ISIPV6,  node.is_ipv6 ? 1 : 0);
        SqliteTools.put_int (insert_statement,  TABLE_PORT,       node.port);
        SqliteTools.put_text(insert_statement,  TABLE_MAINTAINER, node.maintainer);
        SqliteTools.put_text(insert_statement,  TABLE_LOCATION,   node.location);
        SqliteTools.put_int (insert_statement,  TABLE_ISBLOCKED,  node.is_blocked ? 1 : 0);
      } catch (SqliteStatementError e) {
        stderr.printf("Error writing dht node to sqlite database: %s\n", e.message);
        return;
      }

      insert_statement.step();
      insert_statement.reset();
    }

    public SqliteDhtNodeStorage( Sqlite.Database db ) throws SqliteDbError {
      this.db = db;

      string errmsg;

      //create table and index if needed
      if(db.exec (QUERY_TABLE_NODES, null, out errmsg) != Sqlite.OK) {
        throw new SqliteDbError.QUERY(_("Error creating dht nodes table: %s\n"), errmsg);
      }

      //prepare insert statement for adding new history messages
      if(db.prepare_v2 (STATEMENT_INSERT_NODES, STATEMENT_INSERT_NODES.length, out insert_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY(_("Error creating dht nodes insert statement: %d: %s\n"), db.errcode (), db.errmsg());
      }

      //prepare select statement to get history. Will execute on indexed data
      if(db.prepare_v2 (STATEMENT_SELECT_NODES, STATEMENT_SELECT_NODES.length, out select_statement) != Sqlite.OK) {
        throw new SqliteDbError.QUERY(_("Error creating dht nodes select statement: %d: %s\n"), db.errcode (), db.errmsg());
      }
    }
  }
}
