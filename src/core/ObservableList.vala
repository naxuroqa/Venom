/*
 *    ObservableList.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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

namespace Venom {
  public class ObservableList<T> : GLib.Object {
    public signal void added(T item, uint index);
    public signal void removed(T item, uint index);

    private GLib.List<T> list;
    public ObservableList() {
    }

    public void set_list(owned GLib.List<T> list) {
      this.list = (owned) list;
    }

    public void append(T item) {
      var idx = list.length();
      list.append(item);
      added(item, idx);
    }

    public void remove(T item) {
      var idx = list.index(item);
      list.remove(item);
      removed(item, idx);
    }

    public uint length() {
      return list.length();
    }

    public uint index(T item) {
      return list.index(item);
    }
    public T nth_data(uint index) {
      return list.nth_data(index);
    }
  }

  public class ObservableListModel<T> : GLib.Object, GLib.ListModel {
    private unowned ObservableList<T> list;
    public ObservableListModel(ObservableList<T> list) {
      this.list = list;
      list.added.connect(on_added);
      list.removed.connect(on_removed);
    }

    private void on_added(T item, uint index) {
      items_changed(index, 0, 1);
    }

    private void on_removed(T item, uint index) {
      items_changed(index, 1, 0);
    }

    public virtual GLib.Object ? get_item(uint index) {
      return list.nth_data(index) as GLib.Object;
    }

    public virtual GLib.Type get_item_type() {
      return typeof (T);
    }

    public virtual uint get_n_items() {
      return list.length();
    }

    public virtual GLib.Object ? get_object(uint index) {
      return get_item(index);
    }
  }

}
