/*
 *    ContactListEntry.vala
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
  public interface IContactListEntry : GLib.Object {
    public abstract IContact get_contact();
  }

  [GtkTemplate(ui = "/chat/tox/venom/ui/contact_list_entry.ui")]
  public class ContactListEntry : Gtk.ListBoxRow, IContactListEntry {
    [GtkChild] private Gtk.Label contact_name;
    [GtkChild] private Gtk.Label contact_status;
    [GtkChild] private Gtk.Image contact_image;
    [GtkChild] private Gtk.Image status_image;

    private ILogger logger;
    private ContactListEntryViewModel view_model;
    private ContextStyleBinding attention_binding;

    public ContactListEntry(ILogger logger, IContact contact) {
      logger.d("ContactListEntry created.");
      this.logger = logger;
      this.view_model = new ContactListEntryViewModel(logger, contact);
      this.attention_binding = new ContextStyleBinding(status_image, "highlight");

      view_model.bind_property("contact-name", contact_name, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-status", contact_status, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-image", contact_image, "pixbuf", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-status-image", status_image, "icon-name", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-status-tooltip", status_image, "tooltip-text", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-requires-attention", attention_binding, "enable", GLib.BindingFlags.SYNC_CREATE);
    }

    public IContact get_contact() {
      return view_model.get_contact();
    }

    ~ContactListEntry() {
      logger.d("ContactListEntry destroyed.");
    }
  }
}
