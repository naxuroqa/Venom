/*
 *    Main.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  public class Main : GLib.Object {
    private static string? datafile = null;
    private static bool offline = false;
    private static bool textview = false;
    private static bool version = false;
    private const OptionEntry[] option_entries = {
      { "loglevel", 'l', 0, OptionArg.CALLBACK, (void *) parse_loglevel, N_("Set level of messages to log"), N_("<loglevel>") },
      { "version", 'V', 0, OptionArg.NONE, ref version, N_("Display version number"), null },
      { null }
    };

    public static bool parse_loglevel (string name, string? val, ref OptionError error) throws OptionError {
      if (val == null) {
        return true;
      }
      Regex regex;
      try {
        regex = new GLib.Regex("^[0-9]+$");
      } catch {
        Logger.log(LogLevel.FATAL, "could not create regex needed for number parsing");
        return true;
      }

      if (!regex.match(val, 0, null)) {
        throw new OptionError.BAD_VALUE("'%s' not a positive number", val);
      }
      Logger.displayed_level = (LogLevel) int.parse(val);
      return true;
    }

    public static int main (string[] args) {
      GLib.Intl.setlocale(GLib.LocaleCategory.ALL, "");
      GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.GETTEXT_PATH);
      GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "utf-8");
      GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);

      GLib.OptionContext option_context = new GLib.OptionContext("");
      option_context.set_help_enabled(true);
      option_context.add_main_entries(option_entries, null);
      try {
        option_context.parse(ref args);
      } catch (GLib.OptionError e) {
        stdout.printf(_("error: %s\n"), e.message);
        stdout.printf(_("Run '%s --help' to see a full list of available command line options.\n"), args[0]);
        return -1;
      }

      if (version) {
        stdout.printf("%s %s\n", args[0], Config.VERSION);
        return 0;
      }

      return new Application().run(args);
    }
  }
}
