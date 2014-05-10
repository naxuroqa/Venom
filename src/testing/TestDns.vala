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
  public class TestDns : GLib.Object {
    public static int main(string[] args) {
      if(args.length < 2) {
        message("Wrong number of arguments");
        message("Format: %s <dns-uri-scheme> <pin>", args[0]);
        return -1;
      }
      string pin = args.length < 3 ? null : args[2];

      Venom.ToxDns dns = new Venom.ToxDns();
      dns.resolve_id(args[1], () => {
        if(pin == null) {
          stdout.printf("Please insert pin: ");
          pin = stdin.read_line();
        }
        return pin;
      });
      return 0;
    }
  }
}
