/*
 *    Copyright (C) 2013 Venom authors and contributors
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
namespace Venom {
  public class AboutDialog : Gtk.AboutDialog {
    public AboutDialog() {
      authors = {
                  "naxuroqa <naxuroqa@gmail.com>",
                  "Denys Han <h.denys@gmail.com>",
                  "Andrii Titov <concuror@gmail.com>",
                  null
                };
      comments = "GTK+/Vala GUI for Tox";
      copyright = "Copyright © 2013-2014 Venom authors and contributors";
      program_name = "Venom";
      version = Config.VENOM_VERSION;
      website = "https://github.com/naxuroqa/Venom";
      license_type = Gtk.License.GPL_3_0;
    }
  }
}
