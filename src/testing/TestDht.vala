/*
 *    ToxTestDht.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
  public class TestDht : GLib.Object {
    public void run_connection_test(string ip_string, string pub_key_string, int port = 33445, int timeout = 100, bool ipv6 = false) {
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
        Thread.usleep(25000);
      }
      if(connected) {
        stdout.printf("[x] Connection successfully established.\n");
      } else {
        stdout.printf("[ ] Could not establish connection!\n");
      }
      stdout.printf("----------------------------------------\n");
      stdout.flush();
    }

    public static void main(string[] args) {
      TestDht test = new TestDht();
      test.run_connection_test("192.81.133.111", "8CD5A9BF0A6CE358BA36F7A653F99FA6B258FF756E490F52C1F98CC420F78858");
      test.run_connection_test("66.175.223.88",  "B24E2FB924AE66D023FE1E42A2EE3B432010206F751A2FFD3E297383ACF1572E");
      test.run_connection_test("192.184.81.118", "5CD7EB176C19A2FD840406CD56177BB8E75587BB366F7BB3004B19E3EDC04143");
      test.run_connection_test("192.210.149.121","F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67");
      test.run_connection_test("81.224.34.47",   "48F0D94C0D54EB1995A2ECEDE7DB6BDD5E05D81704B2F3D1BB9FE43AC97B7269", 443);
      test.run_connection_test("198.46.136.167", "728925473812C7AAC482BE7250BCCAD0B8CB9F737BF3D42ABD34459C1768F854");
      test.run_connection_test("95.47.140.214",  "F4BF7C5A9D0EF4CB684090C38DE937FAE1612021F21FEA4DCBFAC6AAFEF58E68");
      test.run_connection_test("54.215.145.71",  "6EDDEE2188EF579303C0766B4796DCBA89C93058B6032FEA51593DCD42FB746C");
      test.run_connection_test("66.74.30.125",   "7155386A691E7BD3C4C0589D70ACDA191D488634772885CCED5DD7B3F7E6310D");
      test.run_connection_test("69.42.220.58",   "9430A83211A7AD1C294711D069D587028CA0B4782FA43CB9B30008247A43C944");
      test.run_connection_test("31.192.105.19",  "D59F99384592DE4C8AB9D534D5197DB90F4755CC9E975ED0C565E18468A1445B");
      test.run_connection_test("5.39.218.35",    "CC2B02636A2ADBC2871D6EC57C5E9589D4FD5E6F98A14743A4B949914CF26D39");
      stdout.printf("Testing done, press any key to close.\n");
      char c;
      stdin.scanf("%c", out c);
    }
  }
}
