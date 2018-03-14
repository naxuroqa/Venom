/*
 *    ContactListWidget.vala
 *
 *    Copyright (C) 2017-2018  Venom authors and contributors
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
  [GtkTemplate(ui = "/im/tox/venom/ui/contact_list_widget.ui")]
  public class ContactListWidget : Gtk.Box {
    private ILogger logger;
    private ContactListWidgetCallback callback;
    private UserInfo user_info;

    [GtkChild]
    private Gtk.Label username;
    [GtkChild]
    private Gtk.Label statusmessage;
    [GtkChild]
    private Gtk.Image userimage;
    [GtkChild]
    private Gtk.ListBox contact_list;
    [GtkChild]
    private Gtk.Image image_status;

    public ContactListWidget(ILogger logger, ObservableList<IContact> contacts, ContactListWidgetCallback callback, UserInfo user_info) {
      logger.d("ContactListWidget created.");
      this.logger = logger;
      this.callback = callback;
      this.user_info = user_info;

      refresh_user_info(this);
      user_info.info_changed.connect(refresh_user_info);

      contact_list.bind_model(new ObservableListModel<IContact>(contacts), create_entry);
      contact_list.row_activated.connect(on_row_activated);
    }

    private void refresh_user_info(GLib.Object sender) {
      username.label = user_info.get_name();
      statusmessage.label = user_info.get_status_message();
      var userimage_pixbuf = scalePixbuf(user_info.get_image());
      if (userimage_pixbuf != null) {
        userimage.set_from_pixbuf(userimage_pixbuf);
      }
      image_status.set_from_icon_name(get_resource_from_status(user_info.get_user_status()), Gtk.IconSize.INVALID);
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
      return pixbuf.scale_simple(44, 44, Gdk.InterpType.BILINEAR);
    }

    private Gtk.Widget create_entry(GLib.Object object) {
      var c = object as IContact;
      if (c is Contact || c is GroupchatContact) {
        return new ContactListEntry(logger, c);
      }
      return new ContactListRequestEntry(logger, c);
    }

    private void on_row_activated(Gtk.ListBoxRow row) {
      if (row is IContactListEntry) {
        var entry = row as IContactListEntry;
        callback.on_contact_selected(entry.get_contact());
      } else {
        logger.e("ContactListWidget wrong type selected.");
      }
    }

    ~ContactListWidget() {
      logger.d("ContactListWidget destroyed.");
    }
  }

  public interface ContactListWidgetCallback : GLib.Object {
    public abstract void on_contact_selected(IContact contact);
  }
}
