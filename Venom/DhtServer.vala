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
      this.ip_port = ip_port;
      this.pub_key = new uint8[32];
      assert(this.pub_key.length == pub_key.length);
      for(int i = 0; i < pub_key.length; ++i)
        this.pub_key[i] = pub_key[i];
    }
    public string toString() {
      return "%u.%u.%u.%u %u %02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X".printf(ip_port.ip.c[0], ip_port.ip.c[1], ip_port.ip.c[2], ip_port.ip.c[3],
                    ip_port.port,
                    pub_key[0],  pub_key[1],  pub_key[2],  pub_key[3],  pub_key[4],  pub_key[5],  pub_key[6], pub_key[7],
                    pub_key[8],  pub_key[9],  pub_key[10], pub_key[11], pub_key[12], pub_key[13], pub_key[14], pub_key[15],
                    pub_key[16], pub_key[17], pub_key[18], pub_key[19], pub_key[20], pub_key[21], pub_key[22], pub_key[23],
                    pub_key[24], pub_key[25], pub_key[26], pub_key[27], pub_key[28], pub_key[29], pub_key[30], pub_key[31]);
    }
  }
}
