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
using Gee;
namespace Venom {
  public class ContactList : Object {
    private HashMap<int, Contact> contacts;
    private ToxSession session;

    private Window contact_list_window;
    private Image image_status;

    private string data_filename = "data";
    private string data_pathname = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");
    private uint8[] my_id;

    public ContactList( Window contact_list_window, Image image_status ) {
      this.contacts = new HashMap<int, Contact>();
      this.contact_list_window = contact_list_window;
      this.image_status = image_status;

      this.contact_list_window.destroy.connect (Gtk.main_quit);
      
      session = new ToxSession();
      try {
        session.load_from_file(data_pathname, data_filename);
        stdout.printf("Successfully loaded messenger data.\n");
      } catch (Error e) {
        try {
          session.save_to_file(data_pathname, data_filename);
        } catch (Error e) {
          stderr.printf("Could not load messenger data and failed to create new one\n");
        }
      }
      session.on_friendrequest.connect(this.on_friendrequest);
      session.on_friendmessage.connect(this.on_friendmessage);
      session.on_action.connect(this.on_action);
      session.on_namechange.connect(this.on_namechange);
      session.on_statusmessage.connect(this.on_statusmessage);
      session.on_userstatus.connect(this.on_userstatus);
      session.on_read_receipt.connect(this.on_read_receipt);
      session.on_connectionstatus.connect(this.on_connectionstatus);

      session.on_ownconnectionstatus.connect(this.on_ownconnectionstatus);

      my_id = session.get_address(); //TODO set label to this information
      session.start();
    }

    ~ContactList() {
      session.stop();
      // wait for background thread to finish
      session.join();

      // Save session before shutdown
      // session.save_to_file("data");
      stdout.printf("Session ended gracefully.\n");
    }

    // Session Signal callbacks
    private void on_friendrequest(uint8[] public_key, string message) {
      string public_key_string = Tools.bin_to_hexstring(public_key);
      stdout.printf("[fr] %s:%s\n", public_key_string, message);

      Gtk.MessageDialog messagedialog = new Gtk.MessageDialog (contact_list_window,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.YES_NO,
                                  "New friend request from %s.\n\nMessage: %s\nDo you want to accept?".printf(public_key_string, message));

		  int response = messagedialog.run();
      if(response == ResponseType.YES) {
        Tox.FriendAddError far = session.addfriend_norequest(public_key);
        if((int)far >= 0) {
          stdout.printf("Added new Friend #%i\n", (int)far);
          contacts[(int)far] = new Contact(public_key);
        }
      }
      messagedialog.destroy();
    }
    private void on_friendmessage(int friend_number, string message) {
      stdout.printf("<%s> %s:%s\n", new DateTime.now_local().format("%F"), contacts[friend_number].name, message);
    }
    private void on_action(int friend_number, string action) {
      stdout.printf("[ac] %i:%s\n", friend_number, action);
    }
    private void on_namechange(int friend_number, string new_name) {
      stdout.printf("%s changed his name to %s\n", contacts[friend_number].name, new_name);
      contacts[friend_number].name = new_name;
    }
    private void on_statusmessage(int friend_number, string status_message) {
      stdout.printf("%s changed his status to %s\n", contacts[friend_number].name, status_message);
      contacts[friend_number].status_message = status_message;
    }
    private void on_userstatus(int friend_number, int user_status) {
      stdout.printf("[us] %s:%i\n", contacts[friend_number].name, user_status);
      contacts[friend_number].user_status = (Tox.UserStatus)user_status;
    }
    private void on_read_receipt(int friend_number, uint32 receipt) {
      stdout.printf("[rr] %s:%u\n", contacts[friend_number].name, receipt);
    }
    private void on_connectionstatus(int friend_number, bool status) {
      stdout.printf("%s is now %s.\n", contacts[friend_number].name, status ? "online" : "offline");
      if(!status)
        contacts[friend_number].last_seen = new DateTime.now_local();
    }

    private void on_ownconnectionstatus(bool status) {
      if(status) {
        image_status.set_from_stock(Stock.YES, IconSize.BUTTON);
      } else {
        image_status.set_from_stock(Stock.NO, IconSize.BUTTON);
      }
    }

    // GUI Events
    [CCode (instance_pos = -1)]
    public void button_userimage_clicked(Object source) {
      //TODO
    }

    [CCode (instance_pos = -1)]
    public void entry_username_activated(Gtk.Entry source) {
      string username = source.get_text();
      if( session.setname(username) == 0)
        stdout.printf("Name changed to %s\n", username);
      // TODO remove focus
      // TODO set entry max to maxnamelength
    }

    [CCode (instance_pos = -1)]
    public void entry_status_activated(Object source) {
      //TODO
    }

    [CCode (instance_pos = -1)]
    public void button_copy_id_clicked(Object source) {
      Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD).set_text("Tox me: %s".printf(Tools.bin_to_hexstring(my_id)), -1);
    }

    [CCode (instance_pos = -1)]
    public void button_add_contact_clicked(Object source) {
      AddFriendDialog dialog = null;
      try {
        dialog = AddFriendDialog.create();
      } catch (Error e) {
        stderr.printf("Error creating AddFriendDialog: %s\n", e.message);
      }

      if(dialog.gtk_add_friend_dialog.run() != Gtk.ResponseType.OK)
        return;

      uint8[] friend_id = Tools.hexstring_to_bin(dialog.friend_id);

      // print some info
      stdout.printf("Friend ID:");
      for(int i = 0; i < friend_id.length; ++i)
        stdout.printf("%02X", friend_id[i]);
      stdout.printf("\n");

      // add friend
      Tox.FriendAddError ret = session.addfriend(friend_id, dialog.friend_msg);
      switch(ret) {
        case Tox.FriendAddError.TOOLONG:
        break;
        case Tox.FriendAddError.NOMESSAGE:
        break;
        case Tox.FriendAddError.OWNKEY:
        break;
        case Tox.FriendAddError.ALREADYSENT:
        break;
        case Tox.FriendAddError.UNKNOWN:
        break;
        case Tox.FriendAddError.BADCHECKSUM:
        break;
        case Tox.FriendAddError.SETNEWNOSPAM:
        break;
        case Tox.FriendAddError.NOMEM:
        break;
        default:
          stdout.printf("Friend request successfully sent. Friend added as %i.\n", (int)ret);
        break;
      }
    }

    [CCode (instance_pos = -1)]
    public void button_remove_contact_clicked(Object source) {
      //TODO
    }

    public void show() {
      contact_list_window.show_all ();
    }

    public static ContactList create() throws Error {
      Builder builder = new Builder();
      builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "contact_list.glade"));
      Window window = builder.get_object("window") as Window;
      Image image_status = builder.get_object("image_status") as Image;

      ContactList contact_list = new ContactList(window, image_status);
      builder.connect_signals(contact_list);
      return contact_list;
    }
  }
}
