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

    public ContactListWidget(ILogger logger, Contacts contacts, ContactListWidgetCallback callback, UserInfo user_info) {
      logger.d("ContactListWidget created.");
      this.logger = logger;
      this.callback = callback;
      this.user_info = user_info;

      refresh_user_info(this);
      user_info.info_changed.connect(refresh_user_info);

      contact_list.bind_model(new ContactListModel(contacts), create_entry);
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
      return new ContactListEntry(logger, object as IContact);
    }

    private void on_row_activated(Gtk.ListBoxRow row) {
      if (row is ContactListEntry) {
        var entry = row as ContactListEntry;
        callback.on_contact_selected(entry.get_contact());
      } else {
        logger.e("ContactListWidget wrong type selected.");
      }
    }

    // Destructor
    ~ContactListWidget() {
      logger.d("ContactListWidget destroyed.");
    }
  }

  public class ContactListModel : GLib.Object, GLib.ListModel {
    private Contacts contacts;

    public ContactListModel(Contacts contacts) {
      this.contacts = contacts;
      contacts.contact_added.connect(on_contact_added);
      contacts.contact_removed.connect(on_contact_removed);
      contacts.contact_changed.connect(on_contact_changed);
    }

    private void on_contact_added(GLib.Object sender, uint index) {
      items_changed(index, 0, 1);
    }

    private void on_contact_removed(GLib.Object sender, uint index) {
      items_changed(index, 1, 0);
    }

    private void on_contact_changed(GLib.Object sender, uint index) {
      items_changed(index, 1, 1);
    }

    public virtual GLib.Object ? get_item(uint position) {
      return contacts.get_item(position);
    }

    public virtual GLib.Type get_item_type() {
      return typeof (IContact);
    }

    public virtual uint get_n_items() {
      return contacts.length();
    }

    public virtual GLib.Object ? get_object(uint position) {
      return get_item(position);
    }
  }

  public interface ContactListWidgetCallback : GLib.Object {
    public abstract void on_contact_selected(IContact contact);
  }
}
