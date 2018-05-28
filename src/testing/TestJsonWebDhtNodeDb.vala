/*
 *    TestJsonWebDhtNodeDb.vala
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

namespace TestJsonWebDhtNodeDb {
  private static ILogger logger;
  private static IDhtNodeFactory nodeFactory;

  private static void before() {
    logger = new MockLogger();
    nodeFactory = new MockDhtNodeFactory();
  }

  private static void testWebNodeDb() {
    before();
    var database = new JsonWebDhtNodeDatabase(logger);
    assert_nonnull(database);
  }

  private static void testWebNodeDbGet() {
    before();
    var database = new JsonWebDhtNodeDatabase(logger);
    assert_nonnull(database);
    var nodes = database.getDhtNodes(nodeFactory);
    assert(nodes.length() != 0);
  }

  private static int main(string[] args) {
    Test.init(ref args);

    if (!Test.slow()) {
      return 77;
    }

    Test.add_func("/test_web_node_db", testWebNodeDb);
    Test.add_func("/test_web_node_db_get", testWebNodeDbGet);
    Test.run();
    return 0;
  }
}
