/*
 *    DhtNode.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  public class DhtNode : GLib.Object {
    public int    id         { get; set; }
    public string pub_key    { get; set; }
    public string host       { get; set; }
    public uint   port       { get; set; }
    public bool   is_blocked { get; set; }
    public string maintainer { get; set; }
    public string location   { get; set; }

    public DhtNode() {
    }

    public DhtNode.with_params(string pub_key, string host, uint port = 33445, bool is_blocked = false, string maintainer = "", string location = "") {
      this.pub_key = pub_key;
      this.host = host;
      this.port = port;
      this.is_blocked = is_blocked;
      this.maintainer = maintainer;
      this.location = location;
    }

    public string to_string() {
      return "%s:%u %s - %s / %s (blocked: %s)".printf(host, port, pub_key, maintainer, location, is_blocked ? "true" : "false");
    }
  }
}
