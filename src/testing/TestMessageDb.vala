/*
 *    TestMessageDb.vala
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
    when(statement, "builder")
        .then_return_object(builder);

    statementFactory = new MockStatementFactory();
    when(statementFactory, "create_statement", args().string("", any_string()).create())
        .then_return_object(statement);

    message = new MockLoggedMessage();
    messageFactory = new MockLoggedMessageFactory();
    when(messageFactory, "createLoggedMessage")
        .then_return_object(message);

    logger = new MockLogger();
  }

  private void test_init() throws Error {
    var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
    Assert.assert_not_null(messageDatabase);
  }

  private void test_insert() throws Error {
    var messageDatabase = new SqliteMessageDatabase(statementFactory, logger);
    Assert.assert_not_null(messageDatabase);
    var time = new DateTime.now_local();
    messageDatabase.insertMessage("a", "b", "c", time, true);

    mock().verify(statement, "bind_text", args().string("$USER").string("a").create());
    mock().verify(statement, "bind_text", args().string("$CONTACT").string("b").create());
    mock().verify(statement, "bind_text", args().string("$MESSAGE").string("c").create());
    mock().verify(statement, "bind_int64", args().string("$TIME").int64(time.to_unix()).create());
    mock().verify(statement, "bind_bool", args().string("$SENDER").bool(true).create());
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
