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
      string data_dir = Tools.find_data_dir();
      theme_directory = Path.build_filename(data_dir, "theme");
      sounds_directory = Path.build_filename(data_dir, "sounds");

      arrow      = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/arrow_white.png");
      send_file  = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/attach.png");
      call       = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/call.png");
      ok         = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/check.png");
      smiley     = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/emoticon.png");
      cancel     = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/no.png");
      send       = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/sendmessage.png");
      call_video = load_image_from_resource("/org/gtk/venom/pixmaps/button_icons/video.png");

      add          = load_image_from_resource("/org/gtk/venom/pixmaps/contact_list_icons/add.png");
      groupchat    = load_image_from_resource("/org/gtk/venom/pixmaps/contact_list_icons/group.png");
      settings     = load_image_from_resource("/org/gtk/venom/pixmaps/contact_list_icons/settings.png");
      filetransfer = load_image_from_resource("/org/gtk/venom/pixmaps/contact_list_icons/transfer.png");

      away         = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_idle.png");
      away_glow    = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_idle_notification.png");
      busy         = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_busy.png");
      busy_glow    = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_busy_notification.png");
      offline      = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_away.png");
      offline_glow = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_away_notification.png");
      online       = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_online.png");
      online_glow  = load_image_from_resource("/org/gtk/venom/pixmaps/status/dot_online_notification.png");

      default_contact   = load_image_from_resource("/org/gtk/venom/pixmaps/user_icons/default_contact.png");
      default_groupchat = load_image_from_resource("/org/gtk/venom/pixmaps/user_icons/default_groupchat.png");

      default_theme_filename = Path.build_filename(theme_directory, "default.css");


      tox_config_dir = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");
      data_filename = Path.build_filename(tox_config_dir, "data");
      db_filename = Path.build_filename(tox_config_dir, "tox.db");
      config_filename = Path.build_filename(tox_config_dir, "config.json");

      default_username = _("Tox User");
      default_statusmessage = _("Toxing on Venom v.%s").printf(Config.VERSION);
    }

    public Gdk.Pixbuf ok {get; private set;}
    public Gdk.Pixbuf cancel {get; private set;}

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
    public Gdk.Pixbuf send {get; private set;}

    public Gdk.Pixbuf send_file {get; private set;}
    public Gdk.Pixbuf smiley {get; private set;}

    public Gdk.Pixbuf add {get; private set;}
    public Gdk.Pixbuf groupchat {get; private set;}
    public Gdk.Pixbuf settings {get; private set;}
    public Gdk.Pixbuf filetransfer {get; private set;}

    public Gdk.Pixbuf default_contact {get; private set;}
    public Gdk.Pixbuf default_groupchat {get; private set;}

    public Gdk.Pixbuf arrow {get; private set;}

    public string sounds_directory {get; set;}
    public string theme_directory {get; set;}
    public string default_theme_filename {get; private set;}
    public string tox_config_dir {get; private set;}
    public string data_filename {get; set;}
    public string db_filename {get; set;}
    public string config_filename {get; set;}
    public string default_username {get; private set;}
    public string default_statusmessage {get; private set;}

    public bool offline_mode {get; set; default = false;}
    public bool textview_mode {get; set; default = false;}

    private Gdk.Pixbuf? load_image_from_resource(string resourcename) {
      Gdk.Pixbuf buf = null;
      try {
        buf = new Gdk.Pixbuf.from_resource( resourcename );
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error while loading image from \"" + resourcename + "\": " + e.message);
      }
      return buf;
    }
  }
}
