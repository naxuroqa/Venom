/*
 *    TestAbout.vala
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

public class TestAbout : UnitTest {
  private Logger logger;

  public TestAbout() {
    add_func("/test_gtk", test_gtk);
    add_func("/test_about", test_about);
    add_func("/test_about_text", test_about_text);
  }

  public override void set_up() throws Error {
    logger = new MockLogger();
  }

  private void test_gtk() throws Error {
    var widget = new Gtk.Button();
    Assert.assert_true(widget is Gtk.Button);
  }

  private void test_about() throws Error {
    var widget = new Venom.AboutDialog(logger);
    Assert.assert_true(widget is Gtk.AboutDialog);
  }

  private void test_about_text() throws Error {
    var widget = new Venom.AboutDialog(logger);
    Assert.assert_not_null(widget.authors);
    Assert.assert_not_null(widget.artists);
    Assert.assert_not_null(widget.translator_credits);
    Assert.assert_equals<uint>(widget.license_type, Gtk.License.GPL_3_0);
    Assert.assert_null(widget.logo);
  }

  private static int main(string[] args) {
    Test.init(ref args);

    if (!Test.slow()) {
      return 77;
    }

    Gtk.init(ref args);

    Idle.add(() => {
      var test = new TestAbout();
      Test.run();
      Gtk.main_quit();
      return false;
    });

    Gtk.main();
    return 0;
  }
}
