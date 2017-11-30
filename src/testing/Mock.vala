/*
 *    Mock.vala
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

namespace Mock {
  public class MockLogger : ILogger, Object {
    public MockLogger() {
    }
    public void d(string message) {
      mock().actual_call(this, "d");
    }
    public void i(string message) {
      mock().actual_call(this, "i");
    }
    public void w(string message) {
      mock().actual_call(this, "w");
    }
    public void e(string message) {
      mock().actual_call(this, "e");
    }
    public void f(string message) {
      mock().actual_call(this, "f");
    }
    public void attach_to_glib() {
      mock().actual_call(this, "attach_to_glib");
    }
  }
}
