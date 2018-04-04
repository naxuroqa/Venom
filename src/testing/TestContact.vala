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
using Mock;
using Testing;

public class TestContact : UnitTest {
  public TestContact() {
    add_func("/test_contact", test_contact);
    add_func("/test_contact_name", test_contact_name);
  }

  private static void test_contact() throws Error {
    var public_key = new uint8[ToxCore.public_key_size()];
    var contact = new Contact(1, "id");
    Assert.assert_true(contact.tox_friend_number == 1);

    Assert.assert_true(contact.get_id() == "id");
    Assert.assert_true(contact.get_name_string() == "id");
    Assert.assert_true(contact.get_status_string() == "");
    Assert.assert_true(contact.get_status() == UserStatus.OFFLINE);
  }

  private static void test_contact_name() throws Error {
    var contact = new Contact(0, "");
    contact.name = "name";
    Assert.assert_true(contact.name == "name");
    Assert.assert_true(contact.get_name_string() == "name");
  }

  private static int main(string[] args) {
    Test.init(ref args);
    var test = new TestContact();
    Test.run();
    return 0;
  }
}
