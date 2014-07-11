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

  public enum AudioCallState {
    RINGING,
    STARTED,
    ENDED
  }

  public interface IContact : GLib.Object {
    public abstract string get_name_string();
    public abstract string get_name_string_with_hyperlinks();
    public abstract string get_status_string();
    public abstract string get_status_string_with_hyperlinks();
    public abstract string get_status_string_alt();
    public abstract string get_last_seen_string();
    public abstract string get_tooltip_string();
  }

  public class Contact : IContact, GLib.Object {
    // Saved in toxs savefile
    public uint8[]        public_key       { get; set; }
    public int            friend_id        { get; set; default = -1;}
    public string         name             { get; set; default = ""; }
    public string         status_message   { get; set; default = ""; }
    public DateTime       last_seen        { get; set; default = null; }
    public uint8          user_status      { get; set; default = (uint8)Tox.UserStatus.INVALID; }
    // Saved in venoms savefile
    public string         note             { get; set; default = ""; }
    public string         alias            { get; set; default = ""; }
    public bool           is_blocked       { get; set; default = false; }
    public string         group            { get; set; default = ""; }
    // Not saved
    public bool           online           { get; set; default = false; }
    public Gdk.Pixbuf?    image            { get; set; default = null; }
    public int            unread_messages  { get; set; default = 0; }
    public bool           is_typing        { get; set; default = false; }
    // ToxAV stuff
    public int            call_index       { get; set; default = -1; }
    public AudioCallState audio_call_state { get; set; default = AudioCallState.ENDED; }

    private GLib.HashTable<uint8, FileTransfer> _file_transfers = new GLib.HashTable<uint8, FileTransfer>(null, null);

    public unowned GLib.HashTable<uint8, FileTransfer> get_filetransfers() {
      return _file_transfers;
    }

    public Contact(uint8[] public_key, int friend_id = -1) {
      this.public_key = public_key;
      this.friend_id = friend_id;
    }

    public string get_name_string() {
      if(name != "") {
        if(alias == "") {
          return name;
        } else {
          return _("%s <i>(%s)</i>").printf(Markup.escape_text(name), Markup.escape_text(alias));
        }
      } else if (alias != "") {
        return _("<i>%s</i>").printf(Markup.escape_text(alias));
      } else {
        return Tools.bin_to_hexstring(public_key);
      }
    }

    public string get_name_string_with_hyperlinks() {
      if(name != "") {
        if(alias == "") {
          return name;
        } else {
          return _("%s <i>(%s)</i>").printf(Tools.markup_uris(name), Tools.markup_uris(alias));
        }
      } else if (alias != "") {
        return _("<i>%s</i>").printf(Tools.markup_uris(alias));
      } else {
        return Tools.bin_to_hexstring(public_key);
      }
    }

    public string get_status_string() {
      if(online || status_message != "") {
        return Markup.escape_text(status_message);
      } else if (last_seen != null) {
        return get_last_seen_string();
      } else {
        return _("Offline");
      }
    }

    public string get_status_string_with_hyperlinks() {
      if(online || status_message != "") {
        return Tools.markup_uris(status_message);
      } else if (last_seen != null) {
        return get_last_seen_string();
      } else {
        return _("Offline");
      }
    }

    public string get_status_string_alt() {
      return Tools.markup_uris(status_message);
    }

    public string get_last_seen_string() {
      return last_seen != null ? _("Last seen: %s").printf(last_seen.format("%c")) : "";
    }

    public string get_tooltip_string() {
      StringBuilder b = new StringBuilder();
      b.append(get_name_string_with_hyperlinks());
      if(status_message != "") {
        b.append_c('\n');
        b.append(get_status_string_alt());
      }
      if(!online && last_seen != null) {
        b.append_c('\n');
        b.append(get_last_seen_string());
      }
      return b.str;
    }
  }
}
