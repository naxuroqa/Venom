/*
 *    ObservableList.vala
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

namespace Venom {
  public class ObservableList : GLib.Object {
    public signal void added(GLib.Object item, uint index);
    public signal void removed(GLib.Object item, uint index);

    private Gee.List<GLib.Object> list = new Gee.ArrayList<GLib.Object>();

    public void set_list(GLib.List<GLib.Object> list) {
      foreach (var item in list) {
        this.list.add(item);
      }
    }

    public void append(GLib.Object item) {
      var idx = list.size;
      list.add(item);
      added(item, idx);
    }

    public void remove(GLib.Object item) {
      var idx = list.index_of(item);
      removed(item, idx);
      list.remove_at(idx);
    }

    public uint length() {
      return list.size;
    }

    public uint index(GLib.Object item) {
      return (uint) list.index_of(item);
    }

    public GLib.Object nth_data(uint index) {
      return list.@get((int) index);
    }
  }

  public class ObservableListModel : GLib.Object, GLib.ListModel {
    private ObservableList list;
    public ObservableListModel(ObservableList list) {
      this.list = list;
      list.added.connect(on_added);
      list.removed.connect(on_removed);
    }

    private void on_added(GLib.Object item, uint index) {
      items_changed(index, 0, 1);
    }

    private void on_removed(GLib.Object item, uint index) {
      items_changed(index, 1, 0);
    }

    public virtual GLib.Object ? get_item(uint index) {
      return list.nth_data(index) as GLib.Object;
    }

    public virtual GLib.Type get_item_type() {
      return typeof (GLib.Object);
    }

    public virtual uint get_n_items() {
      return list.length();
    }

    public virtual GLib.Object ? get_object(uint index) {
      return get_item(index);
    }
  }

}
