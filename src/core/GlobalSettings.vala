/*
 *    GlobalSettings.vala
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
  public class GlobalSettings : GLib.Object {
    public string last_used_profile { get; set; default = ""; }
    public bool auto_login { get; set; default = false; }

    public static string serialize(GlobalSettings settings) throws Error {
      return Json.gobject_to_data(settings, null);
    }

    public static GlobalSettings deserialize(string data) throws Error {
      return Json.gobject_from_data(typeof(GlobalSettings), data) as GlobalSettings;
    }
  }
}
