/*
 *    ContactListEntryViewModel.vala
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
  public class ContactListEntryViewModel : GLib.Object {
    private ILogger logger;
    private IContact contact;

    public string contact_name { get; set; }
    public string contact_status { get; set; }
    public Gdk.Pixbuf contact_image { get; set; }
    public string contact_status_image { get; set; }

    public ContactListEntryViewModel(ILogger logger, IContact contact) {
      logger.d("ContactListEntryViewModel created.");
      this.logger = logger;
      this.contact = contact;

      contact.changed.connect(update_contact);
      update_contact();
    }

    public IContact get_contact() {
      return contact;
    }

    private void update_contact() {
      contact_name = contact.get_name_string();
      contact_status = contact.get_status_string();
      var pixbuf = contact.get_image();
      if (pixbuf != null) {
        contact_image = pixbuf.scale_simple(44, 44, Gdk.InterpType.BILINEAR);
      }
      contact_status_image = icon_name_from_status(contact.get_status());
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

    ~ContactListEntryViewModel() {
      logger.d("ContactListEntryViewModel destroyed.");
    }
  }
}
