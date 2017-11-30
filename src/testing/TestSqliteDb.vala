/*
 *    TestSqliteDb.vala
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

namespace TestSqliteDb {

  private static void testSqliteFactory() {
    var factory = new SqliteWrapperFactory();
    assert_nonnull(factory);
  }

  private static void testSqliteDatabaseWrapper() {
    var factory = new SqliteWrapperFactory();
    try {
      var database = factory.createDatabase(":memory:");
      assert_nonnull(database);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testSqliteStatementWrapper() {
    var factory = new SqliteWrapperFactory();
    try {
      var database = factory.createDatabase(":memory:");
      var stmtFactory = factory.createStatementFactory(database);
      var statement = stmtFactory.createStatement("");
      assert_nonnull(statement);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testSqliteFailRealDatabase() {
    var factory = new SqliteWrapperFactory();
    try {
      factory.createDatabase("file://invalid_path");
    } catch (Error e) {
      return;
    }
    Test.fail();
  }

  private static void testSqliteFailRealStatement() {
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

  private static void testSqliteRealStatement() {
    var factory = new SqliteWrapperFactory();
    try {
      var database = factory.createDatabase(":memory:");
      var stmtFactory = factory.createStatementFactory(database);
      var statement = stmtFactory.createStatement("ANALYZE sqlite_master");
      statement.step();
    } catch (Error e) {
      stdout.printf(e.message + "\n");
      Test.fail();
    }
  }

  private static void main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_sqlite_factory", testSqliteFactory);
    Test.add_func("/test_sqlite_database_wrapper", testSqliteDatabaseWrapper);
    Test.add_func("/test_sqlite_statement_wrapper", testSqliteStatementWrapper);
    Test.add_func("/test_sqlite_fail_real_database", testSqliteFailRealDatabase);
    Test.add_func("/test_sqlite_fail_real_statement", testSqliteFailRealStatement);
    Test.add_func("/test_sqlite_real_statement", testSqliteRealStatement);
    Test.run();
  }
}
