/*
 *    MockContact.vala
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

public class MockContact : IContact, GLib.Object {
  public string get_id() {
    return mock().actual_call(this, "get_id").get_string();
  }
  public string get_name_string() {
    return mock().actual_call(this, "get_name_string").get_string();
  }
  public string get_status_string() {
    return mock().actual_call(this, "get_status_string").get_string();
  }
  public UserStatus get_status() {
    return (UserStatus) mock().actual_call(this, "get_status").get_int();
  }
  public bool is_connected() {
    return mock().actual_call(this, "is_connected").get_bool();
  }
  public bool is_typing() {
    return mock().actual_call(this, "is_typing").get_bool();
  }
  public bool is_conference() {
    return mock().actual_call(this, "is_connected").get_bool();
  }
  public Gdk.Pixbuf get_image() {
    return (Gdk.Pixbuf) mock().actual_call(this, "get_image").get_object();
  }
  public bool get_requires_attention() {
    return mock().actual_call(this, "get_requires_attention").get_bool();
  }
  public void clear_attention() {
    mock().actual_call(this, "clear_attention");
  }
  public bool show_notifications() {
    return mock().actual_call(this, "show_notifications").get_bool();
  }
}
