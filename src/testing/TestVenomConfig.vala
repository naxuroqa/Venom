/*
 *    TestVenomConfig.vala
 *
 *    Copyright (C) 2017 Venom authors and contributors
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

namespace TestVenomConfig {

  private static void testVenomVersion() {
    assert(Config.VERSION == "%d.%d.%d".printf(Config.VERSION_MAJOR, Config.VERSION_MINOR, Config.VERSION_PATCH));
  }

  private static void testVenomStrings() {
    assert(Config.COPYRIGHT_NOTICE != null);
    assert(Config.SHORT_DESCRIPTION != null);
  }

  private static void main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_venom_version", testVenomVersion);
    Test.add_func("/test_venom_strings", testVenomStrings);
    Test.run();
  }
}
