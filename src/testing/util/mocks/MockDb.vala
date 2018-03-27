/*
 *    DatabaseMock.vala
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

using Venom;

namespace Mock {
  public class MockDatabase : IDatabase, Object {}

  public class MockStatement : IDatabaseStatement, Object {
    public DatabaseResult step() throws DatabaseStatementError {
      return (DatabaseResult) mock().actual_call(this, "step").get_int();
    }
    public void bind_text(string key, string val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_text").get_throws();
    }
    public void bind_int64(string key, int64 val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_int64").get_throws();
    }
    public void bind_int(string key, int val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_int").get_throws();
    }
    public void bind_bool(string key, bool val) throws DatabaseStatementError {
      mock().actual_call(this, "bind_bool").get_throws();
    }
    public string column_text(int key) throws DatabaseStatementError {
      return mock().actual_call(this, "column_text").get_string();
    }
    public int64 column_int64(int key) throws DatabaseStatementError {
      return mock().actual_call(this, "column_int64").get_int();
    }
    public int column_int(int key) throws DatabaseStatementError {
      return mock().actual_call(this, "column_int").get_int();
    }
    public bool column_bool(int key) throws DatabaseStatementError {
      return mock().actual_call(this, "column_bool").get_bool();
    }
    public void reset() {
      mock().actual_call(this, "reset");
    }
    public IDatabaseStatementBuilder builder() {
      return (IDatabaseStatementBuilder) mock().actual_call(this, "builder").get_object();
    }
  }

  public class MockDatabaseFactory : IDatabaseFactory, Object {
    public IDatabase createDatabase(string path) throws DatabaseError {
      return (IDatabase) mock().actual_call(this, "createDatabase").get_object();
    }
    public IDatabaseStatementFactory createStatementFactory(IDatabase database) {
      return (IDatabaseStatementFactory) mock().actual_call(this, "createStatementFactory").get_object();
    }
    public IDhtNodeDatabase createNodeDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return (IDhtNodeDatabase) mock().actual_call(this, "createNodeDatabase").get_object();
    }
    public IContactDatabase createContactDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return (IContactDatabase) mock().actual_call(this, "createContactDatabase").get_object();
    }
    public IMessageDatabase createMessageDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return (IMessageDatabase) mock().actual_call(this, "createMessageDatabase").get_object();
    }
    public ISettingsDatabase createSettingsDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      return (ISettingsDatabase) mock().actual_call(this, "createSettingsDatabase").get_object();
    }
  }

  public class MockStatementFactory : IDatabaseStatementFactory, Object {
    public IDatabaseStatement createStatement(string statement) {
      return (IDatabaseStatement) mock().actual_call(this, "createStatement").get_object();
    }
  }
}
