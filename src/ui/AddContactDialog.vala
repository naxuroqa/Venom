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
  public class AddContactDialog : Gtk.Dialog{
    public string contact_id {
      get { return entry_contact_id.get_text(); }
      set { entry_contact_id.set_text(value); }
    }
    public string contact_message {
      owned get { return textview_contact_message.buffer.text; }
      set { textview_contact_message.buffer.text = value; }
    }
    
    private Gtk.Entry entry_contact_id;
    private Gtk.TextView textview_contact_message;
    
    public AddContactDialog() {
      init_widgets();
    }
    
    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "add_contact_dialog.glade"));
      } catch (GLib.Error e) {
        stderr.printf("Loading add contact window failed!\n");
      }
      
      Gtk.Grid grid = builder.get_object("grid") as Gtk.Grid;
      this.get_content_area().add(grid);

      entry_contact_id = builder.get_object("entry_contact_id") as Gtk.Entry;
      textview_contact_message = builder.get_object("textview_contact_message") as Gtk.TextView;

      Gtk.Image image_default = builder.get_object("image_default") as Gtk.Image;
      image_default.set_from_pixbuf(ResourceFactory.instance.default_contact);

      this.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Ok", Gtk.ResponseType.OK, null);
      this.set_default_response(Gtk.ResponseType.OK);
      this.title = "Add contact";
      this.set_default_size(400, 250);
      
      contact_message = "Please let me add you to my contactlist.";
    }
  }
}
