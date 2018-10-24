/*
 *    FriendInfoWidget.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/friend_info_widget.ui")]
  public class FriendInfoWidget : Gtk.Box {
    [GtkChild] private Gtk.Label username;
    [GtkChild] private Gtk.Label statusmessage;
    [GtkChild] private Gtk.Image userimage;
    [GtkChild] private Gtk.Label last_seen;
    [GtkChild] private Gtk.Entry alias;
    [GtkChild] private Gtk.Label tox_id;
    [GtkChild] private Gtk.Image tox_identicon;
    [GtkChild] private Gtk.Switch auto_conference;
    [GtkChild] private Gtk.Switch auto_filetransfer;
    [GtkChild] private Gtk.Revealer location_revealer;
    [GtkChild] private Gtk.FileChooserButton location;
    [GtkChild] private Gtk.Switch show_notifications;
    [GtkChild] private Gtk.Box notifications_box;
    [GtkChild] private Gtk.Revealer notifications_notice;
    [GtkChild] private Gtk.Button remove_button;
    [GtkChild] private Gtk.Button apply;

    private ILogger logger;
    private unowned ApplicationWindow app_window;
    private FriendInfoViewModel view_model;

    public FriendInfoWidget(ILogger logger, ApplicationWindow app_window, FriendInfoWidgetListener listener, IContact contact, ISettingsDatabase settings_database) {
      logger.d("FriendInfoWidget created.");
      this.logger = logger;
      this.app_window = app_window;
      this.view_model = new FriendInfoViewModel(logger, listener, contact as Contact);

      apply.clicked.connect(view_model.on_apply_clicked);
      remove_button.clicked.connect(view_model.on_remove_clicked);
      alias.icon_press.connect(view_model.on_clear_alias_clicked);
      view_model.leave_view.connect(leave_view);

      app_window.reset_header_bar();
      view_model.bind_property("username", app_window.header_bar, "title", BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", app_window.header_bar, "subtitle", BindingFlags.SYNC_CREATE);

      view_model.bind_property("username", username, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", statusmessage, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("userimage", userimage, "pixbuf", BindingFlags.SYNC_CREATE);
      view_model.bind_property("last-seen", last_seen, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("last-seen-tooltip", last_seen, "tooltip-text", BindingFlags.SYNC_CREATE);
      view_model.bind_property("tox-id", tox_id, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("tox-identicon", tox_identicon, "pixbuf", BindingFlags.SYNC_CREATE);

      view_model.bind_property("alias", alias, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("auto-conference", auto_conference, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("auto-filetransfer", auto_filetransfer, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("show-notifications", show_notifications, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settings_database.bind_property("enable-urgency-notification", notifications_box, "sensitive", BindingFlags.SYNC_CREATE);
      settings_database.bind_property("enable-urgency-notification", notifications_notice, "reveal-child", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

      auto_filetransfer.bind_property("active", location_revealer, "reveal-child", BindingFlags.SYNC_CREATE);

      location.set_current_folder(view_model.location);
      location.selection_changed.connect(on_file_set);
    }

    private void on_file_set() {
      view_model.location = location.get_filename();
    }

    private void leave_view() {
      app_window.show_welcome();
    }

    ~FriendInfoWidget() {
      logger.d("FriendInfoWidget destroyed.");
    }
  }
}
