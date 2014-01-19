/*
 *    Tools.vala
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
  public class Tools {
    // find our data dir (on linux most likely /usr/share or /usr/local/share)
    public static string find_data_dir() {
      foreach (string s in GLib.Environment.get_system_data_dirs()) {
        string dir = Path.build_filename(s, "venom");
        File f = File.new_for_path(dir);
        if(f.query_exists())
          return dir;
      }
      // Assume that our current pwd is our data dir
      return "";
    }

    public static void create_path_for_file(string filename, int mode) {
      string pathname = Path.get_dirname(filename);
      if(pathname != null) {
        File path = File.new_for_path(pathname);
        if(!path.query_exists()) {
          DirUtils.create_with_parents(pathname, mode);
          stdout.printf("created directory %s\n", pathname);
        }
      }
    }

    // convert a hexstring to uint8[]
    public static uint8[] hexstring_to_bin(string s) {
      uint8[] buf = new uint8[s.length / 2];
      for(int i = 0; i < buf.length; ++i) {
        int b = 0;
        s.substring(2*i, 2).scanf("%02x", ref b);
        buf[i] = (uint8)b;
      }
      return buf;
    }

    // convert a uint8[] to string
    public static string bin_to_hexstring(uint8[] bin) {
      if(bin == null || bin.length == 0)
        return "";
      StringBuilder b = new StringBuilder();
      for(int i = 0; i < bin.length; ++i) {
        b.append("%02X".printf(bin[i]));
      }
      return b.str;
    }

    // convert a string to a nullterminated uint8[]
    public static uint8[] string_to_nullterm_uint (string input){
      if(input == null || input.length <= 0)
        return {'\0'};
      uint8[] clone = new uint8[input.data.length + 1];
      Memory.copy(clone, input.data, input.data.length * sizeof(uint8));
      clone[clone.length - 1] = '\0';
      return clone;
    }

    // clone the given array
    public static uint8[] clone(uint8[] input, int length) {
      uint8[] clone = new uint8[length];
      Memory.copy(clone, input, length * sizeof(uint8));
      return clone;
    }

    public static string friend_add_error_to_string(Tox.FriendAddError friend_add_error) {
      switch(friend_add_error) {
        case Tox.FriendAddError.TOOLONG:
          return "Message too long";
        case Tox.FriendAddError.NOMESSAGE:
          return "No message included";
        case Tox.FriendAddError.OWNKEY:
          return "Can't send to own key";
        case Tox.FriendAddError.ALREADYSENT:
          return "Friend request already sent";
        case Tox.FriendAddError.UNKNOWN:
          return "Unknown error";
        case Tox.FriendAddError.BADCHECKSUM:
          return "Bad checksum";
        case Tox.FriendAddError.SETNEWNOSPAM:
          return "Set new nospam";
        case Tox.FriendAddError.NOMEM:
          return "Out of memory";
        default:
          return "Friend request successfully sent";
      }
    }
    private static GLib.Regex _action_regex;
    public static GLib.Regex action_regex {
      get {
        if(_action_regex == null) {
          try {
            _action_regex = new GLib.Regex("^/(?P<action_name>\\S+) (?P<action_string>.+)$");
          } catch (GLib.RegexError e) {
            stderr.printf("Can't create action regex: %s.\n", e.message);
          }
        }
        return _action_regex;
      }
      private set {
        _action_regex = value;
      }
    }
  }
}
