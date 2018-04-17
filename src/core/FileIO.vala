/*
 *    FileIO.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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
  public class FileIO : GLib.Object {
    private FileIO() {}

    public static string? load_contents_text(string path) throws Error {
      var file = File.new_for_path(path);
      uint8[] buf;
      file.load_contents(null, out buf, null);
      return (string) buf;
    }

    public static void save_contents_text(string path, string data) throws Error {
      var file = File.new_for_path(path);
      file.replace_contents(data.data, null, false, FileCreateFlags.NONE, null, null);
    }
  }
}
