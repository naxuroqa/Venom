/*
 *    Client.vala
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
  class Client : Gtk.Application {
    public Client() {
      // call gobject base constructor
      GLib.Object(
        application_id: "im.tox.venom",
        flags: GLib.ApplicationFlags.HANDLES_OPEN
      );
    }
    private ContactListWindow get_contact_list_window() {
      if(get_windows().length() > 0)
        return get_windows().data as ContactListWindow;
      else
        return new ContactListWindow(this);
    }

    protected override void activate() {
      get_contact_list_window().present();
    }

    protected override void open(GLib.File[] files, string hint) {
      hold();
      ContactListWindow contact_list_window = get_contact_list_window();
      contact_list_window.present();

      Regex r = null;
      try {
        r = new Regex("^.*tox:/?/?/(?P<contact_id>[[:xdigit:]]*)/?$");
      } catch (GLib.RegexError e) {
        stderr.printf("Can't create regex to parse uri: %s.\n", e.message);
      }
      string uri = files[0].get_uri();
      stdout.printf("Matching uri \"%s\"\n", uri);
      GLib.MatchInfo info = null;
      if(r != null && r.match(uri, 0, out info)) {
        string contact_id_string = info.fetch_named("contact_id");
        stdout.printf("Adding contact \"%s\".\n", contact_id_string);
        contact_list_window.add_contact(contact_id_string);
      } else {
        stdout.printf("Invalid uri or contact id: %s\n", uri);
      }

      release();
    }
  }
}
