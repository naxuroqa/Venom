/*
 *    AddContactDialog.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
  public class AddContactDialog : Gtk.Dialog{
    public string contact_id {
      get { return entry_contact_id.get_text(); }
      set { entry_contact_id.set_text(value); }
    }
    public string contact_message {
      owned get { return textview_contact_message.buffer.text; }
      set { textview_contact_message.buffer.text = value; }
    }

    private Gtk.Entry entry_contact_id;
    private Gtk.TextView textview_contact_message;
    private GLib.Regex id_regex;

    public AddContactDialog() {
      init_widgets();
    }

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/add_contact_dialog.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading add contact window failed!\n");
      }

      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.get_content_area().add(box);

      entry_contact_id = builder.get_object("entry_contact_id") as Gtk.Entry;
      textview_contact_message = builder.get_object("textview_contact_message") as Gtk.TextView;

      entry_contact_id.changed.connect(on_entry_changed);
      on_entry_changed();

      try {
        id_regex = new GLib.Regex("^[[:xdigit:]]*$");
      } catch (RegexError re) {
        stderr.printf("Failed to compile regex: %s\n", re.message);
      }

      this.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Ok", Gtk.ResponseType.OK, null);
      this.set_default_response(Gtk.ResponseType.OK);
      this.title = "Add contact";
      this.set_default_size(400, 250);

      contact_message = ResourceFactory.instance.default_add_contact_message;
    }

    private void on_entry_changed() {
      if(contact_id == null || contact_id == "") {
        entry_contact_id.secondary_icon_tooltip_text = "No ID given";
        entry_contact_id.secondary_icon_name = "dialog-warning";
      } else if (contact_id.length != Tox.FRIEND_ADDRESS_SIZE*2) {
        entry_contact_id.secondary_icon_tooltip_text = "ID of invalid size";
        entry_contact_id.secondary_icon_name = "dialog-warning";
      } else if (id_regex != null && !id_regex.match(contact_id)) {
        entry_contact_id.secondary_icon_tooltip_text = "ID contains invalid characters";
        entry_contact_id.secondary_icon_name = "dialog-warning";
      } else {
        entry_contact_id.secondary_icon_pixbuf = null;
      }
    }
  }
}
