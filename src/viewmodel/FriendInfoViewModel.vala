/*
 *    FriendInfoViewModel.vala
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
  public class FriendInfoViewModel : GLib.Object {
    public string username { get; set; }
    public string statusmessage { get; set; }
    public Gdk.Pixbuf userimage { get; set; }
    public string last_seen { get; set; }
    public string alias { get; set; }
    public string tox_id { get; set; }
    public signal void leave_view();

    private ILogger logger;
    private Contact contact;
    private FriendInfoWidgetListener listener;

    public FriendInfoViewModel(ILogger logger, FriendInfoWidgetListener listener, Contact contact) {
      logger.d("FriendInfoViewModel created.");
      this.logger = logger;
      this.contact = contact;
      this.listener = listener;

      alias = contact.alias;
      set_info();
      contact.changed.connect(set_info);
    }

    private void set_info() {
      username = contact.name;
      statusmessage = contact.status_message;
      last_seen = contact.last_seen.format("%c");
      tox_id = contact.get_id();
      var pixbuf = contact.get_image();
      if (pixbuf != null) {
        userimage = pixbuf.scale_simple(96, 96, Gdk.InterpType.BILINEAR);
      }
    }

    public void on_apply_clicked() {
      logger.d("on_apply_clicked.");
      contact.alias = alias;
      contact.changed();
    }

    public void on_remove_clicked() {
      try {
        listener.on_remove_friend(contact);
      } catch (Error e) {
        logger.e("Could not remove friend: " + e.message);
        return;
      }
      leave_view();
    }

    public void on_clear_alias_clicked() {
      alias = "";
    }

    ~FriendInfoViewModel() {
      logger.d("FriendInfoViewModel destroyed.");
    }
  }

  public interface FriendInfoWidgetListener : GLib.Object {
    public abstract void on_remove_friend(IContact contact) throws Error;
  }
}
