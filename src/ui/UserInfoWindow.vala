/*
 *    UserInfoWindow.vala
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
    public string user_id {
      set { label_id.set_text(value); }
      get { return label_id.get_text(); }
    }
    public int max_name_length {
      get { return entry_username.max_length; }
      set { entry_username.max_length = value; }
    }
    public int max_status_length {
      get { return entry_statusmessage.max_length; }
      set { entry_statusmessage.max_length = value; }
    }

    private Gtk.Entry entry_username;
    private Gtk.Entry entry_statusmessage;
    private Gtk.Image image_userimage;
    private Gtk.Label label_id;

    public UserInfoWindow() {
      init_widgets();
    }

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/user_info_window.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading user info window failed!\n");
      }
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.get_content_area().add(box);

      entry_username = builder.get_object("entry_username") as Gtk.Entry;
      entry_statusmessage = builder.get_object("entry_statusmessage") as Gtk.Entry;
      image_userimage = builder.get_object("image_userimage") as Gtk.Image;
      label_id = builder.get_object("label_id") as Gtk.Label;

      Gtk.Button button_copy_id = builder.get_object("button_copy_id") as Gtk.Button;
      button_copy_id.clicked.connect(() => {
        Gdk.Display display = get_display();
        Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD).set_text(user_id, -1);
        Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_PRIMARY).set_text(user_id, -1);
      });

      this.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Apply", Gtk.ResponseType.APPLY, null);
      this.set_default_response(Gtk.ResponseType.APPLY);
      this.title = "Edit user information";
      // set dialog to minimal size
      set_default_size(0, 0);
    }
  }
}
