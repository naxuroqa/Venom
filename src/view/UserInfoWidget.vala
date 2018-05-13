/*
 *    UserInfoWidget.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/user_info_widget.ui")]
  public class UserInfoWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry entry_username;
    [GtkChild] private Gtk.Entry entry_statusmessage;
    [GtkChild] private Gtk.Image avatar;
    [GtkChild] private Gtk.Label label_id;
    [GtkChild] private Gtk.Button reset_avatar;
    [GtkChild] private Gtk.FileChooserButton filechooser;
    [GtkChild] private Gtk.Button apply;

    private ILogger logger;
    private UserInfoViewModel view_model;

    public UserInfoWidget(ILogger logger, ApplicationWindow app_window, UserInfo user_info, UserInfoViewListener listener) {
      logger.d("UserInfoWidget created.");
      this.logger = logger;
      this.view_model = new UserInfoViewModel(logger, user_info, listener);

      app_window.reset_header_bar();
      view_model.bind_property("username", app_window.header_bar, "title", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", app_window.header_bar, "subtitle", GLib.BindingFlags.SYNC_CREATE);

      view_model.bind_property("username", entry_username, "text", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("statusmessage", entry_statusmessage, "text", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("avatar", avatar, "pixbuf", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("tox-id", label_id, "label", GLib.BindingFlags.SYNC_CREATE);

      var imagefilter = new Gtk.FileFilter();
      imagefilter.set_filter_name(_("Images"));
      imagefilter.add_mime_type("image/*");
      filechooser.add_filter(imagefilter);

      filechooser.file_set.connect(on_file_set);
      reset_avatar.clicked.connect(on_file_reset);
      apply.clicked.connect(view_model.on_apply_clicked);
    }

    private void on_file_set() {
      view_model.set_file(filechooser.get_file());
    }

    private void on_file_reset() {
      view_model.reset_file();
      filechooser.unselect_all();
    }

    ~UserInfoWidget() {
      logger.d("UserInfoWidget destroyed.");
    }
  }
}
