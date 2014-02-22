/*
 *    VenomSettings.vala
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
  public class VenomSettings : Object {

    public bool enable_logging{get;set;}
    public bool enable_urgency_notification{get;set;}
    public int days_to_log{get;set;}
    public bool dec_binary_prefix{get;set;}

    private static VenomSettings? _instance;
    public static VenomSettings instance {
      get {
        if( _instance == null ) {
          File tmp = File.new_for_path(ResourceFactory.instance.config_filename);
          if (tmp.query_exists()) {
            _instance = new VenomSettings.with_settings_file(ResourceFactory.instance.config_filename);
          } else {
            _instance = new VenomSettings();
            _instance.save_setting(ResourceFactory.instance.config_filename);
          }
        }
        return _instance;
      }
      private set {
        _instance = value;
      }
    }

    public void save_setting(string path_to_file) {
      Json.Node root = Json.gobject_serialize (this);

      Json.Generator generator = new Json.Generator ();
      generator.set_root (root);

      try {
        generator.to_file (path_to_file);
      } catch (Error e) {
        stderr.printf("Error saving configs:%s\n",e.message);
        return;
      }
    }

    private VenomSettings() {
      enable_urgency_notification = true;
      enable_logging = false;
      this.days_to_log = 180;
      dec_binary_prefix = true;
    }

    private VenomSettings.with_settings(VenomSettings other) {
      this.enable_urgency_notification = other.enable_urgency_notification;
      this.enable_logging = other.enable_logging;
      this.days_to_log = other.days_to_log;
      this.dec_binary_prefix = other.dec_binary_prefix;
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
