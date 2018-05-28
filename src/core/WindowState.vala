/*
 *    WindowState.vala
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
  public class WindowState : GLib.Object {
    public int width { get; set; default = 800; }
    public int height { get; set; default = 600; }
    public bool is_maximized { get; set; default = false; }
    public bool is_fullscreen { get; set; default = false; }

    public static string serialize(WindowState state) throws Error {
      return Json.gobject_to_data(state, null);
    }

    public static WindowState deserialize(string data) throws Error {
      return Json.gobject_from_data(typeof(WindowState), data) as WindowState;
    }
  }
}
