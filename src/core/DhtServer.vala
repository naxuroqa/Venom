/*
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
    public IpPort ip_port {get; set;}
    public uint8[] pub_key {get; set;}
    public DhtServer() {
    }
    public DhtServer.withArgs(IpPort ip_port, uint8[] pub_key) {
      assert(pub_key.length == 32);
      this.ip_port = ip_port;
      this.pub_key = Tools.clone(pub_key, pub_key.length);
    }
    public string toString() {
      return "%u.%u.%u.%u %u %s".printf(ip_port.ip.c[0], ip_port.ip.c[1], ip_port.ip.c[2], ip_port.ip.c[3],
                    uint16.from_big_endian(ip_port.port), Tools.bin_to_hexstring(pub_key));
    }
  }
}
