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

public class Main {
    private static string bin_name;
    private static void set_data_filename(string filename) {
      if(filename == null)
        return;
      stdout.printf("Using data file \"%s\"\n", filename);
      ResourceFactory.instance.data_filename = filename;
    }
    
    private static void print_usage() {
      stdout.printf(
        "Usage: %s [OPTION...]\n" +
        "Options:\n" +
        "  -n <file>            Use <file> as datafile\n" +
        "  -?, --help           Display this help\n" +
        "  -V, --version        Print version information\n"
        , bin_name
        );
    }

    private static void print_version() {
      stdout.printf("%s %s\n", bin_name, Config.VENOM_VERSION);
    }
    
    private static void print_unsupported(string arg) {
      stderr.printf("Argument \"%s\" not recognized.\n", arg);
    }
    
    private static void print_too_few_args(string arg) {
      stderr.printf("Too few arguments for \"%s\".\n", arg);
    }

    private static int parse_args(string[] args) {
      bin_name = args[0];
      for(int i = 1; i < args.length; ++i) {
        if(args[i] == "-n") {
          if((i + 1) >= args.length) {
            print_too_few_args(args[i]);
            return -1;
          }
          set_data_filename(args[++i]);
        } else if(args[i] == "-?" || args[i] == "--help") {
          print_usage();
          return 1;
        } else if(args[i] == "-V" || args[i] == "--version") {
          print_version();
          return 1;
        } else {
          print_unsupported(args[i]);
          return -2;
        }
      }
      return 0;
    }    
    
    public static int main (string[] args) {

      // Parse args and 
      int ret = parse_args(args);
      if(ret < 0) {
        print_usage();
        return ret;
      } else if(ret > 0) {
        return 0;
      }

      return new Client().run(args);
    }
  }
}
