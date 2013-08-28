using Gtk;
using Gee;
namespace Venom {
  public class ContactList : Object {
    private ArrayList<Contact> contacts;
    private ToxSession session;

    private Window contact_list_window;
    private ComboBoxText status_combo_box;

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

      uint8[] friend_id = ToxSession.hexstringToBin(dialog.friend_id);

      // print some info
      stdout.printf("Friend ID:");
      for(int i = 0; i < friend_id.length; ++i)
        stdout.printf("%02X", friend_id[i]);
      stdout.printf("\n");

      // add friend
      Tox.FriendAddError ret = session.add_friend(friend_id, dialog.friend_msg);
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

    public ContactList( Window contact_list_window, ComboBoxText status_combo_box ) {
      this.contacts = new ArrayList<Contact>();
      this.contact_list_window = contact_list_window;
      this.status_combo_box = status_combo_box;

      this.contact_list_window.destroy.connect (Gtk.main_quit);
      
      session = new ToxSession();
      try {
        session.load_from_file("data");
        stdout.printf("Successfully loaded messenger data.\n");
      } catch (Error e) {
        try {
          session.save_to_file("data");
        } catch (Error e) {
          stderr.printf("Could not load messenger data and failed to create new one\n");
        }
      }
      session.start();
    }

    ~ContactList() {
      session.stop();
      session.join();
      //session.save_to_file("data");
      stdout.printf("Session ended gracefully.\n");
    }

    public static ContactList create() throws Error {
      Builder builder = new Builder();
      builder.add_from_file("ui/contact_list.glade");
      Window window = builder.get_object("window") as Window;
      ComboBoxText status_combo_box = builder.get_object("combobox_status") as ComboBoxText;
      status_combo_box.set_active(0);

      ContactList contact_list = new ContactList(window, status_combo_box);
      builder.connect_signals(contact_list);
      return contact_list;
    }
  }
}
