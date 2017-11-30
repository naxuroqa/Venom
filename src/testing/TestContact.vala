/*
 *    TestContact.vala
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

using Venom;

namespace TestContact {

  // private static void testContact() {
  //   uint8[] public_key = new uint8[ToxCore.public_key_size()];
  //   var contact = new Contact(public_key);
  //   assert(equals(contact.public_key, public_key));
  //   assert(contact.friend_id == -1);
  //   assert(contact.get_name_string() == Tools.bin_to_hexstring(public_key));
  // }

  // private static void testContactName() {
  //   var contact = new Contact({});
  //   var name = "name";
  //   contact.name = name;
  //   assert(contact.name == name);
  //   assert(contact.get_name_string() == name);
  // }

  // private static bool equals(uint8[] a, uint8[] b) {
  //   return (a != null && b != null && a.length == b.length && Memory.cmp(a, b, a.length) == 0);
  // }

  private static int main(string[] args) {
    return 77;
    //Test.init(ref args);
    //Test.add_func("/test_contact", testContact);
    //Test.add_func("/test_contact_name", testContactName);
    //Test.run();
  }
}
