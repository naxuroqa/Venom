/*
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
    public ContactListTreeView() {
        list_store_contacts = new Gtk.ListStore (1, typeof (Contact));
        
        Gtk.TreeViewColumn name_column = new Gtk.TreeViewColumn();
        name_column.set_title("Name");
        Gtk.CellRendererText name_column_cell = new Gtk.CellRendererText();
        name_column.pack_start(name_column_cell, true);

        name_column.set_cell_data_func(name_column_cell, render_contact_name);
        
        set_model (list_store_contacts);
        
        append_column(name_column);
    }
    
    private Contact get_contact_from_iter(Gtk.TreeIter iter) {
      GLib.Value v;
      model.get_value(iter, 0, out v);
      return v as Contact;
    }
    
    private void render_contact_name (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel tree_model, Gtk.TreeIter iter)
    {
      Contact c = get_contact_from_iter(iter);
      if(c.online)
        (cell as Gtk.CellRendererText).foreground = "black";
      else
        (cell as Gtk.CellRendererText).foreground = "gray";

      (cell as Gtk.CellRendererText).text = "%s (%s)".printf(c.name, c.status_message);
    }

    public void add_contact(Contact contact) {
      Gtk.TreeIter iter;
      list_store_contacts.append (out iter);
      list_store_contacts.set (iter, 0, contact);
    }

    public void update_contact(Contact contact) {
      //TODO
    }

    public void remove_contact(Contact contact) {
      Gtk.TreeIter iter = find_contact(contact);
      list_store_contacts.remove(iter);
      columns_changed();
    }

    private Gtk.TreeIter? find_contact(Contact contact) {
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
