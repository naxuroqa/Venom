/*
 *    ResourceFactory.vala
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
  public class ResourceFactory : GLib.Object{

    private static ResourceFactory? _instance;
    public static ResourceFactory instance {
      get {
        if( _instance == null )
          _instance = new ResourceFactory();
        return _instance;
      }
      private set {
        _instance = value;
      }
    }

    private ResourceFactory () {
      string pixmaps_prefix = "/org/gtk/venom/pixmaps/";
      string theme_folder = Path.build_filename(Tools.find_data_dir(), "theme");

      away = load_image_from_resource(pixmaps_prefix + "away.png");
      away_glow = load_image_from_resource(pixmaps_prefix + "away_glow.png");
      busy = load_image_from_resource(pixmaps_prefix + "busy.png");
      busy_glow = load_image_from_resource(pixmaps_prefix + "busy_glow.png");
      offline = load_image_from_resource(pixmaps_prefix + "offline.png");
      offline_glow = load_image_from_resource(pixmaps_prefix + "offline_glow.png");
      online = load_image_from_resource(pixmaps_prefix + "online.png");
      online_glow = load_image_from_resource(pixmaps_prefix + "online_glow.png");

      call = load_image_from_resource(pixmaps_prefix + "call.png");
      call_video = load_image_from_resource(pixmaps_prefix + "call_video.png");
      send_file = load_image_from_resource(pixmaps_prefix + "send_file.png");

      add = load_image_from_resource(pixmaps_prefix + "add.png");
      groupchat = load_image_from_resource(pixmaps_prefix + "groupchat.png");
      settings = load_image_from_resource(pixmaps_prefix + "settings.png");

      default_contact = load_image_from_resource(pixmaps_prefix + "default_contact.png");
      default_groupchat = load_image_from_resource(pixmaps_prefix + "default_groupchat.png");
      arrow = load_image_from_resource(pixmaps_prefix + "arrow.png");

      default_theme_filename = Path.build_filename(theme_folder, "default.css");


      tox_config_dir = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");
      data_filename = Path.build_filename(tox_config_dir, "data");
      db_filename = Path.build_filename(tox_config_dir, "tox.db");
      config_filename = Path.build_filename(tox_config_dir, "config.json");

      default_add_contact_message = "Please let me add you to my contactlist.";
      default_username = "Tox User";
    }


    public Gdk.Pixbuf away {get; private set;}
    public Gdk.Pixbuf away_glow {get; private set;}
    public Gdk.Pixbuf busy {get; private set;}
    public Gdk.Pixbuf busy_glow {get; private set;}
    public Gdk.Pixbuf offline {get; private set;}
    public Gdk.Pixbuf offline_glow {get; private set;}
    public Gdk.Pixbuf online {get; private set;}
    public Gdk.Pixbuf online_glow {get; private set;}

    public Gdk.Pixbuf call {get; private set;}
    public Gdk.Pixbuf call_video {get; private set;}
    public Gdk.Pixbuf send_file {get; private set;}

    public Gdk.Pixbuf add {get; private set;}
    public Gdk.Pixbuf groupchat {get; private set;}
    public Gdk.Pixbuf settings {get; private set;}

    public Gdk.Pixbuf default_contact {get; private set;}
    public Gdk.Pixbuf default_groupchat {get; private set;}

    public Gdk.Pixbuf arrow {get; private set;}

    public string default_theme_filename {get; private set;}
    public string tox_config_dir {get; private set;}
    public string data_filename {get; set;}
    public string db_filename {get; set;}
    public string config_filename {get; set;}
    public string default_add_contact_message {get; private set;}
    public string default_username {get; private set;}

    public bool offline_mode {get; set; default = false;}
    public bool textview_mode {get; set; default = false;}

    private Gdk.Pixbuf? load_image_from_resource(string resourcename) {
      Gdk.Pixbuf buf = null;
      try {
        buf = new Gdk.Pixbuf.from_resource( resourcename );
      } catch (Error e) {
        stderr.printf("Error while loading image from \"%s\":%s\n", resourcename, e.message );
      }
      return buf;
    }
  }
}
