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
  public class ContactListTreeView : Gtk.TreeView {
    Gtk.ListStore list_store_contacts;
    Gtk.TreeViewColumn name_column;

    public signal void contact_activated(Contact contact);

    public ContactListTreeView() {
      list_store_contacts = new Gtk.ListStore (3, typeof(Contact), typeof(GroupChat), typeof(string));

      name_column = new Gtk.TreeViewColumn();
      ContactListCellRenderer name_column_cell = new ContactListCellRenderer();
      name_column.pack_start(name_column_cell, true);
      
      name_column.add_attribute (name_column_cell, "contact", 0);
      name_column.add_attribute (name_column_cell, "groupchat", 1);

      set_model (list_store_contacts);

      append_column(name_column);

      row_activated.connect(on_row_activated);

      query_tooltip.connect(modify_tooltip);
      set_tooltip_column(2);

      //hide headers
      set_headers_visible(false);
    }

    private bool modify_tooltip(int x, int y, bool keyboard_tooltip, Gtk.Tooltip tooltip) {
      tooltip.set_icon_from_icon_name("gtk-info", Gtk.IconSize.LARGE_TOOLBAR);
      return false;
    }
    
    private Contact get_contact_from_iter(Gtk.TreeIter iter) {
      GLib.Value v;
      model.get_value(iter, 0, out v);
      return v as Contact;
    }

    public void add_contact(Contact contact) {
      Gtk.TreeIter iter;
      list_store_contacts.append (out iter);
      list_store_contacts.set (iter, 0, contact, 2, Tools.bin_to_hexstring(contact.public_key));
    }
    
    public void add_groupchat(GroupChat groupchat) {
      Gtk.TreeIter iter;
      list_store_contacts.append (out iter);
      list_store_contacts.set (iter, 1, groupchat);
    }

    public void update_contact(Contact contact) {
      Gtk.TreeIter? iter = find_iter(contact);
      list_store_contacts.row_changed(model.get_path(iter), iter);
    }

    public void remove_contact(Contact contact) {
      Gtk.TreeIter iter = find_iter(contact);
      list_store_contacts.remove(iter);
      columns_changed();
    }
    
    public Contact? get_selected_contact() {
      Gtk.TreeSelection selection =  get_selection();
      if(selection == null)
        return null;
      Gtk.TreeModel model;
      Gtk.TreeIter iter;
      if (!selection.get_selected(out model, out iter))
        return null;
      GLib.Value val;
      model.get_value(iter, 0, out val);
      Contact c = val as Contact;
      return c;
    }
    
    private void on_row_activated(Gtk.TreePath path, Gtk.TreeViewColumn column) {
      Gtk.TreeIter iter;
      model.get_iter(out iter, path);
      GLib.Value val;
      model.get_value(iter, 0, out val);
      Contact c = val as Contact;
      
      contact_activated(c);
    }
    
    private Gtk.TreeIter? find_iter(Contact contact) {
      Gtk.TreeIter iter;
      list_store_contacts.get_iter_first(out iter);
      do {
        if(get_contact_from_iter(iter) == contact)
          return iter;
      } while( list_store_contacts.iter_next(ref iter) );
      
      // not found
      return null;
    }
  }
}
