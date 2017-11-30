/*
 *    DatabaseMock.vala
 *
 *    Copyright (C) 2017 Venom authors and contributors
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

using Venom;

namespace Mock {
  public class MockDatabase : IDatabase, Object {}

  public class MockStatement : IDatabaseStatement, Object {
    public DatabaseResult step() throws DatabaseStatementError {
      mock().actual_call(this, "step");
      return DatabaseResult.OK;
    }
    public void bind_text(string key, string val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_text");
    }
    public void bind_int64(string key, int64 val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_int64");
    }
    public void bind_int(string key, int val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_int");
    }
    public void bind_bool(string key, bool val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_bool");
    }
    public string column_text(int key) throws DatabaseStatementError {
      mock().actual_call(this, "column_text");
      return "";
    }
    public int64 column_int64(int key) throws DatabaseStatementError {
      mock().actual_call(this, "column_int64");
      return 0;
    }
    public int column_int(int key) throws DatabaseStatementError {
      mock().actual_call(this, "column_int");
      return 0;
    }
    public bool column_bool(int key) throws DatabaseStatementError {
      mock().actual_call(this, "column_bool");
      return false;
    }
    public void reset() {
      mock().actual_call(this, "reset");
    }
    public IDatabaseStatementBuilder builder() {
      mock().actual_call(this, "builder");
      return new SqliteStatementWrapper.Builder(this);
    }
  }

  public class MockDatabaseFactory : IDatabaseFactory, Object {
    public bool throwExceptions = false;

    public MockDatabaseFactory(bool throwExceptions = false) {
      this.throwExceptions = throwExceptions;
    }

    public IDatabase createDatabase(string path) throws DatabaseError {
      mock().actual_call(this, "createDatabase");
      if (throwExceptions) {
        throw new DatabaseError.OPEN("Mock exception");
      }
      return new MockDatabase();
    }
    public IDatabaseStatementFactory createStatementFactory(IDatabase database) {
      mock().actual_call(this, "createStatementFactory");
      return new MockStatementFactory();
    }

    public IDhtNodeDatabase createNodeDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      mock().actual_call(this, "createNodeDatabase");
      return (IDhtNodeDatabase) null;
    }
    public IContactDatabase createContactDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      mock().actual_call(this, "createContactDatabase");
      return (IContactDatabase) null;
    }
    public IMessageDatabase createMessageDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      mock().actual_call(this, "createMessageDatabase");
      return (IMessageDatabase) null;
    }
    public ISettingsDatabase createSettingsDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      mock().actual_call(this, "createSettingsDatabase");
      return (ISettingsDatabase) null;
    }
  }

  public class MockStatementFactory : IDatabaseStatementFactory, Object {
    public IDatabaseStatement createStatement(string statement) {
      mock().actual_call(this, "createStatement");
      return new MockStatement();
    }
  }
}
