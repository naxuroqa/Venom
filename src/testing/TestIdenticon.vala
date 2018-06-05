/*
 *    TestIdenticon.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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

using Venom;
using Mock;
using Testing;

public class TestIdenticon : UnitTest {
  private ILogger logger;
  private uint8[] key;
  private uint8[] expected_hash;

  public TestIdenticon() {
    add_func("/test_hash", test_hash);
    add_func("/test_hue_color", test_hue_color);
    add_func("/test_hue_color2", test_hue_color2);
    add_func("/test_rgb_color", test_rgb_color);
    add_func("/test_rgb_color2", test_rgb_color2);
    add_func("/test_draw_identicon", test_draw_identicon);
  }

  public override void set_up() throws Error {
    logger = new MockLogger();
    key = {
      0x76, 0x51, 0x84, 0x06, 0xF6, 0xA9, 0xF2, 0x21,
      0x7E, 0x8D, 0xC4, 0x87, 0xCC, 0x78, 0x3C, 0x25,
      0xCC, 0x16, 0xA1, 0x5E, 0xB3, 0x6F, 0xF3, 0x2E,
      0x33, 0x5A, 0x23, 0x53, 0x42, 0xC4, 0x8A, 0x39
    };
    expected_hash = {
      0xec, 0xac, 0x37, 0x54, 0xec, 0xe2, 0xa2, 0x29,
      0xdc, 0x40, 0xf0, 0xad, 0xff, 0x6e, 0x30, 0x41,
      0xb8, 0xce, 0x4a, 0x44, 0xc8, 0xec, 0x3b, 0xd7,
      0x78, 0xf9, 0x0d, 0xfd, 0x35, 0x29, 0xe5, 0xb7
    };
  }

  private void test_hash() throws Error {
    var identicon = new Identicon(key);
    var hash = identicon.generate_hash(key);
    Assert.assert_array_equals(expected_hash, hash);
  }

  private void test_hue_color() throws Error {
    var identicon = new Identicon(key);
    var hue_uint = identicon.hue_uint(expected_hash, 26);
    Assert.assert_true(15381169825207 == hue_uint);
    var hue_color = identicon.hue_color(hue_uint);
    Assert.assert_true(0.054644894f == hue_color);
  }

  private void test_hue_color2() throws Error {
    var identicon = new Identicon(key);
    var hue_uint = identicon.hue_uint(expected_hash, 20);
    Assert.assert_true(220916941814009 == hue_uint);
    var hue_color = identicon.hue_color(hue_uint);
    Assert.assert_true(0.78485465f == hue_color);
  }

  private void test_rgb_color() throws Error {
    var identicon = new Identicon(key);
    var rgb = identicon.hsl_to_rgb(0.054644894f);
    Assert.assert_array_equals({ 114, 63, 38 }, rgb);
  }

  private void test_rgb_color2() throws Error {
    var identicon = new Identicon(key);
    var rgb = identicon.hsl_to_rgb(0.78485465f, 0.5f, 0.8f);
    Assert.assert_array_equals({ 214, 178, 229 }, rgb);
  }

  private void test_draw_identicon() throws Error {
    var identicon = new Identicon(key);
    identicon.draw();
    Assert.assert_not_null(identicon.get_pixbuf());
  }

  private static int main(string[] args) {
    Test.init(ref args);
    var test = new TestIdenticon();
    (test);
    Test.run();
    return 0;
  }
}
