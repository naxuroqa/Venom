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
    public string ip {get; set;}
    public uint16 port {get; set;}
    public uint8[] pub_key {get; set;}
    public bool ipv6 {get; set;}

    public DhtServer.with_args(string ip, uint16 port, uint8[] pub_key, bool ipv6 = false) {
      assert(pub_key.length == 32);
      this.ip = ip;
      this.port = port;
      this.pub_key = Tools.clone(pub_key, pub_key.length);
      this.ipv6 = ipv6;
    }
    public string to_string() {
      return "%s:%u%s %s".printf(ip, uint16.from_big_endian(port), ipv6 ? " (ipv6)" : "", Tools.bin_to_hexstring(pub_key));
    }
  }
}
