/*
 *    FriendRequestWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/friend_request_widget.ui")]
  public class FriendRequestWidget : Gtk.Box {
    private ILogger logger;
    private IContact contact;
    private FriendRequestWidgetListener listener;
    private unowned ApplicationWindow app;

    [GtkChild]
    private Gtk.Label contact_id;
    [GtkChild]
    private Gtk.Label contact_message;

    [GtkChild]
    private Gtk.Button accept;
    [GtkChild]
    private Gtk.Button reject;

    public FriendRequestWidget(ApplicationWindow app, ILogger logger, IContact contact, FriendRequestWidgetListener listener) {
      logger.d("FriendRequestWidget created.");
      this.logger = logger;
      this.contact = contact;
      this.app = app;
      this.listener = listener;

      contact_id.label = contact.get_id();
      contact_message.label = contact.get_status_string();
      accept.clicked.connect(on_accept_clicked);
      reject.clicked.connect(on_reject_clicked);
    }

    private void on_accept_clicked() {
      try {
        listener.on_accept_friend_request(contact.get_id());
        app.show_welcome();
      } catch (Error e) {
        logger.i("Could not accept friend request: " + e.message);
      }
    }

    private void on_reject_clicked() {
      try {
        listener.on_reject_friend_request(contact.get_id());
        app.show_welcome();
      } catch (Error e) {
        logger.i("Could not reject friend request: " + e.message);
      }
    }

    ~FriendRequestWidget() {
      logger.d("FriendRequestWidget destroyed.");
    }
  }

  public interface FriendRequestWidgetListener : GLib.Object {
    public abstract void on_accept_friend_request(string id) throws Error;
    public abstract void on_reject_friend_request(string id) throws Error;
  }
}
