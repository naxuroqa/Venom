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
    public abstract MockFunctionCall when(GLib.Object object, string function_name);
    public abstract void verify(GLib.Object object, string function_name) throws MatcherError;
    public abstract void verify_count(GLib.Object object, string function_name, int count) throws MatcherError;

    public abstract MockFunctionCall actual_call(GLib.Object? object, string function_name);
    public abstract MockFunctionCall expect_one_call(GLib.Object? object, string function_name);
    public abstract MockFunctionCall expect_calls(GLib.Object? object, string function_name, int call_count);
    public abstract void verify_no_more_interactions(GLib.Object object) throws MatcherError;

    public abstract Mock check_expectations() throws MatcherError;
    public abstract void clear();
  }

  public interface MockFunctionCall : GLib.Object {
    public abstract MockFunctionCall with_parameter(string parameter_name, GLib.Object parameter);
    public abstract MockFunctionCall with_int_parameter(string parameter_name, int parameter);

    public abstract MockFunctionCall increment_call_count();
    public abstract MockFunctionCall increment_expected_count();

    public abstract int get_call_count();
    public abstract int get_expected_count();

    public abstract MockFunctionCall set_call_count(int count);
    public abstract MockFunctionCall set_expected_count(int count);

    public abstract GLib.Object ? get_function_object();

    public abstract string get_function_name();

    public abstract void set_bool(bool value);
    public abstract void set_string(string value);
    public abstract void then_return_int(int value);
    public abstract void then_return_object(GLib.Object o);
    public abstract void then_throw(GLib.Error error);

    public abstract bool get_bool() throws GLib.Error;
    public abstract string get_string() throws GLib.Error;
    public abstract int get_int() throws GLib.Error;
    public abstract Object ? get_object() throws GLib.Error;

    public abstract void get_throws() throws GLib.Error;

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

    private GLib.HashTable<string, MockFunctionCall> function_calls;

    public MockImpl() {
      function_calls = new GLib.HashTable<string, MockFunctionCall>(str_hash, str_equal);
    }

    private MockFunctionCall init_func(GLib.Object? object, string function_name) {
      var function_call = function_calls.@get(function_name);
      if (function_call == null) {
        function_call = new MockFunctionCallImpl(object, function_name);
        function_calls.set(function_name, function_call);
      }
      return function_call;
    }

    public virtual MockFunctionCall actual_call(GLib.Object? object, string function_name) {
      return init_func(object, function_name).increment_call_count();
    }

    public virtual MockFunctionCall when(GLib.Object object, string function_name) {
      return init_func(object, function_name);
    }

    public virtual void verify(GLib.Object object, string function_name) throws MatcherError {
      verify_call(expect_one_call(object, function_name));
    }

    public virtual void verify_count(GLib.Object object, string function_name, int count) throws MatcherError {
      verify_call_count(init_func(object, function_name), count);
    }

    public virtual MockFunctionCall expect_one_call(GLib.Object? object, string function_name) {
      return init_func(object, function_name).increment_expected_count();
    }

    public virtual MockFunctionCall expect_calls(GLib.Object? object, string function_name, int call_count) {
      var function_call = init_func(object, function_name);
      return function_call.set_expected_count(function_call.get_expected_count() + call_count);
    }

    private string get_object_info(GLib.Object? o) {
      if (o == null) {
        return "unknown";
      }
      return "%s".printf(o.get_type().name());
    }

    private void print_call_info(MockFunctionCall call) {
      stderr.printf("# EXPECTED calls:\n#  %s\n   + typeof %s\n\n", call.to_string(), get_object_info(call.get_function_object()));
      stderr.printf("# ACTUAL calls:\n");
      function_calls.foreach ((key, val) => {
        stderr.printf("#  %s\n   + typeof %s\n", val.to_string(), get_object_info(val.get_function_object()));
      });
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

    private void verify_call(MockFunctionCall call) throws MatcherError {
      var count = call.get_expected_count();
      verify_call_count(call, count > 0 ? count : -1);
    }

    private void verify_call_count(MockFunctionCall call, int expected_count) throws MatcherError {
      if (expected_count == 0 && call.get_call_count() > 0) {
        print_expected_call_count_mismatch(call);
        throw new MatcherError.CALL_COUNT_MISMATCH("Call count mismatch");
      } else if (expected_count > 0 && call.get_call_count() == 0) {
        print_expected_call_missing(call);
        throw new MatcherError.CALL_COUNT_MISMATCH("Call missing");
      } else if (expected_count > call.get_call_count()) {
        print_expected_call_count_mismatch(call);
        throw new MatcherError.CALL_COUNT_MISMATCH("Call count mismatch");
      }
    }

    public virtual Mock check_expectations() throws MatcherError {
      var keys = function_calls.get_keys();
      var vals = function_calls.get_values();
      for (var i = 0; i < keys.length(); i++) {
        verify_call(vals.nth_data(i));
      }
      return this;
    }

    public virtual void verify_no_more_interactions(GLib.Object object) throws MatcherError {
      assert_not_reached();
    }

    public virtual void clear() {
      function_calls.remove_all();
    }
  }

  public class MockFunctionCallImpl : GLib.Object, MockFunctionCall {
    private string name;
    private int call_count;
    private int expected_count;
    private GLib.Object ? object;
    private GLib.Value ? val;
    private GLib.Error ? error;

    public MockFunctionCallImpl(GLib.Object? object, string name) {
      this.object = object;
      this.name = name;
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

    public virtual MockFunctionCall increment_expected_count() {
      expected_count++;
      return this;
    }

    public virtual int get_call_count() {
      return call_count;
    }

    public virtual int get_expected_count() {
      return expected_count;
    }

    public virtual MockFunctionCall set_call_count(int count) {
      call_count = count;
      return this;
    }

    public virtual MockFunctionCall set_expected_count(int count) {
      expected_count = count;
      return this;
    }

    public virtual GLib.Object ? get_function_object() {
      return object;
    }

    public virtual string get_function_name() {
      return name;
    }

    public virtual void set_bool(bool value) {
      val = Value(typeof(bool));
      val.set_boolean(value);
    }

    public virtual void set_string(string value) {
      val = Value(typeof(string));
      val.set_string(value);
    }

    public virtual void then_return_int(int value) {
      val = Value(typeof(int));
      val.set_int(value);
    }

    public virtual void then_return_object(GLib.Object value) {
      val = Value(typeof(GLib.Object));
      val.set_object(value);
    }

    public virtual void then_throw(GLib.Error error) {
      this.error = error;
    }

    public virtual bool get_bool() throws GLib.Error {
      get_throws();
      return val != null ? val.get_boolean() : false;
    }

    public virtual string get_string() throws GLib.Error {
      get_throws();
      return val != null ? val.get_string() : "";
    }

    public virtual int get_int() throws GLib.Error {
      get_throws();
      return val != null ? val.get_int() : 0;
    }

    public virtual Object? get_object() throws GLib.Error {
      get_throws();
      return val != null ? val.get_object() : null;
    }

    public virtual void get_throws() throws GLib.Error {
      if (error != null) {
        throw error;
      }
    }

    public virtual string to_string() {
      return "function(\"%s\") x%i".printf(name, call_count);
    }
  }
}
