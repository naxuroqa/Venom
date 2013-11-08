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
      stdout.printf("Using data file at %s\n", filename);
      ResourceFactory.instance.data_filename = filename;
    }
    
    private static void print_help() {
      stdout.printf(
        "Usage:\n" +
        "\t%s -h\n" +
        "\t%s -n <data filename>\n"
        , bin_name, bin_name
        );
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
        } else if(args[i] == "-h") {
          return 0;
        } else {
          print_unsupported(args[i]);
          return -2;
        }
      }
      return 1;
    }    
    
    public static int main (string[] args) {

      // Parse args and 
      int ret = parse_args(args);
      if(ret < 1) {
        print_help();
        return ret;
      }
    
      Client client = new Client(args);
      client.main();
      return 0;
    }
  }
}
