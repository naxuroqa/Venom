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
    private ArrayList<Contact> contacts;
    private ToxSession session;

    private Window contact_list_window;
    private ComboBoxText status_combo_box;
    private string data_filename = "data";
    private string data_pathname = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");

    public ContactList( Window contact_list_window, ComboBoxText status_combo_box ) {
      this.contacts = new ArrayList<Contact>();
      this.contact_list_window = contact_list_window;
      this.status_combo_box = status_combo_box;

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

      uint8[] my_id = session.get_address();
      stdout.printf("My ID: %s\n", Tools.bin_to_hexstring(my_id));
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
        if((int)far >= 0)
          stdout.printf("Added new Friend #%i\n", (int)far);
      }
      messagedialog.destroy();
    }
    private void on_friendmessage(int friend_number, string message) {
      stdout.printf("[fm] %i:%s\n", friend_number, message);
    }
    private void on_action(int friend_number, string action) {
      stdout.printf("[ac] %i:%s\n", friend_number, action);
    }
    private void on_namechange(int friend_number, string new_name) {
      stdout.printf("[nc] %i:%s\n", friend_number, new_name);
    }
    private void on_statusmessage(int friend_number, string status) {
      stdout.printf("[sm] %i:%s\n", friend_number, status);
    }
    private void on_userstatus(int friend_number, int user_status) {
      stdout.printf("[us] %i:%i\n", friend_number, user_status);
    }
    private void on_read_receipt(int friend_number, uint32 receipt) {
      stdout.printf("[rr] %i:%u\n", friend_number, receipt);
    }
    private void on_connectionstatus(int friend_number, bool status) {
      stdout.printf("[cs] %i:%i\n", friend_number, (int)status);
    }

    // GUI Events
    [CCode (instance_pos = -1)]
    public void clicked(Object source) {
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
    public void combobox_status_changed(ComboBoxText source) {
      stdout.printf("New status: %s (%i)\n", source.get_active_text(), source.get_active());
      bool result = false;
      switch(source.get_active()) {
        case 0: // online
          if(!session.is_running())
            session.start();
          result = session.set_status(Tox.UserStatus.NONE);
        break;
        case 1: // away
          if(!session.is_running())
            session.start();
          result = session.set_status(Tox.UserStatus.AWAY);
        break;
        case 2: // busy
          if(!session.is_running())
            session.start();
          result = session.set_status(Tox.UserStatus.BUSY);
        break;
        case 3: //offline
          session.stop();
          result = true;
        break;
        default:
        break;
      }
      if(!result) {
        stderr.printf("Could not change status!\n");
      }
    }

    public void show() {
      contact_list_window.show_all ();
    }

    public static ContactList create() throws Error {
      Builder builder = new Builder();
      builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "contact_list.glade"));
      Window window = builder.get_object("window") as Window;
      ComboBoxText status_combo_box = builder.get_object("combobox_status") as ComboBoxText;
      status_combo_box.set_active(0);

      ContactList contact_list = new ContactList(window, status_combo_box);
      builder.connect_signals(contact_list);
      return contact_list;
    }
  }
}
