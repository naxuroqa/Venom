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
  public class FriendRequest : GLib.Object {
    public string id { get; set; }
    public string message { get; set; }
    public DateTime timestamp { get; set; }

    public FriendRequest(string id, string message) {
      this.id = id;
      this.message = message;
      this.timestamp = new DateTime.now_local();
    }
  }

  public class ConferenceInvite : GLib.Object {
    public IContact sender { get; set; }
    public ConferenceType conference_type { get; set; }
    public DateTime timestamp { get; set; }
    public uint8[] get_cookie() {
      return cookie;
    }
    private uint8[] cookie;
    public ConferenceInvite(IContact sender, ConferenceType conference_type, uint8[] cookie) {
      this.sender = sender;
      this.conference_type = conference_type;
      this.cookie = cookie;
      this.timestamp = new DateTime.now_local();
    }
  }
}
