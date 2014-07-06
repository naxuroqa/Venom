/*
 *    Settings.vala
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
  public class Settings : Object {

    public const string MESSAGE_LOGGING_KEY = "enable-logging";
    public const string DAYS_TO_LOG_KEY = "days-to-log";
    public const string URGENCY_NOTIFICATION_KEY = "enable-urgency-notification";
    public const string DEC_BINARY_PREFIX_KEY = "dec-binary-prefix";
    public const string SEND_TYPING_STATUS_KEY = "send-typing-status";
    public const string SHOW_TYPING_STATUS_KEY = "show-typing-status";
    public const string DEFAULT_HOST_KEY = "default-host";

    public bool   enable_logging              { get; set; default = false;     }
    public bool   enable_urgency_notification { get; set; default = true;      }
    public int    days_to_log                 { get; set; default = 180;       }
    public bool   dec_binary_prefix           { get; set; default = true;      }
    public bool   send_typing_status          { get; set; default = false;     }
    public bool   show_typing_status          { get; set; default = true;      }
    public int    contactlist_width           { get; set; default = 200;       }
    public int    contactlist_height          { get; set; default = 600;       }
    public int    window_width                { get; set; default = 600;       }
    public int    window_height               { get; set; default = 600;       }
    public string default_host                { get; set; default = "toxme.se";}
    public bool enable_tray                   { get; set; default = false;}

    private static Settings? _instance;
    public static Settings instance {
      get {
        if( _instance == null ) {
          File tmp = File.new_for_path(ResourceFactory.instance.config_filename);
          if (tmp.query_exists()) {
            _instance = load_settings(ResourceFactory.instance.config_filename);
          } else {
            _instance = new Settings();
            _instance.save_settings(ResourceFactory.instance.config_filename);
          }
        }
        return _instance;
      }
      private set {
        _instance = value;
      }
    }

    private Settings() {
    }

    private string filepath;
    private bool timeout_started;
    private bool timeout_function() {
      // save only if not saved previously
      if( timeout_started ) {
        save_settings(filepath);
      }
      return false;
    }

    public void save_settings_with_timeout(string path_to_file) {
      // only add timeout function once
      if( !timeout_started ) {
        timeout_started = true;
        filepath = path_to_file;
        Timeout.add_seconds(1, timeout_function);
      }
    }

    public void save_settings(string path_to_file) {
      timeout_started = false;
      Json.Node root = Json.gobject_serialize (this);

      Json.Generator generator = new Json.Generator ();
      generator.set_root (root);
      generator.pretty = true;

      File file = File.new_for_path(path_to_file);
      try {
        DataOutputStream os = new DataOutputStream(file.replace(null, false, FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION ));
        generator.to_stream(os);
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error saving configs: " + e.message);
        return;
      }
      Logger.log(LogLevel.INFO, "Settings saved.");
    }

    public static Settings? load_settings(string path) {
      Json.Node node;
      try {
        Json.Parser parser = new Json.Parser();
        parser.load_from_file(path);
        node = parser.get_root();
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error reading configs: " + e.message);
        return null;
      }
      return Json.gobject_deserialize (typeof (Settings), node) as Settings;
    }
  }
}
