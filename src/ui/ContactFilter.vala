/*
 *    Copyright (C) 2013 Venom authors and contributors
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
  interface ContactFilter : GLib.Object {
    public abstract bool filter_func(Gtk.TreeModel model, Gtk.TreeIter iter);
  }
  class ContactFilterAll : GLib.Object, ContactFilter {
    public bool filter_func(Gtk.TreeModel model, Gtk.TreeIter iter) {
      return true;
    }
  }
  class ContactFilterOnline : GLib.Object, ContactFilter {
    public bool filter_func(Gtk.TreeModel model, Gtk.TreeIter iter) {
      GLib.Value value_contact;
      model.get_value(iter, 0, out value_contact);
      Contact c = value_contact as Contact;
      if(c == null)
        return true;
      return c.online;
    }
  }
}
