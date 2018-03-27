/*
 *    UnitTest.vala
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

namespace Testing {
  public class UnitTest : GLib.Object {
    public delegate void TestFunction() throws Error;
    public void add_func(string name, TestFunction f) {
      Test.add_data_func("/" + name, () => {
        run_testcase(f);
      });
    }

    public void run() {
      Test.run();
    }

    private void run_testcase(TestFunction f) {
      pre_set_up();
      try {
        set_up();
        try {
          f();
        } catch (Error e) {
          stderr.printf("# Testcase failed: %s\n", e.message);
          Test.fail();
        }
        tear_down();
      } catch (Error e) {
        stderr.printf("# Error during test set_up/tear_down: %s\n", e.message);
        Test.fail();
      }
      post_tear_down();
    }

    private void pre_set_up() {
      Mock.mock().clear();
    }

    public virtual void set_up() throws Error {}
    public virtual void tear_down() throws Error {}

    private void post_tear_down() {
      Mock.mock().clear();
    }
  }
}
