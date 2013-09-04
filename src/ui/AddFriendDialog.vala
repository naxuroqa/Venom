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

using Gtk;

namespace Venom {
  public class AddFriendDialog : Object{
    public Gtk.Dialog gtk_add_friend_dialog;
    private Gtk.Entry gtk_friend_id_entry;
    private Gtk.Entry gtk_friend_message_entry;
    private Gtk.Button gtk_button_ok;
    private Gtk.Image gtk_image_id;
    private Gtk.Image gtk_image_msg;
    public string friend_id {get; private set;}
    public string friend_msg {get; private set;}
    private bool id_ok = false;
    private bool msg_ok = false;

    public AddFriendDialog(Gtk.Dialog add_friend_dialog, Gtk.Entry friend_id_entry, 
                            Gtk.Entry friend_message, Gtk.Button button_ok, Gtk.Image img_id, Gtk.Image img_msg) {
      gtk_add_friend_dialog = add_friend_dialog;
      gtk_friend_id_entry = friend_id_entry;
      gtk_friend_message_entry = friend_message;
      gtk_button_ok = button_ok;
      gtk_image_id = img_id;
      gtk_image_msg = img_msg;
      friend_id = "";
      friend_msg = "";
    }

    ~AddFriendDialog() {
      gtk_add_friend_dialog.destroy();
    }

    [CCode (instance_pos = -1)] //DO NEVER FORGET ABOUT THIS!
    public void on_close(Gtk.Dialog source) {
      gtk_add_friend_dialog.response(ResponseType.CANCEL);
    }

    [CCode (instance_pos = -1)]
    public void on_button_ok_clicked(Object source) {
      if(msg_ok && id_ok)
        gtk_add_friend_dialog.response(ResponseType.OK);
    }

    [CCode (instance_pos = -1)]
    public void on_button_cancel_clicked(Gtk.Button source) {
      gtk_add_friend_dialog.response(ResponseType.CANCEL);
    }

    [CCode (instance_pos = -1)]
    public void on_text_changed(Object source) {
      friend_id = gtk_friend_id_entry.get_text();
      friend_msg = gtk_friend_message_entry.get_text();

      uint8[] binary_id = Tools.hexstring_to_bin(friend_id);
      if(binary_id != null && binary_id.length == Tox.FRIEND_ADDRESS_SIZE) {
        if(!id_ok)
          gtk_image_id.set_from_stock(Gtk.Stock.YES, IconSize.BUTTON);
        id_ok = true;
      } else {
        if(id_ok)
          gtk_image_id.set_from_stock(Gtk.Stock.NO, IconSize.BUTTON);
        id_ok = false;
      }

      if(friend_msg != null && friend_msg.length != 0) {
        if(!msg_ok)
          gtk_image_msg.set_from_stock(Gtk.Stock.YES, IconSize.BUTTON);
        msg_ok = true;
      } else {
        if(msg_ok)
          gtk_image_msg.set_from_stock(Gtk.Stock.YES, IconSize.BUTTON);
        msg_ok = false;
      }

      gtk_button_ok.set_sensitive(msg_ok && id_ok);
    }

    public static AddFriendDialog create() throws Error {
      Builder builder = new Builder();
      builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "add_friend_dialog.glade"));
      Gtk.Dialog dialog = builder.get_object("dialog") as Dialog;
      Gtk.Entry id_entry = builder.get_object("text_entry_friend_id") as Entry;
      Gtk.Entry msg_entry = builder.get_object("text_entry_friend_message") as Entry;
      Gtk.Button button_ok = builder.get_object("button_ok") as Button;
      Gtk.Image image_id = builder.get_object("image_id") as Image;
      Gtk.Image image_msg = builder.get_object("image_msg") as Image;
        
      AddFriendDialog add_friend_dialog = new AddFriendDialog(dialog, id_entry, msg_entry, button_ok, image_id, image_msg);
      builder.connect_signals(add_friend_dialog);
      return add_friend_dialog;
    }
  }
}
