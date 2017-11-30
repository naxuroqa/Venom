/*
 *    MockFramework.vala
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

namespace Mock {
  public errordomain MatcherError {
    CALL_COUNT_MISMATCH,
    OBJECT_MISMATCH
  }

  public static Mock mock() {
    return MockImpl.get_instance();
  }

  public static void check_expectations_noerror() {
    try {
      mock().check_expectations();
    } catch (Error e) {
      stderr.printf(e.message);
      Test.fail();
    }
  }

  public interface Mock : GLib.Object {
    public abstract MockFunctionCall actual_call(GLib.Object? object, string function_name);
    public abstract MockFunctionCall expect_one_call(GLib.Object? object, string function_name);
    public abstract MockFunctionCall expect_calls(GLib.Object? object, string function_name, int call_count);

    public abstract Mock check_expectations() throws MatcherError;
    public abstract void clear();
  }

  public interface MockFunctionCall : GLib.Object {
    public abstract MockFunctionCall with_parameter(string parameter_name, GLib.Object parameter);
    public abstract MockFunctionCall with_int_parameter(string parameter_name, int parameter);

    public abstract MockFunctionCall increment_call_count();
    public abstract int get_call_count();
    public abstract void set_call_count(int count);
    public abstract GLib.Object ? get_object();
    public abstract string get_function_name();

    public abstract string to_string();
  }

  public class MockImpl : GLib.Object, Mock {
    private static Mock instance;

    public static Mock get_instance() {
      if (instance == null) {
        instance = new MockImpl();
      }
      return instance;
    }

    private GLib.HashTable<string, MockFunctionCall> expected_function_calls;
    private GLib.HashTable<string, MockFunctionCall> actual_function_calls;

    public MockImpl() {
      expected_function_calls = new GLib.HashTable<string, MockFunctionCall>(str_hash, str_equal);
      actual_function_calls = new GLib.HashTable<string, MockFunctionCall>(str_hash, str_equal);
    }

    public virtual MockFunctionCall actual_call(GLib.Object? object, string function_name) {
      var function_call = actual_function_calls.@get(function_name);
      if (function_call == null) {
        function_call = new MockFunctionCallImpl(function_name);
        actual_function_calls.set(function_name, function_call);
      } else {
        function_call.increment_call_count();
      }
      return function_call;
    }

    public virtual MockFunctionCall expect_one_call(GLib.Object? object, string function_name) {
      return expect_calls(object, function_name, 1);
    }

    public virtual MockFunctionCall expect_calls(GLib.Object? object, string function_name, int call_count) {
      var function_call = expected_function_calls.@get(function_name);
      if (function_call == null) {
        function_call = new MockFunctionCallImpl(function_name);
        function_call.set_call_count(call_count);
        expected_function_calls.set(function_name, function_call);
      } else {
        function_call.set_call_count(function_call.get_call_count() + call_count);
      }
      return function_call;
    }

    private void print_call_info(MockFunctionCall call) {
      stderr.printf("# EXPECTED call:\n#  %s\n".printf(call.to_string()));
      stderr.printf("# ACTUAL calls:\n");
      if (actual_function_calls.size() <= 0) {
        stderr.printf("# No calls happened\n");
      } else {
        actual_function_calls.foreach ((key, val) => {
          stderr.printf("#  %s\n".printf(val.to_string()));
        });
      }
      stderr.printf("###\n");
    }

    private void print_expected_call_count_mismatch(MockFunctionCall call) {
      stderr.printf("### Expected call count mismatch: ###\n");
      print_call_info(call);
    }

    private void print_expected_object_mismatch(MockFunctionCall call) {
      stderr.printf("### Expected object mismatch: ###\n");
      print_call_info(call);
    }

    private void print_expected_call_missing(MockFunctionCall call) {
      stderr.printf("### Expected call missing: ###\n");
      print_call_info(call);
    }

    public virtual Mock check_expectations() throws MatcherError {
      var keys = expected_function_calls.get_keys();
      var vals = expected_function_calls.get_values();
      for (var i = 0; i < keys.length(); i++) {
        var key = keys.nth_data(i);
        var val = vals.nth_data(i);
        var actual_call = actual_function_calls.@get(key);
        if (actual_call == null) {
          print_expected_call_missing(val);
          throw new MatcherError.CALL_COUNT_MISMATCH("Call missing");
        } else if (actual_call.get_call_count() != val.get_call_count()) {
          print_expected_call_count_mismatch(val);
          throw new MatcherError.CALL_COUNT_MISMATCH("Call count mismatch");
        } else if (actual_call.get_object() != val.get_object()) {
          print_expected_object_mismatch(val);
          throw new MatcherError.CALL_COUNT_MISMATCH("Object mismatch");
        }
      }
      clear();
      return this;
    }

    public virtual void clear() {
      expected_function_calls.remove_all();
      actual_function_calls.remove_all();
    }
  }

  public class MockFunctionCallImpl : GLib.Object, MockFunctionCall {
    private string name;
    private int call_count;
    private GLib.Object ? object;

    public MockFunctionCallImpl(string name) {
      this.name = name;

      call_count = 1;
      object = null;
    }

    public virtual MockFunctionCall on_object(GLib.Object object) {
      this.object = object;
      return this;
    }

    public virtual MockFunctionCall with_parameter(string parameter_name, GLib.Object parameter) {
      return this;
    }

    public virtual MockFunctionCall with_int_parameter(string parameter_name, int parameter) {
      return this;
    }

    public virtual MockFunctionCall increment_call_count() {
      call_count++;
      return this;
    }

    public virtual int get_call_count() {
      return call_count;
    }

    public virtual void set_call_count(int count) {
      call_count = count;
    }

    public virtual GLib.Object ? get_object() {
      return object;
    }

    public virtual string get_function_name() {
      return name;
    }

    public virtual string to_string() {
      return "function(\"%s\") x%i".printf(name, call_count);
    }
  }
}
