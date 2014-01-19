/*
 *    Contact.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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

    public uint8[] public_key    { get; set; }
    public int friend_id         { get; set; }
    public string name           { get; set; default = ""; }
    // set a locally stored name/tag
    //public string local_name     { get; set; default = ""; }
    public string status_message { get; set; default = ""; }
    public DateTime last_seen    { get; set; default = null; }
    public int user_status       { get; set; default = (int)Tox.UserStatus.INVALID; }
    public bool online           { get; set; default = false; }
    public Gdk.Pixbuf? image     { get; set; default = null; }
    public int unread_messages   { get; set; default = 0; }

    public Contact(uint8[] public_key, int friend_id = -1) {
      this.public_key = public_key;
      this.friend_id = friend_id;
    }
  }
}
