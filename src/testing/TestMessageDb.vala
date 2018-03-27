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
using Testing;

public class TestMessageDb : UnitTest {
  private IDatabaseStatementBuilder builder;
  private IDatabaseStatement statement;
  private ILoggedMessageFactory messageFactory;
  private IDatabaseStatementFactory statementFactory;
  private ILogger logger;
  private ILoggedMessage message;

  public TestMessageDb() {
    add_func("test_init", test_init);
    add_func("test_insert", test_insert);
    add_func("test_retrieve", test_retrieve);
  }

  public override void set_up() throws Error {
    statement = new MockStatement();
    builder = new SqliteStatementWrapper.Builder(statement);
    mock().when(statement, "builder").then_return_object(builder);
    statementFactory = new MockStatementFactory();
    mock().when(statementFactory, "createStatement").then_return_object(statement);

    message = new MockLoggedMessage();
    messageFactory = new MockLoggedMessageFactory();
    mock().when(messageFactory, "createLoggedMessage").then_return_object(message);
    logger = new MockLogger();
  }

  private void test_init() throws Error {
    var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
    Assert.assert_not_null(messageDatabase);
  }

  private void test_insert() throws Error {
    var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
    Assert.assert_not_null(messageDatabase);
    messageDatabase.insertMessage("", "", "", new DateTime.now_local(), true);

    mock().verify_count(statement, "bind_text", 3);
    mock().verify(statement, "bind_int64");
    mock().verify(statement, "bind_bool");
  }

  private void test_retrieve() throws Error {
    var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
    Assert.assert_not_null(messageDatabase);
    var messages = messageDatabase.retrieveMessages("", "", messageFactory);
    Assert.assert_null(messages);
  }

  private static void main(string[] args) {
    Test.init(ref args);
    var test = new TestMessageDb();
    Test.run();
  }
}
