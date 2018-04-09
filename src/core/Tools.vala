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
    private Tools() {}

    public static void create_path_for_file(string filename, int mode) {
      string pathname = Path.get_dirname(filename);
      File path = File.new_for_path(pathname);
      if (!path.query_exists()) {
        DirUtils.create_with_parents(pathname, mode);
        // Logger.log(LogLevel.INFO, "created directory " + pathname);
      }
    }

    // convert a hexstring to uint8[]
    public static uint8[] hexstring_to_bin(string s) {
      var buf = new uint8[s.length / 2];
      var b = 0;
      for (int i = 0; i < buf.length; ++i) {
        s.substring(2 * i, 2).scanf("%02x", ref b);
        buf[i] = (uint8) b;
      }
      return buf;
    }

    // convert a uint8[] to string
    public static string bin_to_hexstring(uint8[] bin)
    requires(bin.length != 0)
    {
      var b = new StringBuilder();
      for (int i = 0; i < bin.length; ++i) {
        b.append("%02X".printf(bin[i]));
      }
      return b.str;
    }

    public static string uint8_to_nullterm_string(uint8[] data) {
      //TODO optimize this
      uint8[] buf = new uint8[data.length + 1];
      Memory.copy(buf, data, data.length);
      string sbuf = (string) buf;

      if (sbuf.validate()) {
        return sbuf;
      }
      // Extract usable parts of the string
      StringBuilder sb = new StringBuilder();
      for (unowned string s = sbuf; s.get_char() != 0; s = s.next_char()) {
        unichar u = s.get_char_validated();
        if (u != (unichar) (-1)) {
          sb.append_unichar(u);
        } else {
          // Logger.log(LogLevel.WARNING, "Invalid UTF-8 character detected");
        }
      }
      return sb.str;
    }

    public static string shorten_name(string name) {
      string[] parts = Regex.split_simple("\\s",name);
      if (parts.length < 2) { return name; }
      return parts[0];
    }

    public static string remove_whitespace(string str) {
      try {
        var regex = new GLib.Regex("\\s");
        return(regex.replace(str, -1, 0, ""));
      } catch (GLib.RegexError e) {
        GLib.assert_not_reached();
      }
    }

    public static uint64 get_file_size(GLib.File file) throws Error {
      var is = file.read();
      is.seek(0, SeekType.END);
      return is.tell();
    }

    public static string markup_uris(string text) throws Error {
      return Tools.uri_regex.replace(text, -1, 0, "<a href=\"\\g<u>\">\\g<u></a>");
    }

    private static GLib.Regex _action_regex;
    public static GLib.Regex action_regex {
      get {
        if (_action_regex == null) {
          try {
            _action_regex = new GLib.Regex("^/(?P<action_name>\\S+)(\\s+(?P<action_string>.+))?$");
          } catch (GLib.RegexError e) {
            // Logger.log(LogLevel.ERROR, "Can't create action regex: " + e.message);
          }
        }
        return _action_regex;
      }
    }
    private static GLib.Regex _uri_regex;
    public static GLib.Regex uri_regex {
      get {
        if (_uri_regex == null) {
          try {
            _uri_regex = new GLib.Regex("(?<u>[a-z]+://\\S*)");
          } catch (GLib.RegexError e) {
            // Logger.log(LogLevel.ERROR, "Can't create uri regex: " + e.message);
          }
        }
        return _uri_regex;
      }
    }
  }
}
