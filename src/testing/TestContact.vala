/*
 *    TestContact.vala
 *
 *    Copyright (C) 2017-2018 Venom authors and contributors
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

  private static void testContact() {
    var public_key = new uint8[ToxCore.public_key_size()];
    var contact = new Contact(1, "id");
    assert(contact.tox_friend_number == 1);

    assert(contact.get_id() == "id");
    assert(contact.get_name_string() == "id");
    assert(contact.get_status_string() == "");
    assert(contact.get_status() == UserStatus.OFFLINE);
  }

  private static void testContactName() {
    var contact = new Contact(0, "");
    contact.name = "name";
    assert(contact.name == "name");
    assert(contact.get_name_string() == "name");
  }

  private static int main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_contact", testContact);
    Test.add_func("/test_contact_name", testContactName);
    Test.run();
    return 0;
  }
}
