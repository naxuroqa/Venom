/*
 *    FriendRequestWidget.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/friend_request_widget.ui")]
  public class FriendRequestWidget : Gtk.ListBoxRow {
    private ILogger logger;
    private FriendRequest friend_request;
    private FriendRequestWidgetListener listener;

    [GtkChild] private Gtk.Label contact_id;
    [GtkChild] private Gtk.Label contact_message;
    [GtkChild] private Gtk.Label contact_time;
    [GtkChild] private Gtk.Image contact_image;

    [GtkChild] private Gtk.Button accept;
    [GtkChild] private Gtk.Button reject;

    public FriendRequestWidget(ILogger logger, FriendRequest friend_request, FriendRequestWidgetListener listener) {
      logger.d("FriendRequestWidget created.");
      this.logger = logger;
      this.friend_request = friend_request;
      this.listener = listener;

      contact_id.label = friend_request.id;
      contact_message.label = friend_request.message;
      contact_time.label = TimeStamp.get_pretty_timestamp(friend_request.timestamp);
      var pub_key = Tools.hexstring_to_bin(friend_request.id);
      contact_image.pixbuf = round_corners(Identicon.generate_pixbuf(pub_key, 40));

      accept.clicked.connect(on_accept_clicked);
      reject.clicked.connect(on_reject_clicked);
    }

    private void on_accept_clicked() {
      try {
        listener.on_accept_friend_request(friend_request.id);
      } catch (Error e) {
        logger.i("Could not accept friend request: " + e.message);
      }
    }

    private void on_reject_clicked() {
      try {
        listener.on_reject_friend_request(friend_request.id);
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
