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
  public class ContactListWindow : Object {
    private Gee.HashMap<int, Contact> contacts;
    private Gee.HashMap<int, ConversationWindow> conversation_windows;
    private ToxSession session;

    private Gtk.Window contact_list_window;
    private Gtk.Image image_status;
    private Gtk.Image image_userimage;
    private Gtk.Label label_id;
    private Gtk.Entry entry_username;
    private Gtk.Entry entry_status;
    private ContactListTreeView contact_list_tree_view;
    private Gtk.TreeView treeview_conversations;
    private Gtk.FileChooserDialog file_chooser_dialog;

    private string data_filename = "data";
    private string data_pathname = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");
    private uint8[] my_id;
    
    public signal void on_contact_added(Contact c);
    public signal void on_contact_changed(Contact c);
    public signal void on_contact_removed(Contact c);
    public signal void incoming_message(Message m);
    
    public void add_contact(Contact contact) {
      contacts[contact.friend_id] = contact;
      on_contact_added(contact);    
    }

    public ContactListWindow ( 
        Gtk.Window contact_list_window,
        Gtk.Image image_status,
        Gtk.Image image_userimage,
        Gtk.Label label_id,
        Gtk.Entry entry_username,
        Gtk.Entry entry_status,
        Gtk.Notebook notebook,
        Gtk.TreeView treeview_conversations,
        Gtk.FileChooserDialog file_chooser_dialog 
      ) throws Error {
      this.contacts = new Gee.HashMap<int, Contact>();
      this.conversation_windows = new Gee.HashMap<int, ConversationWindow>();
      this.contact_list_window = contact_list_window;
      this.image_status = image_status;
      this.image_userimage = image_userimage;
      this.label_id = label_id;
      this.entry_username = entry_username;
      this.entry_status = entry_status;
      this.treeview_conversations = treeview_conversations;
      this.file_chooser_dialog = file_chooser_dialog;

      contact_list_tree_view = new ContactListTreeView();
      contact_list_tree_view.show_all();
      int pagenumber = notebook.prepend_page(contact_list_tree_view, new Gtk.Label("Contacts"));
      notebook.set_current_page(pagenumber);
      
      session = new ToxSession();
      try {
        session.load_from_file(data_pathname, data_filename);
        stdout.printf("Successfully loaded messenger data.\n");
      } catch (Error e) {
        try {
          session.save_to_file(data_pathname, data_filename);
        } catch (Error e) {
          stderr.printf("Could not load messenger data and failed to create new one\n");
          throw e;
        }
      }

      init_signals();

      init_contacts();

      // initialize session specific gui stuff
      my_id = session.get_address();
      label_id.set_text(Tools.bin_to_hexstring(my_id));
      string selfname = session.getselfname();
      if(selfname != null && selfname.length > 0) {
        entry_username.set_text(selfname);
      } else {
        session.setname(entry_username.get_text());
      }

      session.start();
    }

    ~ContactListWindow() {
      // Stop background thread
      session.stop();
      // wait for background thread to finish
      session.join();

      // Save session before shutdown
      session.save_to_file(data_pathname, data_filename);
      stdout.printf("Session ended gracefully.\n");
    }
    
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
      contact_list_window.destroy.connect (Gtk.main_quit);
    }
    
    private void init_contacts() {
      // restore friends from datafile
      int client_id = 0;
      uint8[] client_key;
      while( (client_key = session.getclient_id(client_id)) != null ) {
        string name = session.getname(client_id);
        stdout.printf("Adding friend (%s) from data file: %s\n", (name != null ? name : ""), Tools.bin_to_hexstring(client_key));
        Contact c = new Contact(client_key, client_id);
        c.name = name;
        add_contact(c);
        client_id++;
      }
    }
    
    private void on_outgoing_message(string message, Contact receiver) {
      session.sendmessage(receiver.friend_id, message);
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
        stdout.printf("<%s> %s:%s\n", new DateTime.now_local().format("%F"), contacts[friend_number].name, message);
        incoming_message(new Message(contacts[friend_number], message));
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

    // Contact doubleclicked in treeview
    private void on_contact_activated(Contact c) {
      try {
        if(conversation_windows[c.friend_id] == null) {
          ConversationWindow conversation_window = ConversationWindow.create(c);
          conversation_windows[c.friend_id] = conversation_window;
          incoming_message.connect(conversation_window.on_incoming_message);
          conversation_window.new_outgoing_message.connect(on_outgoing_message);

          conversation_window.show_all();
        }
      } catch (Error e) {
        stderr.printf("Could not create conversation window: %s\n", e.message);
      }
    }

    // GUI Events
    [CCode (instance_pos = -1)]
    public void button_userimage_clicked(Object source) {
      int ret = file_chooser_dialog.run();
      file_chooser_dialog.hide();

      if(ret != Gtk.ResponseType.OK) {
        return;
      }

      File f = file_chooser_dialog.get_file();
      if( !f.query_exists() )
        return;
      Gdk.Pixbuf pixbuf = null;
      try {
        pixbuf = new Gdk.Pixbuf.from_file_at_size (f.get_path(), 85, 85);
        image_userimage.set_from_pixbuf(pixbuf);
      } catch (Error e) {
        //Ignore for now
        // TODO maybe error management
      }
    }

    [CCode (instance_pos = -1)]
    public void entry_username_activated(Gtk.Entry source) {
      string username = source.get_text();
      if( session.setname(username) )
        stdout.printf("Name changed to %s\n", username);
      // TODO remove focus
      // TODO set entry max to maxnamelength
    }

    [CCode (instance_pos = -1)]
    public void entry_status_activated(Gtk.Entry source) {
      string message = source.get_text();
      if( session.set_statusmessage(message) )
        stdout.printf("Status changed to %s\n", message);
    }

    [CCode (instance_pos = -1)]
    public void button_copy_id_clicked(Object source) {
      string message = Tools.bin_to_hexstring(my_id);
      Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD).set_text(message, -1);
      Gtk.Clipboard.get(Gdk.SELECTION_PRIMARY).set_text(message, -1);
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

    [CCode (instance_pos = -1)]
    public void button_remove_contact_clicked(Object source) {
      Contact c = contact_list_tree_view.get_selected_contact();
      if(c == null)
        return;
      Gtk.MessageDialog messagedialog = new Gtk.MessageDialog (contact_list_window,
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
    public void button_preferences_clicked(Object source) {
      //TODO
    }

    public void show() {
      contact_list_window.show_all ();
    }

    public static ContactListWindow create() throws Error {
      Gtk.Builder builder = new Gtk.Builder();
      builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "contact_list.glade"));
      Gtk.Window window = builder.get_object("window") as Gtk.Window;
      Gtk.Image image_status = builder.get_object("image_status") as Gtk.Image;
      Gtk.Image image_userimage = builder.get_object("image_userimage") as Gtk.Image;
      Gtk.Label label_id = builder.get_object("label_id") as Gtk.Label;
      Gtk.Entry entry_username = builder.get_object("entry_username") as Gtk.Entry;
      Gtk.Entry entry_status = builder.get_object("entry_status") as Gtk.Entry;
      Gtk.Notebook notebook = builder.get_object("notebook") as Gtk.Notebook;
      //Gtk.TreeView treeview_contacts = builder.get_object("treeview_contacts") as Gtk.TreeView;
      Gtk.TreeView treeview_conversations = builder.get_object("treeview_conversations") as Gtk.TreeView;
      Gtk.FileChooserDialog file_chooser_dialog = builder.get_object("filechooserdialog") as Gtk.FileChooserDialog;

      ContactListWindow contact_list = new ContactListWindow(window, image_status, image_userimage, label_id, 
        entry_username, entry_status, notebook, treeview_conversations, file_chooser_dialog);
      builder.connect_signals(contact_list);
      return contact_list;
    }
  }
}
