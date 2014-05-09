/*
 *    Copyright (C) 2013-2014 Venom authors and contributors
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
  public class ContactListTreeView : Gtk.TreeView {
    Gtk.ListStore list_store_contacts;
    Gtk.TreeViewColumn name_column;

    public signal void entry_activated(IContact c);

    public ContactListTreeView() {
      list_store_contacts = new Gtk.ListStore (1, typeof(IContact));

      name_column = new Gtk.TreeViewColumn();
      ContactListCellRenderer name_column_cell = new ContactListCellRenderer();
      name_column.pack_start(name_column_cell, true);

      name_column.add_attribute (name_column_cell, "entry", 0);

      set_model (list_store_contacts);

      append_column(name_column);

      Gtk.TreeSelection s = get_selection();
      s.set_mode(Gtk.SelectionMode.SINGLE);
      s.set_select_function(on_row_selected);
      
      query_tooltip.connect_after(modify_tooltip);
      has_tooltip = true;

      //hide headers
      set_headers_visible(false);
      can_focus = false;
    }
    private bool on_row_selected( Gtk.TreeSelection selection, Gtk.TreeModel model, Gtk.TreePath path, bool path_currently_selected ) {
      Gtk.TreeIter iter;
      model.get_iter(out iter, path);
      GLib.Value val;
      model.get_value(iter, 0, out val);
      entry_activated(val as IContact);
      return true;
    }

    private bool modify_tooltip(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip) {
      Gtk.TreeModel model;
      Gtk.TreePath path;
      Gtk.TreeIter iter;
      if(!get_tooltip_context(ref x, ref y, keyboard_tooltip, out model, out path, out iter))
        return false;
      if(model == null)
        return false;
      GLib.Value v;
      model.get_value(iter, 0, out v);
      GLib.Object o = v as Object;
      if(o is IContact) {
        IContact c = o as IContact;
        tooltip.set_markup(c.get_tooltip_string());
      } else {
        return false;
      }
      set_tooltip_row(tooltip, path);
      return true;
    }

    public void add_entry(IContact c) {
      Gtk.TreeIter iter;
      list_store_contacts.append(out iter);
      list_store_contacts.set(iter, 0, c);
      can_focus = true;
    }

    public void update_entry(IContact c) {
      Gtk.TreeIter? iter = find_iter(c);
      list_store_contacts.row_changed(list_store_contacts.get_path(iter), iter);
    }

    public void remove_entry(IContact c) {
      Gtk.TreeIter iter = find_iter(c);
      list_store_contacts.remove(iter);
      columns_changed();
      if(list_store_contacts.iter_n_children(null) == 0)
        can_focus = false;
    }

    public IContact? get_selected_entry() {
      Gtk.TreeSelection selection = get_selection();
      if(selection == null)
        return null;
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      if (!selection.get_selected(out model, out iter))
        return null;
      GLib.Value val;
      model.get_value(iter, 0, out val);
      return val as IContact;
    }

    private Gtk.TreeIter? find_iter(IContact c) {
      Gtk.TreeIter iter;
      list_store_contacts.get_iter_first(out iter);
      do {
        GLib.Value val;
        list_store_contacts.get_value(iter, 0, out val);
        if(val.get_object() == c)
          return iter;
      } while( list_store_contacts.iter_next(ref iter) );

      // not found
      return null;
    }
  }
}
