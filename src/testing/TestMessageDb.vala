/*
 *    TestMessageDb.vala
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
using Mock;

namespace TestMessageDb {

  private static void testMessageDb() {
    var statementFactory = new MockStatementFactory();
    var logger = new MockLogger();
    try {
      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
    } catch (Error e) {
      Test.fail();
      return;
    }
    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();
  }

  private static void testMessageDbInsert() {
    var statementFactory = new MockStatementFactory();
    var logger = new MockLogger();
    try {
      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
      messageDatabase.insertMessage("", "", "", new DateTime.now_local(), true);
    } catch (Error e) {
      Test.fail();
      return;
    }
    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();
  }

  private static void testMessageDbRetrieve() {
    var statementFactory = new MockStatementFactory();
    var messageFactory = new MockLoggedMessageFactory();
    var logger = new MockLogger();
    try {
      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
      var messages = messageDatabase.retrieveMessages("", "", messageFactory);
      assert(messages.length() == 0);
    } catch (Error e) {
      Test.fail();
      return;
    }
    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();
    assert(messageFactory.createLoggedMessageCounter == 0);
  }

  private static void testRealDb() {
    var logger = new MockLogger();

    var factory = new SqliteWrapperFactory();

    try {
      var database = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(database);

      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
    } catch (Error e) {
      stderr.printf("failed: " + e.message);
      Test.fail();
      return;
    }
    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();
  }

  private static void testRealDbInsert() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();

    try {
      var database = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(database);

      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
      messageDatabase.insertMessage("", "", "", new DateTime.now_local(), true);
    } catch (Error e) {
      stderr.printf("failed: " + e.message);
      Test.fail();
      return;
    }
    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();
  }

  private static void testRealDbRetrieve() {
    var logger = new MockLogger();
    var messageFactory = new MockLoggedMessageFactory();
    var factory = new SqliteWrapperFactory();

    try {
      var database = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(database);

      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
      var messages = messageDatabase.retrieveMessages("", "", messageFactory);
      assert(messages.length() == 0);
    } catch (Error e) {
      stderr.printf("failed: " + e.message);
      Test.fail();
      return;
    }

    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();
    assert(messageFactory.createLoggedMessageCounter == 0);
  }

  private static void testRealDbInsertRetrieve() {
    var userId = "a";
    var contactId = "b";
    var message = "c";
    var time = new DateTime.now_local();
    var sender = true;

    var logger = new MockLogger();
    var messageFactory = new MockLoggedMessageFactory();
    var factory = new SqliteWrapperFactory();

    try {
      var database = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(database);

      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
      messageDatabase.insertMessage(userId, contactId, message, time, sender);
      var messages = messageDatabase.retrieveMessages(userId, contactId, messageFactory);
      assert(messages.length() == 1);
    } catch (Error e) {
      stderr.printf("failed: " + e.message);
      Test.fail();
      return;
    }

    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();

    assert(messageFactory.createLoggedMessageCounter == 1);
    assert(messageFactory.createdMessages.length() == 1);
    stdout.printf("\n");
    stdout.printf("received data: " + messageFactory.createdMessages.nth_data(0) + "\n");
    var concat_str = userId + contactId + message + time.to_string() + sender.to_string();
    stdout.printf("expected data: " + concat_str + "\n");
    assert(messageFactory.createdMessages.nth_data(0) == concat_str);
  }

  private static void testRealDbInsertSanitizeRetrieve() {
    var userId = "a";
    var contactId = "b";
    var time = new DateTime.now_local();

    var logger = new MockLogger();
    var messageFactory = new MockLoggedMessageFactory();
    var factory = new SqliteWrapperFactory();

    try {
      var database = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(database);

      var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
      assert_nonnull(messageDatabase);
      messageDatabase.insertMessage(userId, contactId, "", time.add_seconds(-1), false);
      messageDatabase.insertMessage(userId, contactId, "", time.add_seconds(+1), false);
      messageDatabase.deleteMessagesBefore(time);
      var messages = messageDatabase.retrieveMessages(userId, contactId, messageFactory);
      assert(messages.length() == 1);

    } catch (Error e) {
      stderr.printf("failed: " + e.message);
      Test.fail();
      return;
    }

    mock().expect_calls(logger, "d", 2);
    check_expectations_noerror();

    assert(messageFactory.createLoggedMessageCounter == 1);
  }

  private static void main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_message_db", testMessageDb);
    Test.add_func("/test_message_db_insert", testMessageDbInsert);
    Test.add_func("/test_message_db_retrieve", testMessageDbRetrieve);
    Test.add_func("/test_real_db", testRealDb);
    Test.add_func("/test_real_db_insert", testRealDbInsert);
    Test.add_func("/test_real_db_retrieve", testRealDbRetrieve);
    Test.add_func("/test_real_db_insert_retrieve", testRealDbInsertRetrieve);
    Test.add_func("/test_real_db_insert_sanitize_retrieve", testRealDbInsertSanitizeRetrieve);
    Test.run();
  }
}
