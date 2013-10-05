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
  public class UserInfoWindow : Gtk.Dialog {
    public string user_name {
      get { return entry_username.get_text(); }
      set { entry_username.set_text(value); }
    }
    public string user_status {
      get { return entry_statusmessage.get_text(); }
      set { entry_statusmessage.set_text(value); }
    }
    public Gdk.Pixbuf user_image {
      get { return image_userimage.get_pixbuf(); }
      set { image_userimage.set_from_pixbuf(value); }
    }
    
    private Gtk.Entry entry_username;
    private Gtk.Entry entry_statusmessage;
    private Gtk.Image image_userimage;
    
    public UserInfoWindow() {
      init_widgets();
    }
    
    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "user_info_window.glade"));
      } catch (GLib.Error e) {
        stderr.printf("Loading user info window failed!\n");
      }
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.get_content_area().add(box);
      
      entry_username = builder.get_object("entry_username") as Gtk.Entry;
      entry_statusmessage = builder.get_object("entry_statusmessage") as Gtk.Entry;
      image_userimage = builder.get_object("image_userimage") as Gtk.Image;
      
      this.add_buttons(Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL, Gtk.Stock.APPLY, Gtk.ResponseType.APPLY, null);
      this.set_default_response(Gtk.ResponseType.APPLY);
    }
  }
}
