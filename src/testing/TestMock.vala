/*
 *    TestMock.vala
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

namespace TestMock {

  private static void test_mock() {
    var o = new GLib.Object();
    mock().actual_call(o, "a");
    mock().verify(o, "a");
    mock().clear();
  }

  private static void test_mock_empty() {
    // check_expectations_noerror();
  }

  private static void test_mock_fail() {
    var o = new GLib.Object();
    try {
      mock().verify(o, "");
      mock().clear();
    } catch (Error e) {
      return;
    }
    Test.fail();
  }

  private static void test_mock_calls() {
    var o = new GLib.Object();
    mock().actual_call(o, "b");
    mock().verify_count(o, "b", 1);
    mock().clear();
  }

  private static void test_mock_calls_multi() {
    var o = new GLib.Object();
    mock().actual_call(o, "c");
    mock().actual_call(o, "c");
    mock().verify_count(o, "c", 2);
    mock().clear();
  }

  private static void test_mock_calls_int_arg() {
    var o = new GLib.Object();
    mock().actual_call(o, "c", args().int(1).create());
    mock().verify(o, "c", args().int(1).create());
    mock().clear();
  }

  private static void test_mock_calls_int_arg_fail() {
    var o = new GLib.Object();
    try {
      mock().actual_call(o, "c", args().int(1).create());
      mock().verify(o, "c", args().int(2).create());
    } catch {
      mock().clear();
      return;
    }
    Test.fail();
  }

  private static void main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_mock", test_mock);
    Test.add_func("/test_mock_empty", test_mock_empty);
    Test.add_func("/test_mock_fail", test_mock_fail);
    Test.add_func("/test_mock_calls", test_mock_calls);
    Test.add_func("/test_mock_calls_multi", test_mock_calls_multi);
    Test.add_func("/test_mock_calls_int_arg", test_mock_calls_int_arg);
    Test.add_func("/test_mock_calls_int_arg_fail", test_mock_calls_int_arg_fail);
    Test.run();
  }
}
