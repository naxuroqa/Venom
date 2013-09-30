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
  public class ContactListWindow : Gtk.Window {
    // Containers
    private Gee.HashMap<int, Contact> contacts;
    private Gee.HashMap<int, ConversationWindow> conversation_windows;
    // Tox session wrapper
    private ToxSession session;

    // Widgets
    private Gtk.Button button_add_contact;
    private Gtk.Button button_group_chat;
    private Gtk.Button button_preferences;
    private Gtk.Image image_status;
    private Gtk.Image image_userimage;
    private Gtk.Label label_name;
    private Gtk.Label label_status;
    private ContactListTreeView contact_list_tree_view;

    private string data_filename = "data";
    private string data_pathname = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");

    // Signals
    public signal void on_contact_added(Contact c);
    public signal void on_contact_changed(Contact c);
    public signal void on_contact_removed(Contact c);
    public signal void incoming_message(Message m);

    // Default Constructor
    public ContactListWindow () {
      this.contacts = new Gee.HashMap<int, Contact>();
      this.conversation_windows = new Gee.HashMap<int, ConversationWindow>();

      init_session();      
      init_widgets();
      init_signals();
      init_contacts();

      // initialize session specific gui stuff
      label_name.set_text(session.getselfname());
      label_status.set_text(session.get_self_statusmessage());

      // start the session
      session.start();
    }

    // Destructor
    ~ContactListWindow() {
      stdout.printf("Ending session...\n");
      // Stop background thread
      session.stop();
      // wait for background thread to finish
      session.join();

      // Save session before shutdown
      session.save_to_file(data_pathname, data_filename);
      stdout.printf("Session ended gracefully.\n");
    }

    // Create a new session, load/create session data
    private void init_session() {
      session = new ToxSession();
      try {
        session.load_from_file(data_pathname, data_filename);
      } catch (Error e) {
        try {
          stdout.printf("Could not load session data (%s), creating new one.\n", e.message);
          session.save_to_file(data_pathname, data_filename);
        } catch (Error e) {
          stderr.printf("Could not load messenger data and failed to create new one.\n");
        }
      }
    }

    // Load widgets from file
    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "contact_list.glade"));
      } catch (GLib.Error e) {
        stderr.printf("Loading contact list failed!\n");
      }
      
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.add(box);
      
      button_add_contact = builder.get_object("button_add_contact") as Gtk.Button;
      button_group_chat = builder.get_object("button_group_chat") as Gtk.Button;
      button_preferences = builder.get_object("button_preferences") as Gtk.Button;
      image_status = builder.get_object("image_status") as Gtk.Image;
      image_userimage = builder.get_object("image_userimage") as Gtk.Image;
      label_name = builder.get_object("label_username") as Gtk.Label;
      label_status = builder.get_object("label_userstatus") as Gtk.Label;
      
      string pixmaps_folder = Path.build_filename(Tools.find_data_dir(), "pixmaps");
      Gtk.Image image_add_contact = builder.get_object("image_add_contact") as Gtk.Image;
      Gtk.Image image_group_chat  = builder.get_object("image_group_chat") as Gtk.Image;
      Gtk.Image image_preferences = builder.get_object("image_preferences") as Gtk.Image;

      string image_add_contact_filename   = Path.build_filename(pixmaps_folder, "add.png");
      string image_group_chat_filename    = Path.build_filename(pixmaps_folder, "groupchat.png");
      string image_preferences_filename   = Path.build_filename(pixmaps_folder, "settings.png");
      string image_default_image_filename = Path.build_filename(pixmaps_folder, "default_image.png");

      image_add_contact.set_from_file(image_add_contact_filename);
      image_group_chat.set_from_file( image_group_chat_filename);
      image_preferences.set_from_file(image_preferences_filename);
      image_userimage.set_from_file(image_default_image_filename);

      builder.connect_signals(this);
      
      contact_list_tree_view = new ContactListTreeView();
      contact_list_tree_view.show_all();
      Gtk.ScrolledWindow w = builder.get_object("contacts_window") as Gtk.ScrolledWindow;
      w.add(contact_list_tree_view);
      
      set_default_size(230, 600);
    }

    // Connect
    private void init_signals() {
      // Session signals
      session.on_friendrequest.connect(this.on_friendrequest);
      session.on_friendmessage.connect(this.on_friendmessage);
      session.on_action.connect(this.on_action);
      session.on_namechange.connect(this.on_namechange);
      session.on_statusmessage.connect(this.on_statusmessage);
      session.on_userstatus.connect(this.on_userstatus);
      session.on_read_receipt.connect(this.on_read_receipt);
      session.on_connectionstatus.connect(this.on_connectionstatus);
      session.on_ownconnectionstatus.connect(this.on_ownconnectionstatus);
      
      // Contact list treeview signals
      on_contact_added.connect(contact_list_tree_view.add_contact);
      on_contact_removed.connect(contact_list_tree_view.remove_contact);
      contact_list_tree_view.contact_activated.connect(on_contact_activated);
      
      // End program when window is closed
      this.destroy.connect (Gtk.main_quit);
    }
    
    // Restore friends from datafile
    private void init_contacts() {
      Contact[] contacts = session.get_friendlist();
      if (contacts != null) {
        foreach(Contact c in contacts) {
          stdout.printf("Retrieved contact %s from savefile.\n", Tools.bin_to_hexstring(c.public_key));
          add_contact(c);
        }
      } else {
        stderr.printf("Could not retrieve contacts!\n");
      }
    }

    public void add_contact(Contact contact) {
      contacts[contact.friend_id] = contact;
      on_contact_added(contact);    
    }

    private void on_outgoing_message(string message, Contact receiver) {
      session.sendmessage(receiver.friend_id, message);
    }

    // Session Signal callbacks
    private void on_friendrequest(uint8[] public_key, string message) {
      string public_key_string = Tools.bin_to_hexstring(public_key);
      stdout.printf("[fr] %s:%s\n", public_key_string, message);

      Gtk.MessageDialog messagedialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.YES_NO,
                                  "New friend request from %s.\n\nMessage: %s\nDo you want to accept?".printf(public_key_string, message));

		  int response = messagedialog.run();
		  messagedialog.destroy();
      if(response != Gtk.ResponseType.YES)
        return;

      Tox.FriendAddError far = session.addfriend_norequest(public_key);
      if((int)far >= 0) {
        stdout.printf("Added new friend #%i\n", (int)far);
        add_contact(new Contact(public_key, (int)far));
      } else {
        stderr.printf("Could not add friend: %i\n", (int)far);
      }
    }
    private void on_friendmessage(int friend_number, string message) {
      if(contacts[friend_number] != null) {
        Contact c = contacts[friend_number];
        stdout.printf("<%s> %s:%s\n", new DateTime.now_local().format("%F"), c.name, message);

        ConversationWindow w = open_conversation_with(c);
        if(w == null)
          return;
        w.show_all();        
        incoming_message(new Message(c, message));
      } else {
        stderr.printf("Contact #%i is not in contactlist!\n", friend_number);
      }
    }
    private void on_action(int friend_number, string action) {
      stdout.printf("[ac] %i:%s\n", friend_number, action);
    }
    private void on_namechange(int friend_number, string new_name) {
      if(contacts[friend_number] != null) {
        stdout.printf("%s changed his name to %s\n", contacts[friend_number].name, new_name);
        contacts[friend_number].name = new_name;
      } else {
        stderr.printf("Contact #%i is not in contactlist!\n", friend_number);
      }
    }
    private void on_statusmessage(int friend_number, string status_message) {
      if(contacts[friend_number] != null) {
        stdout.printf("%s changed his status to %s\n", contacts[friend_number].name, status_message);
        contacts[friend_number].status_message = status_message;
      } else {
        stderr.printf("Contact #%i is not in contactlist!\n", friend_number);
      }
    }
    private void on_userstatus(int friend_number, int user_status) {
      if(contacts[friend_number] != null) {
        stdout.printf("[us] %s:%i\n", contacts[friend_number].name, user_status);
        contacts[friend_number].user_status = user_status;
      } else {
        stderr.printf("Contact #%i is not in contactlist!\n", friend_number);
      }
    }
    private void on_read_receipt(int friend_number, uint32 receipt) {
      if(contacts[friend_number] != null) {
        stdout.printf("[rr] %s:%u\n", contacts[friend_number].name, receipt);
      } else {
        stderr.printf("Contact #%i is not in contactlist!\n", friend_number);
      }
    }
    private void on_connectionstatus(int friend_number, bool status) {
      if(contacts[friend_number] != null) {
        stdout.printf("%s is now %s.\n", contacts[friend_number].name, status ? "online" : "offline");
        if(!status && contacts[friend_number].online)
          contacts[friend_number].last_seen = new DateTime.now_local();
        contacts[friend_number].online = status;
      } else {
        stderr.printf("Contact #%i is not in contactlist!\n", friend_number);
      }
    }

    private void on_ownconnectionstatus(bool status) {
      if(status) {
        image_status.set_from_stock(Gtk.Stock.YES, Gtk.IconSize.BUTTON);
        image_status.set_tooltip_text("Connected to: %s".printf(session.connected_dht_server.toString()));
      } else {
        image_status.set_from_stock(Gtk.Stock.NO, Gtk.IconSize.BUTTON);
        image_status.set_tooltip_text("");
      }
    }
    
    private ConversationWindow? open_conversation_with(Contact c) {
      ConversationWindow w = conversation_windows[c.friend_id];
      if(w == null) {
        try {
          w = ConversationWindow.create(c);
        } catch (Error e) {
          stderr.printf("Could not create conversation window: %s\n", e.message);
          return null;
        }
        incoming_message.connect(w.on_incoming_message);
        w.new_outgoing_message.connect(on_outgoing_message);
        
        conversation_windows[c.friend_id] = w;
      }
      return w;
    }

    // Contact doubleclicked in treeview
    private void on_contact_activated(Contact c) {
      ConversationWindow w = open_conversation_with(c);
      if(w == null)
        return;
      w.show_all();
    }

    // GUI Events
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
          add_contact(new Contact(friend_id, (int)ret));
        break;
      }
    }

    // currently deactivated
    [CCode (instance_pos = -1)]
    public void button_remove_contact_clicked(Object source) {
      Contact c = contact_list_tree_view.get_selected_contact();
      if(c == null)
        return;
      Gtk.MessageDialog messagedialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.YES_NO,
                                  "Do you really want to delete %s from your contact list?".printf(c.name));

		  int response = messagedialog.run();
		  messagedialog.destroy();
      if(response != Gtk.ResponseType.YES)
        return;

      session.delfriend(c.friend_id);
      contacts.unset(c.friend_id);
      on_contact_removed(c);
    }
    
    [CCode (instance_pos = -1)]
    public void button_groupchat_clicked(Object source) {
      stdout.printf("Groupchat button clicked\n");
    }

    [CCode (instance_pos = -1)]
    public void button_preferences_clicked(Object source) {
      //TODO
    }
  }
}
