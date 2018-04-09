/*
 *    GroupchatContact.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  public class GroupchatContact : IContact, GLib.Object {
    // Saved in toxs savefile
    public uint32      tox_conference_number { get; set; }
    public string      title           { get; set; }
    public string      status_message  { get; set; default = ""; }
    public int         unread_messages { get; set; }
    private GLib.HashTable<uint32, GroupchatPeer> peers;

    public GroupchatContact(uint32 conference_number, string title) {
      tox_conference_number = conference_number;
      this.title = title;
      peers = new GLib.HashTable<uint32, GroupchatPeer>(null, null);
    }

    public string get_id() {
      return tox_conference_number.to_string();
    }

    public string get_name_string() {
      return title != "" ? title : "Unnamed conference %u".printf(tox_conference_number);
    }

    public string get_status_string() {
      return _("%u Peers online").printf(peers.size());
    }

    public UserStatus get_status() {
      return UserStatus.ONLINE;
    }

    public Gdk.Pixbuf get_image() {
      return Gtk.IconTheme.get_default().load_icon(R.icons.default_groupchat, 48, 0);
    }

    public unowned GLib.HashTable<uint32, GroupchatPeer> get_peers() {
      return peers;
    }

    public bool get_requires_attention() { return unread_messages > 0; }
    public void clear_attention() { unread_messages = 0; }
  }

  public interface GroupchatPeer : GLib.Object {
    public abstract uint32 peer_number { get; set; }
    public abstract string tox_public_key { get; set; }
    public abstract string name { get; set; }
    public abstract bool known { get; set; }
    public abstract bool is_self { get; set; }
  }

  public class GroupchatPeerImpl : GroupchatPeer, GLib.Object {
    public uint32 peer_number { get; set; }
    public string tox_public_key { get; set; }
    public string name { get; set; }
    public bool known { get; set; }
    public bool is_self { get; set; }

    public GroupchatPeerImpl(uint32 peer_number) {
      this.peer_number = peer_number;
      this.tox_public_key = "";
      this.name = "Peer %u".printf(peer_number);
      this.is_self = false;
    }
  }
}
