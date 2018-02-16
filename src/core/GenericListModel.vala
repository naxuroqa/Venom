/*
 *    GenericListModel.vala
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
  public class GenericListModel<T> : GLib.Object, GLib.ListModel {
    public unowned GLib.List<T> list;
    public GenericListModel(GLib.List<T> list) {
      this.list = list;
    }

    public virtual GLib.Object ? get_item(uint position) {
      return list.nth_data(position) as GLib.Object;
    }

    public virtual GLib.Type get_item_type() {
      return typeof (T);
    }

    public virtual uint get_n_items() {
      return list.length();
    }

    public virtual GLib.Object ? get_object(uint position) {
      return get_item(position);
    }
  }
}
