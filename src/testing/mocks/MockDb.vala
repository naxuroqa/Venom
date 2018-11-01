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
      var args = Arguments.builder()
                     .string(key)
                     .string(val)
                     .create();
      mock().actual_call(this, "bind_text", args).get_throws();
    }
    public void bind_int64(string key, int64 val) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .string(key)
                     .int64(val)
                     .create();
      mock().actual_call(this, "bind_int64", args).get_throws();
    }
    public void bind_int(string key, int val) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .string(key)
                     .int(val)
                     .create();
      mock().actual_call(this, "bind_int", args).get_throws();
    }
    public void bind_bool(string key, bool val) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .string(key)
                     .bool(val)
                     .create();
      mock().actual_call(this, "bind_bool", args).get_throws();
    }
    public string column_text(int key) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .int(key)
                     .create();
      return mock().actual_call(this, "column_text", args).get_string();
    }
    public int64 column_int64(int key) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .int(key)
                     .create();
      return mock().actual_call(this, "column_int64", args).get_int();
    }
    public int column_int(int key) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .int(key)
                     .create();
      return mock().actual_call(this, "column_int", args).get_int();
    }
    public bool column_bool(int key) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .int(key)
                     .create();
      return mock().actual_call(this, "column_bool", args).get_bool();
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
      var args = Arguments.builder()
                     .string(path)
                     .create();
      return (IDatabase) mock().actual_call(this, "createDatabase", args).get_object();
    }
    public IDatabaseStatementFactory create_statement_factory(IDatabase database) {
      var args = Arguments.builder()
                     .object(database)
                     .create();
      return (IDatabaseStatementFactory) mock().actual_call(this, "create_statement_factory", args).get_object();
    }
    public IDhtNodeRepository create_node_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (IDhtNodeRepository) mock().actual_call(this, "create_node_repository", args).get_object();
    }
    public IContactRepository create_contact_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (IContactRepository) mock().actual_call(this, "createContactDatabase", args).get_object();
    }
    public IMessageDatabase createMessageDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (IMessageDatabase) mock().actual_call(this, "createMessageDatabase", args).get_object();
    }
    public ISettingsDatabase create_settings_database(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (ISettingsDatabase) mock().actual_call(this, "create_settings_database", args).get_object();
    }
    public IFriendRequestRepository create_friend_request_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (IFriendRequestRepository) mock().actual_call(this, "create_friend_request_repository", args).get_object();
    }
    public INospamRepository create_nospam_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (INospamRepository) mock().actual_call(this, "create_nospam_repository", args).get_object();
    }
  }

  public class MockStatementFactory : IDatabaseStatementFactory, Object {
    public IDatabaseStatement create_statement(string statement) {
      var args = Arguments.builder()
                     .string(statement)
                     .create();
      return (IDatabaseStatement) mock().actual_call(this, "create_statement", args).get_object();
    }
  }
}
