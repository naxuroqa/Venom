/*
 *    FriendRequest.vala
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
  public class FriendRequest : IContact, GLib.Object {
    private string id;
    private string message;
    public FriendRequest(string id, string message) {
      this.id = id;
      this.message = message;
    }
    public string get_id() {
      return id;
    }
    public string get_name_string() {
      return _("Friend request");
    }
    public string get_status_string() {
      return message;
    }
    public UserStatus get_status() { return UserStatus.NONE; }
    public bool is_connected() { return false; }
    public Gdk.Pixbuf get_image() { return null; }
    public bool get_requires_attention() { return true; }
    public void clear_attention() {}
    public bool is_typing() { return false; }
  }

}
