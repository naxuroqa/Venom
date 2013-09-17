/*
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

namespace Venom {

public class Main {
    public static int main (string[] args) {

      Gtk.init (ref args);
      
      string cssdata = "
      GtkWindow {
        background-color: #231f20;
      }";
      
      Gtk.CssProvider provider = new Gtk.CssProvider();
      provider.load_from_data(cssdata, cssdata.length);
      
      
      Gdk.Screen screen = Gdk.Screen.get_default();
      
      
      Gtk.StyleContext context = new Gtk.StyleContext();
      context.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

      ContactListWindow contact_list = new ContactListWindow();
      contact_list.show_all();

      Gtk.main();
      
      stdout.printf("Shutting down...\n");

      return 0;
    }
  }
}
