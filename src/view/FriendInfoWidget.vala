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
  [GtkTemplate(ui = "/im/tox/venom/ui/friend_info_widget.ui")]
  public class FriendInfoWidget : Gtk.Box {
    [GtkChild] private Gtk.Label username;
    [GtkChild] private Gtk.Label statusmessage;
    [GtkChild] private Gtk.Image userimage;
    [GtkChild] private Gtk.Label last_seen;
    [GtkChild] private Gtk.Entry alias;
    [GtkChild] private Gtk.Label tox_id;
    [GtkChild] private Gtk.Button remove;
    [GtkChild] private Gtk.Button apply;

    private ILogger logger;
    private unowned ApplicationWindow app_window;
    private FriendInfoViewModel view_model;

    public FriendInfoWidget(ILogger logger, ApplicationWindow app_window, FriendInfoWidgetListener listener, IContact contact) {
      logger.d("FriendInfoWidget created.");
      this.logger = logger;
      this.app_window = app_window;
      this.view_model = new FriendInfoViewModel(logger, listener, contact as Contact);

      apply.clicked.connect(view_model.on_apply_clicked);
      remove.clicked.connect(view_model.on_remove_clicked);
      alias.icon_press.connect(view_model.on_clear_alias_clicked);
      view_model.leave_view.connect(leave_view);

      view_model.bind_property("username", username, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", statusmessage, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("userimage", userimage, "pixbuf", BindingFlags.SYNC_CREATE);
      view_model.bind_property("last_seen", last_seen, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("alias", alias, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("tox_id", tox_id, "label", BindingFlags.SYNC_CREATE);
    }

    private void leave_view() {
      app_window.show_welcome();
    }

    ~FriendInfoWidget() {
      logger.d("FriendInfoWidget destroyed.");
    }
  }
}
