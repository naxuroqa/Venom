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
  public class AboutDialog : Gtk.AboutDialog {
    public AboutDialog() {
      init_widgets();
    }
    
    private void init_widgets() {
      this.artists = {"naxuroqa", null};
      this.authors = {"naxuroqa", null};
      
      this.program_name = "Venom";
      this.comments = "GTK+/Vala GUI for Tox";
      this.copyright = "2013 (c) naxuroqa";
      this.version = Config.VENOM_VERSION;
      
      this.website = "https://github.com/naxuroqa/Venom";
      
      this.wrap_license = true;
      this.license = 
        "This program is free software: you can redistribute it and/or modify " +
        "it under the terms of the GNU General Public License as published by " +
        "the Free Software Foundation, either version 3 of the License, or " +
        "(at your option) any later version.\n\n" +
        "This program is distributed in the hope that it will be useful, " +
        "but WITHOUT ANY WARRANTY; without even the implied warranty of " +
        "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the " +
        "GNU General Public License for more details.\n\n" +
        "You should have received a copy of the GNU General Public License " +
        "along with this program.  If not, see <http://www.gnu.org/licenses/>";
      this.resizable = true;
    }
  }
}
