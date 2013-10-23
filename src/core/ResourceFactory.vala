/*
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
      string pixmaps_folder = Path.build_filename(Tools.find_data_dir(), "pixmaps");
      string theme_folder = Path.build_filename(Tools.find_data_dir(), "theme");

      away = load_image(Path.build_filename(pixmaps_folder, "away.png"));
      away_glow = load_image(Path.build_filename(pixmaps_folder, "away_glow.png"));
      offline = load_image(Path.build_filename(pixmaps_folder, "offline.png"));
      offline_glow = load_image(Path.build_filename(pixmaps_folder, "offline_glow.png"));
      online = load_image(Path.build_filename(pixmaps_folder, "online.png"));
      online_glow = load_image(Path.build_filename(pixmaps_folder, "online_glow.png"));

      call = load_image(Path.build_filename(pixmaps_folder, "call.png"));
      call_video = load_image(Path.build_filename(pixmaps_folder, "call_video.png"));

      add = load_image(Path.build_filename(pixmaps_folder, "add.png"));
      groupchat = load_image(Path.build_filename(pixmaps_folder, "groupchat.png"));
      settings = load_image(Path.build_filename(pixmaps_folder, "settings.png"));
      
      default_image = load_image(Path.build_filename(pixmaps_folder, "default_image.png"));
      
      venom = load_image(Path.build_filename(pixmaps_folder, "venom.png"));
      arrow = load_image(Path.build_filename(pixmaps_folder, "arrow.png"));
      
      default_theme_filename = Path.build_filename(theme_folder, "default.css");
    }
    
    public Gdk.Pixbuf away {get; private set;}
    public Gdk.Pixbuf away_glow {get; private set;}
    public Gdk.Pixbuf offline {get; private set;}
    public Gdk.Pixbuf offline_glow {get; private set;}
    public Gdk.Pixbuf online {get; private set;}
    public Gdk.Pixbuf online_glow {get; private set;}

    public Gdk.Pixbuf call {get; private set;}
    public Gdk.Pixbuf call_video {get; private set;}

    public Gdk.Pixbuf add {get; private set;}
    public Gdk.Pixbuf groupchat {get; private set;}
    public Gdk.Pixbuf settings {get; private set;}

    public Gdk.Pixbuf default_image {get; private set;}
    
    public Gdk.Pixbuf venom {get; private set;}
    public Gdk.Pixbuf arrow {get; private set;}
    
    public string default_theme_filename {get; private set;}
    
    private Gdk.Pixbuf? load_image(string filename) {
      Gdk.Pixbuf? buf = null;
      try {
        buf = new Gdk.Pixbuf.from_file( filename );
      } catch (Error e) {
        stderr.printf("Error while loading image from \"%s\":%s\n", filename, e.message );
      }
      return buf;
    }
  }
}
