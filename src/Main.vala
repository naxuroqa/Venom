/*
 *    Main.vala
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

public class Main {
    private static bool version = false;
    private static string? datafile = null;
    private const GLib.OptionEntry[] options = {
      { "datafile", 'n', 0, GLib.OptionArg.FILENAME, ref datafile, "Tox data file", "<file>" },
		  { "version", 'V', 0, OptionArg.NONE, ref version, "Display version number", null },
		  { null }
	  };

    public static int main (string[] args) {
      try {
		    GLib.OptionContext option_context = new GLib.OptionContext("");
		    option_context.set_help_enabled(true);
		    option_context.add_main_entries(options, null);
		    option_context.parse(ref args);
	    } catch (GLib.OptionError e) {
		    stdout.printf("error: %s\n", e.message);
		    stdout.printf("Run '%s --help' to see a full list of available command line options.\n", args[0]);
		    return -1;
	    }

	    if(version) {
	      stdout.printf("%s %s\n", args[0], Config.VERSION);
	      return 0;
	    }

	    if(datafile != null) {
	      stdout.printf("Using data file \"%s\"\n", datafile);
        ResourceFactory.instance.data_filename = datafile;
	    }

      return new Client().run(args);
    }
  }
}
