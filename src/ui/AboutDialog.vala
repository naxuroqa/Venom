/*
 *    AboutDialog.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
        "John Poulakos <jhn1291@gmail.com>",
        "Denys Han <h.denys@gmail.com>",
        "Andrii Titov <concuror@gmail.com>",
        "notsecure <notsecure@marek.ca>",
        "Fukukami",
        "Mario Daniel Ruiz Saavedra <desiderantes@rocketmail.com>",
        "fshp <franchesko.salias.hudro.pedros@gmail.com>",
        "Bahkuh <philip_hq@hotmail.com>",
        "Joel Leclerc <lkjoel@ubuntu.com>",
        "infirit <infirit@gmail.com>",
        "Maxim Golubev <3demax@gmail.com>",
        null
      };
      artists = {
        "ItsDuke <anondelivers.org@gmail.com>",
        null
      };
      string [] packagers = {
        "Sean <sean@tox.im>",
        null
      };
      this.add_credit_section(_("Packagers"), packagers);
      comments = Config.SHORT_DESCRIPTION;
      copyright = Config.COPYRIGHT_NOTICE;
      license_type = Gtk.License.GPL_3_0;
      program_name = "Venom";
      translator_credits = _("translator-credits");
      version = Config.VERSION;
      website = Config.WEBSITE;
    }
  }
}
