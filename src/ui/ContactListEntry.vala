/*
 *    ContactListEntry.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/contact_list_entry.ui")]
  public class ContactListEntry : Gtk.ListBoxRow {
    private ILogger logger;
    private IContact contact;

    [GtkChild]
    private Gtk.Label contact_name;
    [GtkChild]
    private Gtk.Label contact_status;
    [GtkChild]
    private Gtk.Image contact_image;
    [GtkChild]
    private Gtk.Image status_image;

    public ContactListEntry(ILogger logger, IContact contact) {
      logger.d("ContactListEntry created.");
      this.logger = logger;
      this.contact = contact;
      init_widgets();

      contact.changed.connect(init_widgets);
    }

    public IContact get_contact() {
      return contact;
    }

    private void init_widgets() {
      contact_name.label = contact.get_name_string();
      contact_status.label = contact.get_status_string();
      contact_image.pixbuf = contact.get_image();
      status_image.icon_name = icon_name_from_status(contact.get_status());
    }

    private string icon_name_from_status(UserStatus status) {
      switch (status) {
        case UserStatus.ONLINE:
          return R.icons.online;
        case UserStatus.AWAY:
          return R.icons.idle;
        case UserStatus.BUSY:
          return R.icons.busy;
        default:
          return R.icons.offline;
      }
    }

    public void on_contact_modified() {
      init_widgets();
    }

    // Destructor
    ~ContactListEntry() {
      logger.d("ContactListEntry destroyed.");
    }
  }
}
