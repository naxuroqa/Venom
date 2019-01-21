/*
 *    SqliteWrapper.vala
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

  public class SqliteWrapperFactory : DatabaseFactory, Object {
    public Database create_database(string path, string key) throws DatabaseError {
      var update = new SqliteDatabaseUpdate();
      return new SqliteDatabaseWrapper(path, key, update);
    }
    public DatabaseStatementFactory create_statement_factory(Database database) {
      return new SqliteStatementFactory(database as SqliteDatabaseWrapper);
    }
    public DhtNodeRepository create_node_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      return new SqliteDhtNodeRepository(factory, logger);
    }
    public ContactRepository create_contact_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      return new SqliteContactRepository(factory, logger);
    }
    public MessageRepository create_message_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      return new SqliteMessageRepository(factory, logger);
    }
    public ISettingsDatabase create_settings_database(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      return new SqliteSettingsDatabase(factory, logger);
    }
    public FriendRequestRepository create_friend_request_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      return new SqliteFriendRequestRepository(factory, logger);
    }
    public NospamRepository create_nospam_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      return new SqliteNospamRepository(factory, logger);
    }
  }

  public class SqliteStatementFactory : DatabaseStatementFactory, Object {
    private SqliteDatabaseWrapper database;
    public SqliteStatementFactory(SqliteDatabaseWrapper database) {
      this.database = database;
    }

    public DatabaseStatement create_statement(string zSql) throws DatabaseStatementError {
      return new SqliteStatementWrapper(database, zSql);
    }

    public SqliteQueryResult query_database(string sql) throws DatabaseError {
      return database.query(sql);
    }

    public int64 last_insert_rowid() {
      return database.last_insert_rowid();
    }
  }

  public class SqliteStatementWrapper : DatabaseStatement, Object {
    private Sqlite.Statement statement;

    public SqliteStatementWrapper(SqliteDatabaseWrapper database, string zSql) throws DatabaseStatementError {
      var result = database.handle.prepare_v2(zSql, zSql.length, out statement);
      if (result != Sqlite.OK) {
        throw new DatabaseStatementError.PREPARE("Could not create statement: " + database.handle.errmsg());
      }
    }

    public DatabaseResult step() throws DatabaseStatementError {
      return fromSqlite(checkSqliteStepResult(statement.step()));
    }

    public void bind_text(string key, string val) throws DatabaseStatementError {
      var index = statement.bind_parameter_index(key);
      checkSqliteBindResult(statement.bind_text(index, val));
    }
    public void bind_int64(string key, int64 val) throws DatabaseStatementError {
      var index = statement.bind_parameter_index(key);
      checkSqliteBindResult(statement.bind_int64(index, val));
    }
    public void bind_int(string key, int val) throws DatabaseStatementError {
      var index = statement.bind_parameter_index(key);
      checkSqliteBindResult(statement.bind_int(index, val));
    }

    public void bind_bool(string key, bool val) throws DatabaseStatementError {
      bind_int(key, val ? 1 : 0);
    }

    public string column_text(int key) throws DatabaseStatementError {
      return statement.column_text(key);
    }
    public int64 column_int64(int key) throws DatabaseStatementError {
      return statement.column_int64(key);
    }
    public int column_int(int key) throws DatabaseStatementError {
      return statement.column_int(key);
    }

    public bool column_bool(int key) throws DatabaseStatementError {
      return column_int(key) != 0;
    }

    private DatabaseResult fromSqlite(int result) {
      switch (result) {
        case Sqlite.OK:
          return DatabaseResult.OK;
        case Sqlite.DONE:
          return DatabaseResult.DONE;
        case Sqlite.ABORT:
          return DatabaseResult.ABORT;
        case Sqlite.ERROR:
          return DatabaseResult.ERROR;
        case Sqlite.ROW:
          return DatabaseResult.ROW;
      }
      return DatabaseResult.OTHER;
    }

    private int checkSqliteBindResult(int result) throws DatabaseStatementError {
      if (result != Sqlite.OK) {
        throw new DatabaseStatementError.BIND("Could not bind statement: " + result.to_string());
      }
      return result;
    }

    private int checkSqliteStepResult(int result) throws DatabaseStatementError {
      if (result != Sqlite.DONE && result != Sqlite.ROW) {
        throw new DatabaseStatementError.STEP("Could not step statement: " + result.to_string());
      }
      return result;
    }

    public void reset() {
      statement.reset();
    }

    public DatabaseStatementBuilder builder() {
      return new Builder(this);
    }

    public class Builder : DatabaseStatementBuilder, Object {
      private DatabaseStatement statement;
      public Builder(DatabaseStatement statement) {
        this.statement = statement;
      }

      public DatabaseStatementBuilder step() throws DatabaseStatementError {
        statement.step();
        return this;
      }
      public DatabaseStatementBuilder bind_text(string key, string val) throws DatabaseStatementError {
        statement.bind_text(key, val);
        return this;
      }
      public DatabaseStatementBuilder bind_int64(string key, int64 val) throws DatabaseStatementError {
        statement.bind_int64(key, val);
        return this;
      }
      public DatabaseStatementBuilder bind_int(string key, int val) throws DatabaseStatementError {
        statement.bind_int(key, val);
        return this;
      }
      public DatabaseStatementBuilder bind_bool(string key, bool val) throws DatabaseStatementError {
        statement.bind_bool(key, val);
        return this;
      }
      public DatabaseStatementBuilder reset() {
        statement.reset();
        return this;
      }
    }
  }

  public interface SqlSpecification : GLib.Object {
    public abstract string create_statement(SqliteStatementFactory statement_factory);
  }

  public class SqliteDatabaseUpdate : DatabaseUpdate, GLib.Object {
    public void update_database(Database database) throws DatabaseError {
      var sqliteDatabase = database as SqliteDatabaseWrapper;
      if (sqliteDatabase.version == 0) {
        sqliteDatabase.query(
          """
          DROP TABLE IF EXISTS Contacts;
          DROP TABLE IF EXISTS Nodes;
          PRAGMA user_version=1;
          """
        );
      }
    }
  }

  public class SqliteQueryResultRow {
    public int n_columns;
    public string[] values;
    public string[] column_names;
    public SqliteQueryResultRow(int n_columns, string[] values, string[] column_names) {
      this.n_columns = n_columns;
      this.values = new string[n_columns];
      this.column_names = new string[n_columns];
      for(var i = 0; i < n_columns; i++) {
        this.values[i] = values[i];
        this.column_names[i] = column_names[i];
      }
    }
  }

  public class SqliteQueryResult {
    public SqliteQueryResultRow[] rows;
    public SqliteQueryResult(SqliteQueryResultRow[] rows) {
      this.rows = rows;
    }

    public string to_string() {
      var str = new StringBuilder();
      foreach(var row in rows) {
        for (var i = 0; i < row.n_columns; i++) {
          str.append("[%s] %s\n".printf(row.column_names[i], row.values[i]));
        }
      }
      return str.str;
    }
  }

  public class SqliteQuery {
    private string query;
    public SqliteQuery(string query) {
      this.query = query;
    }
    public SqliteQueryResult exec(Sqlite.Database db) throws DatabaseError {
      string errmsg;
      SqliteQueryResultRow[] rows = {};
      var result = db.exec(query, (n_columns, values, column_names) => {
        rows += new SqliteQueryResultRow(n_columns, values, column_names);
        return 0;
      }, out errmsg);

      if (result != Sqlite.OK) {
        throw new DatabaseError.EXEC("Cannot execute query: " + errmsg);
      }
      return new SqliteQueryResult(rows);
    }
  }

  public class SqliteDatabaseWrapper : Database, GLib.Object {
    private Sqlite.Database database;
    private int _version = 0;
    private bool _compatibility = false;
    private string key = "";

    public Sqlite.Database handle {
      get { return database; }
    }

    public bool compatibility {
      get { return _compatibility; }
    }

    public int version {
      get { return _version; }
    }

    public SqliteQueryResult query(string sql) throws DatabaseError {
      return (new SqliteQuery(sql)).exec(database);
    }

    public int64 last_insert_rowid() {
      return database.last_insert_rowid();
    }

    private static Sqlite.Database open_database(string path) throws DatabaseError {
      Sqlite.Database database;
      var result = Sqlite.Database.open_v2(path, out database);
      if (result != Sqlite.OK) {
        throw new DatabaseError.OPEN("Cannot open sqlite database: " + database.errmsg());
      }
      return database;
    }

    public SqliteDatabaseWrapper(string path, string key, DatabaseUpdate update) throws DatabaseError {
      database = open_database(path);

      if (key.length > 0) {
        var key_pragma = @"PRAGMA key = \"x'$key'\";";
        query(key_pragma);
        try {
          query("SELECT count(*) FROM sqlite_master;");
        } catch (DatabaseError e) {
          _compatibility = true;
          database = null;
          database = open_database(path);
          query(key_pragma);
          query("PRAGMA cipher_compatibility = 3;");
          query("SELECT count(*) FROM sqlite_master;");
        }
      }

      try {
        var version = query("PRAGMA user_version;");
        _version = int.parse(version.rows[0].values[0]);
      } catch (DatabaseError e) {
      }

      update.update_database(this);
    }
  }
}
