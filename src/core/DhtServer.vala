/*
 *    Copyright (C) 2013 Venom authors and contributors
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

using Tox;
namespace Venom {
  public class DhtServer {
    public string host {get; set;}
    public uint16 port {get; set;}
    public uint8[] pub_key {get; set;}
    public bool ipv6 {get; set;}

    public DhtServer.with_args(string host, string pub_key, bool ipv6 = false, uint16 port = 33445) {
      this.host = host;
      this.port = port;
      this.pub_key = Tools.hexstring_to_bin(pub_key);
      this.ipv6 = ipv6;
    }
    public string to_string() {
      return "%s:%u%s %s".printf(host, port, ipv6 ? " (ipv6)" : "", Tools.bin_to_hexstring(pub_key));
    }
  }
}
