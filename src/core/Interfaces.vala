/*
 *    Interfaces.vala
 *
 *    Copyright (C) 2017-2018  Venom authors and contributors
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
  public interface IDhtNode : Object {
    public abstract string pub_key    { get; set; }
    public abstract string host       { get; set; }
    public abstract uint   port       { get; set; }
    public abstract string maintainer { get; set; }
    public abstract string location   { get; set; }
    public abstract bool   is_blocked { get; set; }

    public string to_string() {
      return "%s:%u %s - %s / %s (blocked: %s)".printf(host, port, pub_key, maintainer, location, is_blocked ? "true" : "false");
    }
  }

  public interface ILogger : Object {
    public abstract void d(string message);
    public abstract void i(string message);
    public abstract void w(string message);
    public abstract void e(string message);
    public abstract void f(string message);
    public abstract void attach_to_glib();
  }

  public enum UserStatus {
    NONE,
    AWAY,
    BUSY
  }
}
