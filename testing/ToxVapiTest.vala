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

namespace Testing {
  public class ToxTest {
    public void run_connection_test(string ip_string, string pub_key_string, int port = 33445, int timeout = 5000, bool ipv6 = true) {
      Tox.Tox tox = new Tox.Tox(ipv6 ? 1 : 0);
      string ip_address = ip_string;
      uint16 ip_port_be = ((uint16)port).to_big_endian();
      uint8[] pub_key = Venom.Tools.hexstring_to_bin(pub_key_string);
      
      stdout.printf("Connecting to: %s:%u\n", ip_address, uint16.from_big_endian(ip_port_be));
      stdout.printf("Public key:    %s\n", pub_key_string);

      tox.bootstrap_from_address(ip_address, ipv6 ? 1 : 0, ip_port_be, pub_key);
      
      bool connected = false;
      for(int i = 0; i < 5000; ++i) {
        if(connected = (tox.isconnected() != 0))
          break;
        tox.do();
        Thread.usleep(1000);
      }
      if(connected) {
        stdout.printf("[x] Connection successfully established.\n");
      } else {
        stdout.printf("[ ] Could not establish connection!\n");
      }
    }

    public static void main(string[] args) {
      ToxTest test = new ToxTest();
      test.run_connection_test("54.215.145.71",  "6EDDEE2188EF579303C0766B4796DCBA89C93058B6032FEA51593DCD42FB746C"); 
      test.run_connection_test("192.184.81.118", "5CD7EB176C19A2FD840406CD56177BB8E75587BB366F7BB3004B19E3EDC04143");
      stdout.printf("Testing done.\n");
    }
  }
}
