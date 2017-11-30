/*
 *    TestAbout.vala
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

namespace TestAbout {

  private static void testGtk() {
    var widget = new Gtk.Button();
    assert(widget is Gtk.Button);
  }

  private static void testAbout() {
    var widget = new Venom.AboutDialog(new Mock.MockLogger());
    assert(widget is Gtk.AboutDialog);
  }

  private static void testAboutText() {
    var widget = new Venom.AboutDialog(new Mock.MockLogger());
    assert(widget.authors != null);
    assert(widget.artists != null);
    assert(widget.comments == Config.SHORT_DESCRIPTION);
    assert(widget.translator_credits != null);
    assert(widget.copyright == Config.COPYRIGHT_NOTICE);
    assert(widget.license_type == Gtk.License.GPL_3_0);
    assert(widget.logo == null);
  }

  private static int main(string[] args) {
    Test.init(ref args);

    if (!Test.slow()) {
      return 77;
    }

    Gtk.init(ref args);

    Test.add_func("/test_gtk", testGtk);
    Test.add_func("/test_about", testAbout);
    Test.add_func("/test_about_text", testAboutText);

    Idle.add(() => {
      Test.run();
      Gtk.main_quit();
      return false;
    });

    Gtk.main();
    return 0;
  }
}
