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
  public class VenomSettings : Object {

    public bool enable_logging{get;set;}

    private static VenomSettings? _instance;
    public static VenomSettings instance {
      get {
        if( _instance == null )
          _instance = new VenomSettings.with_settings_file(ResourceFactory.instance.config_filename);
        return _instance;
      }
      private set {
        _instance = value;
      }
    }

    private VenomSettings() {
      enable_logging = false;
    }

    private VenomSettings.with_settings(VenomSettings other) {
      this.enable_logging = other.enable_logging;
    }

    public VenomSettings.with_settings_file(string path_to_file) {
      Json.Node node;
      try {
        Json.Parser parser = new Json.Parser();
        parser.load_from_file(path_to_file);
        node = parser.get_root();
      } catch (Error e) {
        stderr.printf("Error reading configs:%s\n",e.message);
        return;
      }
      VenomSettings tmp = Json.gobject_deserialize (typeof (VenomSettings), node) as VenomSettings;
      assert(tmp != null);
      this.with_settings(tmp);
    }
  }
}