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
    public virtual string get_id() {
      return id;
    }
    public virtual string get_name_string() {
      return _("Friend request");
    }
    public virtual string get_status_string() {
      return message;
    }
    public virtual UserStatus get_status() {return UserStatus.OFFLINE;}
    public virtual Gdk.Pixbuf get_image() {return null;}
  }

}
