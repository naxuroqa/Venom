/*
 *    Copyright (C) 2013 Venom authors and contributors
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
  public class Contact : GLib.Object{

    public uint8[] public_key { get; set; }
    public int friend_id { get; set; }
    public string name { get; set; }
    public string local_name { get; set; }
    public string status_message { get; set; }
    public DateTime last_seen { get; set; }
    public int user_status { get; set; }
    public bool online { get; set; }
    public Gdk.Pixbuf? image { get; set; }
    public int unread_messages { get; set; }

    public Contact(uint8[] public_key, int friend_id = -1) {
      this.public_key = public_key;
      this.friend_id = friend_id;
      this.name = "";
      this.local_name = name;
      this.status_message = "";
      this.last_seen = new DateTime.now_local();
      this.user_status = (int)Tox.UserStatus.INVALID;
      this.image = null;
      this.unread_messages = 0;
    }
  }
}
