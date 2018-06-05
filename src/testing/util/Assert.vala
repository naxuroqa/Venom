/*
 *    Assert.vala
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
  public errordomain AssertionError {
    FAILED
  }

  public class Assert {
    private Assert() {}

    public static void fail(string message = "") throws AssertionError {
      throw new AssertionError.FAILED(message);
    }

    public static void assert_true(bool condition) throws AssertionError {
      if (!condition) { fail("Condition != true"); }
    }

    public static void assert_false(bool condition) throws AssertionError {
      if (condition) { fail("Condition != false"); }
    }

    public static void assert_same(void* expected, void* actual) throws AssertionError {
      if (expected != actual) { fail("expected == actual"); }
    }

    public static void assert_not_same(void* unexpected, void* actual) throws AssertionError {
      if (unexpected == actual) { fail("unexpected != actual"); }
    }

    public static void assert_null(void* o) throws AssertionError {
      if (o != null) { fail("Object is not null"); }
    }

    public static void assert_not_null(void* o) throws AssertionError {
      if (o == null) { fail("Object is null"); }
    }

    public static void assert_array_equals(uint8[] expected, uint8[] actual) throws AssertionError {
      if (expected.length != actual.length || Memory.cmp(expected, actual, expected.length) != 0) {
        fail("expected != actual");
      }
    }

    public static void assert_equals<T>(T expected, T actual) throws AssertionError {
      var f = Gee.Functions.get_equal_func_for(typeof(T));
      if (!f(expected, actual)) { fail("expected != actual"); }
    }

    public static void assert_not_equals<T>(T unexpected, T actual) throws AssertionError {
      var f = Gee.Functions.get_equal_func_for(typeof(T));
      if (f(unexpected, actual)) { fail("expected == actual"); }
    }
  }
}
