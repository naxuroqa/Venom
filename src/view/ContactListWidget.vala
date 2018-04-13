/*
 *    ContactListWidget.vala
 *
 *    Copyright (C) 2017-2018 Venom authors and contributors
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
    private ContactListViewModel view_model;

    [GtkChild] private Gtk.Label username;
    [GtkChild] private Gtk.Label statusmessage;
    [GtkChild] private Gtk.Image userimage;
    [GtkChild] private Gtk.ListBox contact_list;
    [GtkChild] private Gtk.Image image_status;
    [GtkChild] private Gtk.MenuButton user_status_menu;

    public ContactListWidget(ILogger logger, ObservableList contacts, ContactListWidgetCallback callback, UserInfo user_info) {
      logger.d("ContactListWidget created.");
      this.logger = logger;
      this.callback = callback;
      this.user_info = user_info;
      this.view_model = new ContactListViewModel(logger, contacts, callback, user_info);

      try {
        var builder = new Gtk.Builder.from_resource("/im/tox/venom/ui/user_status_menu.ui");
        var menu_model = builder.get_object("menu") as GLib.MenuModel;
        user_status_menu.set_menu_model(menu_model);

      } catch (Error e) {
        logger.f("Loading user status menu failed: " + e.message);
        assert_not_reached();
      }

      user_status_menu.set_image(image_status);

      view_model.bind_property("username", username, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", statusmessage, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("userimage", userimage, "pixbuf", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("image-status", image_status, "icon-name", GLib.BindingFlags.SYNC_CREATE);

      contact_list.bind_model(view_model.get_list_model(), create_entry);
      contact_list.row_activated.connect(view_model.on_row_activated);
    }

    private Gtk.Widget create_entry(GLib.Object object) {
      var c = object as IContact;
      if (c is Contact || c is Conference) {
        return new ContactListEntry(logger, c);
      }
      return new ContactListRequestEntry(logger, c);
    }

    ~ContactListWidget() {
      logger.d("ContactListWidget destroyed.");
    }
  }
}
