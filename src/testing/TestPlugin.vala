/*
 *    TestPlugin.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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

using Mock;

namespace TestPlugin {
  private static void test_plugin() {
    var logger = new MockLogger();
    mock().expect_one_call(logger, "i");
    try {
      var test_plugin = new Venom.Pluginregistrar<Venom.Plugin>(logger, "/../src/testing/libexample_plugin");
      test_plugin.load();

      var plugin = test_plugin.new_object();
      plugin.activate(logger);
    } catch (Error e) {
      stdout.printf("Loading plugins failed: %s\n", e.message);
      Test.fail();
    }
    check_expectations_noerror();
  }
  private static void main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_plugin", test_plugin);
    Test.run();
  }
}
