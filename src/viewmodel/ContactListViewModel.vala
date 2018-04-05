/*
 *    ContactListViewModel.vala
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
  public class ContactListViewModel : GLib.Object {
    private ILogger logger;
    private ContactListWidgetCallback callback;
    private UserInfo user_info;
    private ObservableList contacts;

    public string username { get; set; }
    public string statusmessage { get; set; }
    public Gdk.Pixbuf userimage { get; set; }
    public string image_status { get; set; }

    public ContactListViewModel(ILogger logger, ObservableList contacts, ContactListWidgetCallback callback, UserInfo user_info) {
      logger.d("ContactListViewModel created.");
      this.logger = logger;
      this.callback = callback;
      this.user_info = user_info;
      this.contacts = contacts;

      refresh_user_info(this);
      user_info.info_changed.connect(refresh_user_info);
    }

    public ListModel get_list_model() {
      return new ObservableListModel(contacts);
    }

    public void on_row_activated(Gtk.ListBoxRow row) {
      if (row is IContactListEntry) {
        var entry = row as IContactListEntry;
        callback.on_contact_selected(entry.get_contact());
      } else {
        logger.e("ContactListViewModel wrong type selected.");
      }
    }

    private void refresh_user_info(GLib.Object sender) {
      username = user_info.get_name();
      statusmessage = user_info.get_status_message();
      var userimage_pixbuf = scalePixbuf(user_info.get_image());
      if (userimage_pixbuf != null) {
        userimage = userimage_pixbuf;
      }
      image_status = get_resource_from_status(user_info.get_user_status());
    }

    private string get_resource_from_status(UserStatus status) {
      switch (status) {
        case UserStatus.ONLINE:
          return R.icons.online;
        case UserStatus.AWAY:
          return R.icons.idle;
        case UserStatus.BUSY:
          return R.icons.busy;
      }
      return R.icons.offline;
    }

    private Gdk.Pixbuf ? scalePixbuf(Gdk.Pixbuf ? pixbuf) {
      if (pixbuf == null) {
        return null;
      }
      return pixbuf.scale_simple(48, 48, Gdk.InterpType.BILINEAR);
    }

    ~ContactListViewModel() {
      logger.d("ContactListViewModel destroyed.");
    }
  }

  public interface ContactListWidgetCallback : GLib.Object {
    public abstract void on_contact_selected(IContact contact);
  }
}
