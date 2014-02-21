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
  public class Tools : GLib.Object{
    // find our data dir (on linux most likely /usr/share or /usr/local/share)
    public static string find_data_dir() {
      foreach (string s in GLib.Environment.get_system_data_dirs()) {
        string dir = Path.build_filename(s, "venom");
        File f = File.new_for_path(dir);
        if(f.query_exists())
          return dir;
      }
      // Check for common directories on portable versions
      string[] portable_directories = {
        Path.build_filename("share", "venom"),
        Path.build_filename("..", "share", "venom")
      };
      for (int i = 0; i < portable_directories.length; ++i) {
        File f = File.new_for_path(portable_directories[i]);
        if(f.query_exists())
          return portable_directories[i];
      }
      
      // Assume that our current pwd is our data dir
      return "";
    }

    public static void create_path_for_file(string filename, int mode) {
      string pathname = Path.get_dirname(filename);
      File path = File.new_for_path(pathname);
      if(!path.query_exists()) {
        DirUtils.create_with_parents(pathname, mode);
        stdout.printf("created directory %s\n", pathname);
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
    public static string bin_to_hexstring(uint8[] bin)
      requires(bin.length != 0)
    {
      StringBuilder b = new StringBuilder();
      for(int i = 0; i < bin.length; ++i) {
        b.append("%02X".printf(bin[i]));
      }
      return b.str;
    }

    // convert a string to a nullterminated uint8[]
    public static uint8[] string_to_nullterm_uint (string input)
      requires(input.length > 0)
    {
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

    public static string format_filesize(uint64 size) {
      if(VenomSettings.instance.dec_binary_prefix) {
        uint64 kibibyte = 1024;
        uint64 mebibyte = kibibyte * 1024;
        uint64 gibibyte = mebibyte * 1024;
        uint64 tebibyte = gibibyte * 1024;
        uint64 pebibyte = tebibyte * 1024;

        if(size < kibibyte) return "%llu bytes".printf(size);
        if(size < mebibyte) return "%.2lf KiB".printf( (double) size / kibibyte );
        if(size < gibibyte) return "%.2lf MiB".printf( (double) size / mebibyte );
        if(size < tebibyte) return "%.2lf GiB".printf( (double) size / gibibyte );
        if(size < pebibyte) return "%.2lf TiB".printf( (double) size / tebibyte );
        return "really big file";
      } else {
        uint64 kilobyte = 1000;
        uint64 megabyte = kilobyte * 1000;
        uint64 gigabyte = megabyte * 1000;
        uint64 terabyte = gigabyte * 1000;
        uint64 petabyte = terabyte * 1000;

        if(size < kilobyte) return "%llu bytes".printf(size);
        if(size < megabyte) return "%.2lf KB".printf( (double) size / kilobyte );
        if(size < gigabyte) return "%.2lf MB".printf( (double) size / megabyte );
        if(size < terabyte) return "%.2lf GB".printf( (double) size / gigabyte );
        if(size < petabyte) return "%.2lf TB".printf( (double) size / terabyte );
        return "really big file";
      }
    }

    public static string shorten_name(string name) {
      string[] parts = Regex.split_simple("\\s",name);
      if(parts.length < 2) return name;
      return parts[0];
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
            _action_regex = new GLib.Regex("^/(?P<action_name>\\S+)(\\s+(?P<action_string>.+))?$");
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
