/*
 *    Main.vala
 *
 *    Copyright (C) 2013-2017  Venom authors and contributors
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
      { "file", 'f', 0, OptionArg.FILENAME, ref datafile, "Set the location of the tox data file", "<file>" },
      { "loglevel", 'l', 0, OptionArg.CALLBACK, (void *) parse_loglevel, "Set level of messages to log", "<loglevel>" },
      { "offline", 0, 0, OptionArg.NONE, ref offline, "Start in offline mode", null },
      { "textview", 0, 0, OptionArg.NONE, ref textview, "Use textview to display messages", null },
      { "version", 'V', 0, OptionArg.NONE, ref version, "Display version number", null },
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
        throw new OptionError.BAD_VALUE(_("'%s' not a positive number"), val);
      }
      Logger.displayed_level = (LogLevel) int.parse(val);
      return true;
    }

    public static int main (string[] args) {
      GLib.Intl.setlocale(GLib.LocaleCategory.MESSAGES, "");
      GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);
      GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "utf-8");
      //FIXME see if this is needed on windows
      //GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.GETTEXT_PATH);
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

/*
      if(datafile != null) {
        Logger.log(LogLevel.INFO, "Using data file \"" + datafile + "\"");
        R.strings.data_filename = datafile;
      }

      if(textview) {
        Logger.log(LogLevel.INFO, "Using Gtk.TextView to display messages");
        ResourceFactory.instance.textview_mode = true;
      }

      if(offline) {
        Logger.log(LogLevel.INFO, "Starting in offline mode");
        ResourceFactory.instance.offline_mode = true;
      }*/

      return new Application().run(args);
    }
  }
}
