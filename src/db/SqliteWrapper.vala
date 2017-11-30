/*
 *    SqliteWrapper.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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

  public class SqliteWrapperFactory : IDatabaseFactory, Object {
    public IDatabase createDatabase(string path) throws DatabaseError {
      return new SqliteDatabaseWrapper(path);
    }

    public IDatabaseStatementFactory createStatementFactory(IDatabase database) {
      return new SqliteStatementFactory(database as SqliteDatabaseWrapper);
    }

    public IDhtNodeDatabase createNodeDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return new SqliteDhtNodeDatabase(factory, logger);
    }
    public IContactDatabase createContactDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return new SqliteContactDatabase(factory, logger);
    }
    public IMessageDatabase createMessageDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return new SqliteMessageDatabase(factory, logger);
    }

    public ISettingsDatabase createSettingsDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return new SqliteSettingsDatabase(factory, logger);
    }
  }

  public class SqliteStatementFactory : IDatabaseStatementFactory, Object {
    private SqliteDatabaseWrapper database;
    public SqliteStatementFactory(SqliteDatabaseWrapper database) {
      this.database = database;
    }

    public IDatabaseStatement createStatement(string zSql) throws DatabaseStatementError {
      return new SqliteStatementWrapper(database, zSql);
    }
  }

  public class SqliteStatementWrapper : IDatabaseStatement, Object {
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

    public IDatabaseStatementBuilder builder() {
      return new Builder(this);
    }

    public class Builder : IDatabaseStatementBuilder, Object {
      private IDatabaseStatement statement;
      public Builder(IDatabaseStatement statement) {
        this.statement = statement;
      }

      public IDatabaseStatementBuilder step() throws DatabaseStatementError {
        statement.step();
        return this;
      }
      public IDatabaseStatementBuilder bind_text(string key, string val) throws DatabaseStatementError {
        statement.bind_text(key, val);
        return this;
      }
      public IDatabaseStatementBuilder bind_int64(string key, int64 val) throws DatabaseStatementError {
        statement.bind_int64(key, val);
        return this;
      }
      public IDatabaseStatementBuilder bind_int(string key, int val) throws DatabaseStatementError {
        statement.bind_int(key, val);
        return this;
      }
      public IDatabaseStatementBuilder bind_bool(string key, bool val) throws DatabaseStatementError {
        statement.bind_bool(key, val);
        return this;
      }
      public IDatabaseStatementBuilder reset() {
        statement.reset();
        return this;
      }
    }
  }

  public class SqliteDatabaseWrapper : IDatabase, Object {
    private Sqlite.Database database;

    public Sqlite.Database handle {
      get { return database; }
    }

    public SqliteDatabaseWrapper(string path) throws DatabaseError {
      var result = Sqlite.Database.open_v2(path, out database);
      if (result != Sqlite.OK) {
        throw new DatabaseError.OPEN("Cannot open sqlite database: " + database.errmsg());
      }
    }
  }
}
