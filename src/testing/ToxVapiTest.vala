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

namespace Testing {
  public class ToxTest {
    public void run_connection_test(string ip_string, string pub_key_string, int port = 33445, int timeout = 2000, bool ipv6 = false) {
      Tox.Tox tox = new Tox.Tox(ipv6 ? 1 : 0);
      string ip_address = ip_string;
      uint16 ip_port_be = ((uint16)port).to_big_endian();
      uint8[] pub_key = Venom.Tools.hexstring_to_bin(pub_key_string);

      stdout.printf("Connecting to: %s:%u\n", ip_address, port);
      stdout.printf("Public key:    %s\n", pub_key_string);

      tox.bootstrap_from_address(ip_address, ipv6 ? 1 : 0, ip_port_be, pub_key);

      bool connected = false;
      for(int i = 0; i < timeout; ++i) {
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
      stdout.flush();
    }

    public static void main(string[] args) {
      ToxTest test = new ToxTest();
      test.run_connection_test("54.215.145.71",  "6EDDEE2188EF579303C0766B4796DCBA89C93058B6032FEA51593DCD42FB746C");
      test.run_connection_test("66.175.223.88",  "B24E2FB924AE66D023FE1E42A2EE3B432010206F751A2FFD3E297383ACF1572E");
      test.run_connection_test("192.184.81.118", "5CD7EB176C19A2FD840406CD56177BB8E75587BB366F7BB3004B19E3EDC04143");
      test.run_connection_test("198.46.136.167", "728925473812C7AAC482BE7250BCCAD0B8CB9F737BF3D42ABD34459C1768F854");
      test.run_connection_test("95.47.140.214",  "F4BF7C5A9D0EF4CB684090C38DE937FAE1612021F21FEA4DCBFAC6AAFEF58E68");
      test.run_connection_test("198.27.64.29",   "DAC529413F2C1CF0E3282CD8E47D6F2065E6C9D7A0D3DB61B111550E96917555");
      test.run_connection_test("81.224.34.47",   "48F0D94C0D54EB1995A2ECEDE7DB6BDD5E05D81704B2F3D1BB9FE43AC97B7269", 33443);
      test.run_connection_test("66.74.30.125",   "890D9C546EC2B72476EDFEB86AFEAE229FE8D0686D1ED75E8F7BFC56DCC81C26");
      test.run_connection_test("71.59.40.171", "F3293FFA5147639E8AE0A3DDBB63F6E358595A5538882DA7C9BFCA1E2E79B536");
      stdout.printf("Testing done.\n");
    }
  }
}
