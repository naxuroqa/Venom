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
  public class MockDatabase : Database, Object {}

  public class MockStatement : DatabaseStatement, Object {
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
    public DatabaseStatementBuilder builder() {
      return (DatabaseStatementBuilder) mock().actual_call(this, "builder").get_object();
    }
  }

  public class MockDatabaseFactory : DatabaseFactory, Object {
    public Database create_database(string path, string key) throws DatabaseError {
      var args = Arguments.builder()
                     .string(path)
                     .string(key)
                     .create();
      return (Database) mock().actual_call(this, "create_database", args).get_object();
    }
    public DatabaseStatementFactory create_statement_factory(Database database) {
      var args = Arguments.builder()
                     .object(database)
                     .create();
      return (DatabaseStatementFactory) mock().actual_call(this, "create_statement_factory", args).get_object();
    }
    public DhtNodeRepository create_node_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (DhtNodeRepository) mock().actual_call(this, "create_node_repository", args).get_object();
    }
    public ContactRepository create_contact_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (ContactRepository) mock().actual_call(this, "createContactDatabase", args).get_object();
    }
    public MessageRepository create_message_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (MessageRepository) mock().actual_call(this, "create_message_repository", args).get_object();
    }
    public ISettingsDatabase create_settings_database(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (ISettingsDatabase) mock().actual_call(this, "create_settings_database", args).get_object();
    }
    public FriendRequestRepository create_friend_request_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (FriendRequestRepository) mock().actual_call(this, "create_friend_request_repository", args).get_object();
    }
    public NospamRepository create_nospam_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError {
      var args = Arguments.builder()
                     .object(factory)
                     .object(logger)
                     .create();
      return (NospamRepository) mock().actual_call(this, "create_nospam_repository", args).get_object();
    }
  }

  public class MockStatementFactory : DatabaseStatementFactory, Object {
    public DatabaseStatement create_statement(string statement) {
      var args = Arguments.builder()
                     .string(statement)
                     .create();
      return (DatabaseStatement) mock().actual_call(this, "create_statement", args).get_object();
    }
  }
}
