/*
 *    TestSqliteDb.vala
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

public class TestSqliteDb : UnitTest {
  public TestSqliteDb() {
    add_func("/test_sqlite_factory", test_sqlite_factory);
    add_func("/test_sqlite_database_wrapper", test_sqlite_database_wrapper);
    add_func("/test_sqlite_statement_wrapper", test_sqlite_statement_wrapper);
    add_func("/test_sqlite_fail_real_database", test_sqlite_fail_real_database);
    add_func("/test_sqlite_fail_real_statement", test_sqlite_fail_real_statement);
    add_func("/test_sqlite_real_statement", test_sqlite_real_statement);
  }

  private void test_sqlite_factory() throws Error {
    var factory = new SqliteWrapperFactory();
    Assert.assert_not_null(factory);
  }

  private void test_sqlite_database_wrapper() throws Error {
    var factory = new SqliteWrapperFactory();
    var database = factory.createDatabase(":memory:");
    Assert.assert_not_null(database);
  }

  private void test_sqlite_statement_wrapper() throws Error {
    var factory = new SqliteWrapperFactory();
    var database = factory.createDatabase(":memory:");
    var stmtFactory = factory.createStatementFactory(database);
    var statement = stmtFactory.createStatement("");
    Assert.assert_not_null(statement);
  }

  private void test_sqlite_fail_real_database() throws Error {
    var factory = new SqliteWrapperFactory();
    try {
      factory.createDatabase("file://invalid_path");
    } catch (Error e) {
      return;
    }
    Test.fail();
  }

  private void test_sqlite_fail_real_statement() throws Error {
    var factory = new SqliteWrapperFactory();
    try {
      var database = factory.createDatabase(":memory:");
      var stmtFactory = factory.createStatementFactory(database);
      var statement = stmtFactory.createStatement("");
      statement.step();
    } catch (Error e) {
      return;
    }
    Test.fail();
  }

  private void test_sqlite_real_statement() throws Error {
    var factory = new SqliteWrapperFactory();
    var database = factory.createDatabase(":memory:");
    var stmtFactory = factory.createStatementFactory(database);
    var statement = stmtFactory.createStatement("ANALYZE sqlite_master");
    statement.step();
  }

  private static void main(string[] args) {
    Test.init(ref args);
    var test = new TestSqliteDb();
    Test.run();
  }
}
