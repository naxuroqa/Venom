/*
 *    TestObservableList.vala
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

namespace TestGenerics {
  private class SimpleObject : GLib.Object {
    public static int count = 0;

    public SimpleObject() {
      stdout.printf("SimpleObject\n");
      count++;
    }

    ~SimpleObject() {
      stdout.printf("~SimpleObject\n");
      count--;
    }
  }

  private class Container : GLib.Object {
    private GLib.List<SimpleObject> list;
    construct {
      list = new GLib.List<SimpleObject>();
    }

    public void add(SimpleObject item) {
      list.append(item);
    }
  }

  private class GenericContainer<G> : GLib.Object {
    private Gee.List<G> list;
    construct {
      list = new Gee.ArrayList<G>();
    }

    public void add(G item) {
      if (typeof(G).is_object()) {
        var o = ((GLib.Object)item);
        o.ref();
        o.ref();
      }
      list.add(item);
    }

    public void add_list(GLib.List<G> list) {
      foreach (var item in list) {
        this.list.add(item);
        if (typeof(G).is_object()) {
          var o = ((GLib.Object)item);
          o.ref();
          o.ref();
        }
      }
    }

    ~GenericContainer() {
      // Vala generics bug
      if (typeof(G).is_object()) {
        foreach (var o in list) {
          ((GLib.Object)o).unref();
        }
      }
    }
  }

  private static void test_container() {
    assert(SimpleObject.count == 0);
    {
      var list = new Container();
      list.add(new SimpleObject());
      assert(SimpleObject.count == 1);
    }
    assert(SimpleObject.count == 0);
  }

  private static void test_generic_container() {
    assert(SimpleObject.count == 0);
    {
      var list = new GenericContainer<SimpleObject>();
      list.add(new SimpleObject());
      assert(SimpleObject.count == 1);
    }
    assert(SimpleObject.count == 0);
  }

  private static void test_generic_container_list_add() {
    assert(SimpleObject.count == 0);
    {
      var container = new GenericContainer<SimpleObject>();
      {
        var list = new GLib.List<SimpleObject>();
        list.append(new SimpleObject());
        container.add_list(list);
        assert(SimpleObject.count == 1);
      }
      assert(SimpleObject.count == 1);
    }
    assert(SimpleObject.count == 0);
  }

  private static int main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_container", test_container);
    Test.add_func("/test_generic_container", test_generic_container);
    Test.add_func("/test_generic_container_list_add", test_generic_container_list_add);
    Test.run();
    return 0;
  }
}
