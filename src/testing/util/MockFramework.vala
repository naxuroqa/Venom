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

  public static Arguments.Builder args() {
    return Arguments.builder();
  }

  public static string get_object_info(GLib.Object o) {
    if (o == null) {
      return "unknown";
    }
    return "%s".printf(o.get_type().name());
  }

  public class Arguments : GLib.Object {
    private GLib.List<GLib.Value?> arg_list;
    construct {
      arg_list = new GLib.List<GLib.Value?>();
    }

    public void add(GLib.Value v) {
      arg_list.append(v);
    }

    public uint length() {
      return arg_list.length();
    }

    private bool value_equals(GLib.Value v1, GLib.Value v2) {
      var t1 = v1.type();
      var t2 = v2.type();
      if (t1 != t2) {
        return false;
      }
      if (t1 == typeof(uint)) {
        return v1.get_uint() == v2.get_uint();
      } else if (t1 == typeof(int)) {
        return v1.get_int() == v2.get_int();
      } else if (t1 == typeof(uint64)) {
        return v1.get_uint64() == v2.get_uint64();
      } else if (t1 == typeof(int64)) {
        return v1.get_int64() == v2.get_int64();
      } else if (t1 == typeof(string)) {
        return v1.get_string() == v2.get_string();
      } else if (t1 == typeof(GLib.Object)) {
        return v1.get_object() == v2.get_object();
      } else if (t1 == typeof(bool)) {
        return v1.get_boolean() == v2.get_boolean();
      }
      return false;
    }

    public bool equals(Arguments args){
      if (arg_list.length() != args.arg_list.length()) {
        return false;
      }
      for (var i = 0; i < arg_list.length(); i++) {
        if (!value_equals(arg_list.nth_data(i), args.arg_list.nth_data(i))) {
          return false;
        }
      }
      return true;
    }

    const string uint64fmt = "%" + uint64.FORMAT_MODIFIER + "d";
    const string int64fmt = "%" + int64.FORMAT_MODIFIER + "d";

    public string to_string() {
      var ret = "";
      foreach (var v in arg_list) {
        var t = v.type();
        if (t == typeof(uint)) {
          ret += "   + (uint) %u\n".printf(v.get_uint());
        } else if (t == typeof(int)) {
          ret += "   + (int) %i\n".printf(v.get_int());
        } else if (t == typeof(uint64)) {
          ret += "   + (uint64) " + uint64fmt.printf(v.get_uint64()) + "\n";
        } else if (t == typeof(int64)) {
          ret += "   + (int64) " + int64fmt.printf(v.get_int64()) + "\n";
        } else if (t == typeof(string)) {
          ret += "   + (string) \"%s\"\n".printf(v.get_string());
        } else if (t == typeof(GLib.Object)) {
          ret += "   + (Object) %s\n".printf(get_object_info(v.get_object()));
        } else if (t == typeof(bool)) {
          ret += "   + (bool) %s\n".printf(v.get_boolean() ? "true" : "false");
        }
      }
      return ret;
    }

    public static Builder builder() {
      return new Builder();
    }

    public class Builder : GLib.Object {
      private Arguments args;
      construct {
        args = new Arguments();
      }
      public Builder bool(bool b) {
        var v = GLib.Value(typeof(bool));
        v.set_boolean(b);
        args.add(v);
        return this;
      }
      public Builder int(int i) {
        var v = GLib.Value(typeof(int));
        v.set_int(i);
        args.add(v);
        return this;
      }
      public Builder uint(uint i) {
        var v = GLib.Value(typeof(uint));
        v.set_uint(i);
        args.add(v);
        return this;
      }
      public Builder int64(int64 i) {
        var v = GLib.Value(typeof(int64));
        v.set_int64(i);
        args.add(v);
        return this;
      }
      public Builder uint64(uint64 i) {
        var v = GLib.Value(typeof(uint64));
        v.set_uint64(i);
        args.add(v);
        return this;
      }
      public Builder string(string s) {
        var v = GLib.Value(typeof(string));
        v.set_string(s);
        args.add(s);
        return this;
      }
      public Builder object(GLib.Object o) {
        var v = GLib.Value(typeof(GLib.Object));
        v.set_object(o);
        args.add(v);
        return this;
      }
      public Arguments create() {
        return args;
      }
    }
  }

  public interface Mock : GLib.Object {
    public abstract MockFunctionCall when(GLib.Object object, string function_name, Arguments args = new Arguments());
    public abstract void verify(GLib.Object object, string function_name, Arguments args = new Arguments()) throws MatcherError;
    public abstract void verify_count(GLib.Object object, string function_name, int count, Arguments args = new Arguments()) throws MatcherError;

    public abstract MockFunctionCall actual_call(GLib.Object object, string function_name, Arguments args = new Arguments());

    public abstract MockFunctionCall expect_one_call(GLib.Object object, string function_name, Arguments args = new Arguments());
    public abstract MockFunctionCall expect_calls(GLib.Object object, string function_name, int call_count, Arguments args = new Arguments());
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

    public abstract GLib.Object get_function_object();

    public abstract string get_function_name();
    public abstract Arguments get_args();

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

    public abstract string to_string_expected();
    public abstract string to_string_actual();
    public abstract bool equals(GLib.Object o, string function_name, Arguments args);
  }

  public class MockImpl : GLib.Object, Mock {
    private static Mock instance;

    public static Mock get_instance() {
      if (instance == null) {
        instance = new MockImpl();
      }
      return instance;
    }

    private GLib.List<MockFunctionCall> function_calls;

    public MockImpl() {
      function_calls = new GLib.List<MockFunctionCall>();
    }

    private MockFunctionCall init_func(GLib.Object o, string function_name, Arguments args) {
      foreach (var call in function_calls) {
        if (call.equals(o, function_name, args)) {
          return call;
        }
      }
      var call = new MockFunctionCallImpl(o, function_name, args);
      function_calls.prepend(call);
      return call;
    }

    public virtual MockFunctionCall actual_call(GLib.Object object, string function_name, Arguments args = new Arguments()) {
      return init_func(object, function_name, args).increment_call_count();
    }

    public virtual MockFunctionCall when(GLib.Object object, string function_name, Arguments args = new Arguments()) {
      return init_func(object, function_name, args);
    }

    public virtual void verify(GLib.Object object, string function_name, Arguments args = new Arguments()) throws MatcherError {
      verify_call(expect_one_call(object, function_name, args));
    }

    public virtual void verify_count(GLib.Object object, string function_name, int count, Arguments args = new Arguments()) throws MatcherError {
      verify_call_count(expect_calls(object, function_name, count, args), count);
    }

    public virtual MockFunctionCall expect_one_call(GLib.Object object, string function_name, Arguments args = new Arguments()) {
      return init_func(object, function_name, args).increment_expected_count();
    }

    public virtual MockFunctionCall expect_calls(GLib.Object object, string function_name, int call_count, Arguments args = new Arguments()) {
      var function_call = init_func(object, function_name, args);
      return function_call.set_expected_count(function_call.get_expected_count() + call_count);
    }

    private void print_call_info(MockFunctionCall call) {
      stderr.printf("# FOR OBJECT typeof %s\n", get_object_info(call.get_function_object()));
      stderr.printf("# EXPECTED calls:\n#  %s\n%s\n", call.to_string_expected(), call.get_args().to_string());
      stderr.printf("# ACTUAL calls:\n");
      foreach (var c in function_calls) {
        if (c.get_call_count() > 0 && c.get_function_object() == call.get_function_object()) {
          stderr.printf("#  %s\n%s",
                        c.to_string_actual(),
                        c.get_args().to_string());
        }
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
      // var keys = function_calls.get_keys();
      // var vals = function_calls.get_values();
      // for (var i = 0; i < keys.length(); i++) {
      //   verify_call(vals.nth_data(i));
      // }
      return this;
    }

    public virtual void verify_no_more_interactions(GLib.Object object) throws MatcherError {
      assert_not_reached();
    }

    public virtual void clear() {
      function_calls = new GLib.List<MockFunctionCall>();
    }
  }

  public class MockFunctionCallImpl : GLib.Object, MockFunctionCall {
    private GLib.Object object;
    private string name;
    private Arguments args;

    private int call_count;
    private int expected_count;
    private GLib.Value ? val;
    private GLib.Error ? error;

    public MockFunctionCallImpl(GLib.Object object, string name, Arguments args) {
      this.object = object;
      this.name = name;
      this.args = args;
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

    public virtual GLib.Object get_function_object() {
      return object;
    }

    public virtual string get_function_name() {
      return name;
    }

    public virtual Arguments get_args() {
      return args;
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

    public virtual Object ? get_object() throws GLib.Error {
      get_throws();
      return val != null ? val.get_object() : null;
    }

    public virtual void get_throws() throws GLib.Error {
      if (error != null) {
        throw error;
      }
    }

    public virtual string to_string_expected() {
      return "function(\"%s\") x%i".printf(name, expected_count);
    }

    public virtual string to_string_actual() {
      return "function(\"%s\") x%i".printf(name, call_count);
    }

    public virtual bool equals(GLib.Object o, string function_name, Arguments args) {
      return this.object == o && this.name == function_name && this.args.equals(args);
    }
  }
}
