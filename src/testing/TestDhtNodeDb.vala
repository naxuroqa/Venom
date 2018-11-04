/*
 *    TestDhtNodeDb.vala
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

public class TestDhtNodeDb : UnitTest {
  // private Logger logger;
  // private DatabaseStatementFactory statement_factory;
  // private DatabaseStatement statement;
  // private DatabaseStatementBuilder builder;
  //
  // public TestDhtNodeDb() {
  //   add_func("test_init", test_init);
  //   add_func("test_real_dht_node_db", test_real_dht_node_db);
  //   add_func("test_insert", test_insert);
  //   add_func("test_select", test_select);
  //   add_func("test_real_dht_node_db_insert_select", test_real_dht_node_db_insert_select);
  //   add_func("test_real_dht_node_db_insert_select_duplicate", test_real_dht_node_db_insert_select_duplicate);
  //   add_func("test_real_dht_node_db_delete", test_real_dht_node_db_delete);
  //   add_func("test_real_dht_node_db_insert_delete_select", test_real_dht_node_db_insert_delete_select);
  // }
  // 
  // public override void set_up() throws GLib.Error {
  //   logger = new MockCommandLineLogger();
  //   statement = new MockStatement();
  //   builder = new SqliteStatementWrapper.Builder(statement);
  //   statement_factory = new MockStatementFactory();
  //
  //   mock().when(statement, "builder").then_return_object(builder);
  //   mock().when(statement_factory, "create_statement", args().string("", any_string()).create())
  //       .then_return_object(statement);
  // }
  //
  // private void test_init() throws GLib.Error {
  //   var database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(database);
  // }
  //
  // private void test_real_dht_node_db() throws GLib.Error {
  //   var factory = new SqliteWrapperFactory();
  //   var db = factory.create_database(":memory:");
  //   var statement_factory = factory.create_statement_factory(db);
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  // }
  //
  // private void test_insert() throws GLib.Error {
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  //   node_database.insertDhtNode("a", "b", 0, false, "c", "d");
  //
  //   mock().verify(statement, "bind_text", args().string("$KEY").string("a").create());
  //   mock().verify(statement, "bind_text", args().string("$ADDRESS").string("b").create());
  //   mock().verify(statement, "bind_text", args().string("$OWNER").string("c").create());
  //   mock().verify(statement, "bind_text", args().string("$LOCATION").string("d").create());
  //   mock().verify(statement, "bind_int", args().string("$PORT").int(0).create());
  //   mock().verify(statement, "bind_bool", args().string("$ISBLOCKED").bool(false).create());
  //   mock().verify_count(statement, "step", 2);
  // }
  //
  // private void test_select() throws GLib.Error {
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  //
  //   var nodes = node_database.getDhtNodes(node_factory);
  //   Assert.assert_equals<uint>(0, nodes.length());
  // }
  //
  // private void test_real_dht_node_db_insert_select() throws GLib.Error {
  //   var statement_factory = create_memory_stmt_factory();
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  //
  //   node_database.insertDhtNode("a", "b", 0, false, "c", "d");
  //   var nodes = node_database.getDhtNodes(node_factory);
  //   Assert.assert_equals<uint>(1, nodes.length());
  // }
  //
  // private void test_real_dht_node_db_insert_select_duplicate() throws GLib.Error {
  //   var statement_factory = create_memory_stmt_factory();
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  //
  //   node_database.insertDhtNode("a", "b", 0, false, "c", "d");
  //   node_database.insertDhtNode("a", "e", 0, false, "f", "g");
  //   var nodes = node_database.getDhtNodes(node_factory);
  //   Assert.assert_equals<uint>(1, nodes.length());
  // }
  //
  // private void test_real_dht_node_db_delete() throws GLib.Error {
  //   var statement_factory = create_memory_stmt_factory();
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  //
  //   node_database.deleteDhtNode("a");
  // }
  //
  // private void test_real_dht_node_db_insert_delete_select() throws GLib.Error {
  //   var statement_factory = create_memory_stmt_factory();
  //   var node_database = new SqliteDhtNodeRepository(statement_factory, logger);
  //   Assert.assert_not_null(node_database);
  //
  //   node_database.insertDhtNode("a", "b", 0, false, "c", "d");
  //   node_database.deleteDhtNode("a");
  //   var nodes = node_database.getDhtNodes(node_factory);
  //   Assert.assert_equals<uint>(0, nodes.length());
  // }
  //
  // private DatabaseStatementFactory create_memory_stmt_factory() {
  //   var factory = new SqliteWrapperFactory();
  //   var db = factory.create_database(":memory:");
  //   return factory.create_statement_factory(db);
  // }

  private static void main(string[] args) {
    Test.init(ref args);
    var test = new TestDhtNodeDb();
    Test.run();
  }
}
