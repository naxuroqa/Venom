/*
 *    TestDhtNodeDb.vala
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

namespace TestDhtNodeDb {
  private static void testDhtNodeDb() {
    var logger = new MockLogger();
    var statementFactory = new MockStatementFactory();
    try {
      var database = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(database);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDb() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDbInsert() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
      nodeDatabase.insertDhtNode("", "", 0, false, "", "");
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDbSelect() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    var nodeFactory = new MockDhtNodeFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
      var nodes = nodeDatabase.getDhtNodes(nodeFactory);
      assert(nodes.length() == 0);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDbInsertSelect() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    var nodeFactory = new MockDhtNodeFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
      nodeDatabase.insertDhtNode("a", "b", 0, false, "c", "d");
      var nodes = nodeDatabase.getDhtNodes(nodeFactory);
      assert(nodes.length() == 1);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDbInsertSelectDuplicate() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    var nodeFactory = new MockDhtNodeFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
      nodeDatabase.insertDhtNode("a", "b", 0, false, "c", "d");
      nodeDatabase.insertDhtNode("a", "e", 0, false, "f", "g");
      var nodes = nodeDatabase.getDhtNodes(nodeFactory);
      assert(nodes.length() == 1);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDbDelete() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
      nodeDatabase.deleteDhtNode("a");
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void testRealDhtNodeDbInsertDeleteSelect() {
    var logger = new MockLogger();
    var factory = new SqliteWrapperFactory();
    var nodeFactory = new MockDhtNodeFactory();
    try {
      var db = factory.createDatabase(":memory:");
      var statementFactory = factory.createStatementFactory(db);
      var nodeDatabase = new SqliteDhtNodeDatabase(statementFactory, logger);
      assert_nonnull(nodeDatabase);
      nodeDatabase.insertDhtNode("a", "b", 0, false, "c", "d");
      nodeDatabase.deleteDhtNode("a");
      var nodes = nodeDatabase.getDhtNodes(nodeFactory);
      assert(nodes.length() == 0);
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  private static void main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_dht_node_db", testDhtNodeDb);
    Test.add_func("/test_real_dht_node_db", testRealDhtNodeDb);
    Test.add_func("/test_real_dht_node_db_insert", testRealDhtNodeDbInsert);
    Test.add_func("/test_real_dht_node_db_select", testRealDhtNodeDbSelect);
    Test.add_func("/test_real_dht_node_db_insert_select", testRealDhtNodeDbInsertSelect);
    Test.add_func("/test_real_dht_node_db_insert_select_duplicate", testRealDhtNodeDbInsertSelectDuplicate);
    Test.add_func("/test_real_dht_node_db_delete", testRealDhtNodeDbDelete);
    Test.add_func("/test_real_dht_node_db_insert_delete_select", testRealDhtNodeDbInsertDeleteSelect);
    Test.run();
  }
}
