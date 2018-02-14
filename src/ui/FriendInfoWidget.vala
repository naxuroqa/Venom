/*
 *    FriendInfoWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/friend_info_widget.ui")]
  public class FriendInfoWidget : Gtk.Box {

    [GtkChild]
    private Gtk.Label username;

    [GtkChild]
    private Gtk.Label statusmessage;

    [GtkChild]
    private Gtk.Image userimage;

    [GtkChild]
    private Gtk.Label last_seen;

    [GtkChild]
    private Gtk.Entry alias;

    [GtkChild]
    private Gtk.Label tox_id;

    [GtkChild]
    private Gtk.Button remove;

    [GtkChild]
    private Gtk.Button apply;

    private ILogger logger;
    private Contact contact;
    private FriendInfoWidgetListener listener;
    private unowned ApplicationWindow app_window;

    public FriendInfoWidget(ILogger logger, ApplicationWindow app_window, FriendInfoWidgetListener listener, IContact contact) {
      logger.d("FriendInfoWidget created.");
      this.logger = logger;
      this.contact = contact as Contact;
      this.listener = listener;
      this.app_window = app_window;

      set_info();

      apply.clicked.connect(on_apply_clicked);
      remove.clicked.connect(on_remove_clicked);
    }

    private void set_info() {
      username.label = contact.get_name_string();
      statusmessage.label = contact.get_status_string();
      last_seen.label = contact.last_seen.format("%c");
      alias.text = contact.alias;
      tox_id.label = contact.get_id();
    }

    private void on_apply_clicked() {
      logger.d("on_apply_clicked.");
      contact.alias = alias.text;
    }

    private void on_remove_clicked() {
      try {
        listener.on_remove_friend(contact);
      } catch (Error e) {
        logger.e("Could not remove friend: " + e.message);
        return;
      }
      app_window.show_welcome();
    }

    ~FriendInfoWidget() {
      logger.d("FriendInfoWidget destroyed.");
    }
  }

  public interface FriendInfoWidgetListener : GLib.Object {
    public abstract void on_remove_friend(IContact contact) throws Error;
  }
}
