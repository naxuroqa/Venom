/*
 *    ContactListWidget.vala
 *
 *    Copyright (C) 2017-2019 Venom authors and contributors
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/contact_list_widget.ui")]
  public class ContactListWidget : Gtk.Box {
    private Logger logger;
    private ContactListViewModel view_model;

    [GtkChild] private Gtk.Box top_bar_box;
    [GtkChild] private Gtk.Label username;
    [GtkChild] private Gtk.Label statusmessage;
    [GtkChild] private Gtk.Image userimage;
    [GtkChild] private Gtk.Label menu_username;
    [GtkChild] private Gtk.Label menu_statusmessage;
    [GtkChild] private Gtk.Image menu_userimage;
    [GtkChild] private Gtk.ListBox contact_list;
    [GtkChild] private Gtk.Image image_status;
    [GtkChild] private Gtk.MenuButton user_status_menu;
    [GtkChild] private Gtk.Revealer friend_request_revealer;
    [GtkChild] private Gtk.Label friend_request_label;
    [GtkChild] private Gtk.Revealer conference_invite_revealer;
    [GtkChild] private Gtk.Label conference_invite_label;

    private unowned Gtk.ListBoxRow ? selected_row;
    private ListModel contact_list_model;

    public ContactListWidget(Logger logger, ApplicationWindow app_window, ObservableList contacts, ObservableList friend_requests, ObservableList conference_invites, ContactListWidgetCallback callback, UserInfo user_info, ISettingsDatabase settings_database, CallWidgetListener call_widget_listener) {
      logger.d("ContactListWidget created.");
      this.logger = logger;
      this.view_model = new ContactListViewModel(logger, contacts, friend_requests, conference_invites, callback, user_info, call_widget_listener);

      app_window.user_info_box.pack_start(top_bar_box, true, true);

      var builder = new Gtk.Builder.from_resource("/com/github/naxuroqa/venom/ui/user_status_menu.ui");
      var menu_model = builder.get_object("menu") as GLib.MenuModel;
      user_status_menu.set_menu_model(menu_model);

      view_model.bind_property("username", username, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", statusmessage, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("userimage", userimage, "pixbuf", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("username", menu_username, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", menu_statusmessage, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("userimage", menu_userimage, "pixbuf", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("image-status", image_status, "icon-name", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("friend-request-visible", friend_request_revealer, "reveal-child", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("friend-request-label", friend_request_label, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("conference-invite-visible", conference_invite_revealer, "reveal-child", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("conference-invite-label", conference_invite_label, "label", GLib.BindingFlags.SYNC_CREATE);

      contact_list.button_press_event.connect(on_button_pressed);
      contact_list.popup_menu.connect(on_popup_menu);
      contact_list.row_activated.connect(on_row_activated);

      settings_database.notify["enable-compact-contacts"].connect(refresh_contacts);

      var creator = new ContactListEntryCreator(logger, settings_database, call_widget_listener);
      contact_list_model = view_model.get_list_model();
      contact_list.bind_model(contact_list_model, creator.create_entry);
    }

    private void refresh_contacts() {
      var items = contact_list_model.get_n_items();
      contact_list_model.items_changed(0, items, items);
    }

    public unowned ContactListViewModel get_model() {
      return view_model;
    }

    private void on_row_activated(Gtk.ListBox listbox, Gtk.ListBoxRow? row) {
      logger.d("on_row_selected");
      selected_row = row;
      if (row == null) {
        view_model.on_contact_selected(null);
      } else {
        var contact = contact_list_model.get_object(row.get_index()) as IContact;
        view_model.on_contact_selected(contact);
      }
    }

    private bool on_popup_menu() {
      logger.d("on_popup_menu");
      if (selected_row == null) {
        return false;
      }

      var menu = view_model.popup_menu(null);
      var popover = new Gtk.Popover.from_model(selected_row, menu);
      popover.popup();
      return true;
    }

    private bool on_button_pressed(Gtk.Widget widget, Gdk.EventButton ev) {
      logger.d("on_button_pressed");
      if (ev.type == Gdk.EventType.BUTTON_PRESS && ev.button == 3) {
        logger.d("right mouse clicked");
        var row = contact_list.get_row_at_y((int) ev.y);
        if (row != null) {
          var contact = contact_list_model.get_object(row.get_index()) as IContact;
          var menu = view_model.popup_menu(contact);
          var popover = new Gtk.Popover.from_model(row, menu);
          popover.popup();
          return true;
        }
      }
      return false;
    }

    ~ContactListWidget() {
      logger.d("ContactListWidget destroyed.");
    }

    private class ContactListEntryCreator {
      private unowned Logger logger;
      private ISettingsDatabase settings_database;
      private CallWidgetListener call_widget_listener;
      public ContactListEntryCreator(Logger logger, ISettingsDatabase settings_database, CallWidgetListener call_widget_listener) {
        this.logger = logger;
        this.settings_database = settings_database;
        this.call_widget_listener = call_widget_listener;
      }

      public Gtk.Widget create_entry(GLib.Object object) {
        var contact = object as IContact;
        var call_state = call_widget_listener.get_call_state(contact);
        if (settings_database.enable_compact_contacts) {
          return new ContactListEntryCompact(logger, contact, call_state);
        } else {
          return new ContactListEntry(logger, contact, call_state);
        }
      }
    }
  }
}
