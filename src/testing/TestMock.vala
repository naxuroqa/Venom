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
    mock().expect_one_call(null, "a");
    mock().actual_call(null, "a");
    check_expectations_noerror();
  }

  private static void test_mock_empty() {
    check_expectations_noerror();
  }

  private static void test_mock_fail() {
    mock().expect_one_call(null, "a");
    try {
      mock().check_expectations();
    } catch (Error e) {
      mock().clear();
      return;
    }
    Test.fail();
  }

  private static void test_mock_calls() {
    mock().expect_calls(null, "b", 1);
    mock().actual_call(null, "b");
    check_expectations_noerror();
  }

  private static void test_mock_calls_multi() {
    mock().expect_calls(null, "c", 2);
    mock().actual_call(null, "c");
    mock().actual_call(null, "c");
    check_expectations_noerror();
  }

  private static void main(string[] args) {
    Test.init(ref args);

    Test.add_func("/test_mock", test_mock);
    Test.add_func("/test_mock_empty", test_mock_empty);
    Test.add_func("/test_mock_fail", test_mock_fail);
    Test.add_func("/test_mock_calls", test_mock_calls);
    Test.add_func("/test_mock_calls_multi", test_mock_calls_multi);
    Test.run();
  }
}
