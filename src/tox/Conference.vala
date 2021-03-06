/*
 *    Conference.vala
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
  public class Conference : IContact, GLib.Object {
    // Saved in toxs savefile
    public uint32 conference_number { get; set; }
    public string title             { get; set; }
    public string status_message    { get; set; default = ""; }
    public int    unread_messages   { get; set; default = 0; }
    public bool   _show_notifications { get; set; default = true; }
    private Gee.Map<uint32, ConferencePeer> peers;
    private static Gdk.Pixbuf default_image;

    public Conference(uint32 conference_number, string title) {
      this.conference_number = conference_number;
      this.title = title;
      peers = new Gee.HashMap<uint32, ConferencePeer>();
    }

    public string get_id() {
      return @"tox.conference.$conference_number";
    }

    public string get_name_string() {
      return title != "" ? title : _("Unnamed conference %u").printf(conference_number);
    }

    public string get_status_string() {
      return _("%u Peers online").printf(peers.size);
    }

    public UserStatus get_status() {
      return UserStatus.NONE;
    }

    public bool is_connected() {
      return !peers.is_empty;
    }

    public bool is_typing() {
      return false;
    }

    public bool is_conference() {
      return true;
    }

    private Gdk.Pixbuf get_default_image() {
      if (default_image == null) {
        try {
          default_image = Gtk.IconTheme.get_default().load_icon(R.icons.default_groupchat, 48, 0);
        } catch (Error e) {
          assert_not_reached();
        }
      }
      return default_image;
    }

    public Gdk.Pixbuf get_image() {
      if (peers.size < 1) {
        return get_default_image();
      }

      var size = 120;
      var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, size, size);
      var ctx = new Cairo.Context(surface);
      var count = uint.min(peers.size, 5);
      var offset = 90.0 / count;
      var radius = size * 0.1f;
      var deg = Math.PI / 180.0;

      for(var i = 0; i < count; i++) {
        var peer = peers.get(i);

        var identicon = round_corners(Identicon.generate_pixbuf(Tools.hexstring_to_bin(peer.peer_key)));
        var identicon_surf = Gdk.cairo_surface_create_from_pixbuf(identicon, 1, null);

        ctx.save();
        ctx.translate(offset * i, 0);
        ctx.set_source_surface(identicon_surf, 0, 0);
        ctx.paint();

        if (i > 0) {
          ctx.new_sub_path();
          ctx.arc(size - radius, radius, radius, -90 * deg, 0);
          ctx.arc(size - radius, size - radius, radius, 0, 90 * deg);
          ctx.arc(radius, size - radius, radius, 90 * deg, 180 * deg);
          ctx.arc(radius, radius, radius, 180 * deg, 270 * deg);
          ctx.close_path();

          ctx.set_source_rgba(0, 0, 0, 0.25);
          ctx.set_line_width(5);
          ctx.stroke();
        }

        ctx.restore();
      }

      return Gdk.pixbuf_get_from_surface(surface, 0, 0, size, size);
    }

    public unowned Gee.Map<uint32, ConferencePeer> get_peers() {
      return peers;
    }

    public bool show_notifications() {
      return _show_notifications;
    }

    public bool get_requires_attention() { return unread_messages > 0; }
    public void clear_attention() { unread_messages = 0; }
  }

  public class ConferencePeer : GLib.Object {
    public uint32 peer_number { get; set; }
    public string peer_key { get; set; }
    public string peer_name { get; set; }
    public bool is_known { get; set; }
    public bool is_self { get; set; }

    public ConferencePeer(uint32 peer_number, string peer_key, string peer_name, bool is_known, bool is_self) {
      this.peer_number = peer_number;
      this.peer_key = peer_key;
      this.peer_name = peer_name;
      this.is_known = is_known;
      this.is_self = is_self;
    }
  }
}
