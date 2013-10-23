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

  public enum ConnectionStatus {
    ONLINE,
    AWAY,
    BUSY,
    OFFLINE
  }

  public class ContactListWindow : Gtk.Window {
    // Containers
    private Gee.HashMap<int, ConversationWindow> conversation_windows;
    // Tox session wrapper
    private ToxSession session;
    private ConnectionStatus connection_status = ConnectionStatus.OFFLINE;

    // Widgets
    private Gtk.Image image_status;
    private Gtk.Image image_userimage;
    private Gtk.Label label_name;
    private Gtk.Label label_status;
    private ContactListTreeView contact_list_tree_view;
    private Gtk.ComboBox combobox_status;

    private string data_filename = "data";
    private string data_pathname = Path.build_filename(GLib.Environment.get_user_config_dir(), "tox");
    private bool cleaned_up = false;

    // Signals
    public signal void contact_added(Contact c);
    public signal void contact_changed(Contact c);
    public signal void contact_removed(Contact c);
    public signal void incoming_message(Message m);
    public signal void status_changed(ConnectionStatus s);

    // Default Constructor
    public ContactListWindow () {
      this.conversation_windows = new Gee.HashMap<int, ConversationWindow>();

      init_theme();
      init_session();      
      init_widgets();
      init_signals();
      init_contacts();

      // initialize session specific gui stuff
      label_name.set_text(session.getselfname());
      label_status.set_text(session.get_self_statusmessage());
      on_ownconnectionstatus(false);
      
      stdout.printf("ID: %s\n", Tools.bin_to_hexstring(session.get_address()));
    }

    // Destructor
    ~ContactListWindow() {
      cleanup();
    }
    
    public void cleanup() {
      if(cleaned_up)
        return;
      stdout.printf("Ending session...\n");
      // Stop background thread
      session.stop();
      // wait for background thread to finish
      session.join();

      // Save session before shutdown
      try {
        session.save_to_file(data_pathname, data_filename);
      } catch (Error e) {
        stderr.printf("Saving session file failed: %s\n", e.message);
      }
      stdout.printf("Session ended gracefully.\n");
      cleaned_up = true;
    }
    
    private bool on_contact_list_key_pressed (Gtk.Widget source, Gdk.EventKey key) {
      // only for debugging!!!
      if(key.keyval == Gdk.Key.F5) {
        // reset theme
        Gtk.CssProvider provider = Gtk.CssProvider.get_default();        
        Gdk.Screen screen = Gdk.Screen.get_default();
        Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
        
        // set user theme
        init_theme();
        return true;
      }
      return false;
    }
    
    private void init_theme() {
      Gtk.CssProvider provider = new Gtk.CssProvider();
      try {
      provider.load_from_path(ResourceFactory.instance.default_theme_filename); 
      } catch (Error e) {
        stderr.printf("Could not read css file \"%s\": %s\n", ResourceFactory.instance.default_theme_filename,  e.message);
      }     
      
      Gdk.Screen screen = Gdk.Screen.get_default();

      Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
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

    // Initialize widgets
    private void init_widgets() {
      // Set up Window
      set_default_size(230, 600);
      set_property("name", "contact_list");
      set_default_icon(ResourceFactory.instance.tox_logo);

      // Load widgets from file
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "contact_list.glade"));
      } catch (GLib.Error e) {
        stderr.printf("Loading contact list failed!\n");
      }
      
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.add(box);
      
      image_status = builder.get_object("image_status") as Gtk.Image;
      image_userimage = builder.get_object("image_userimage") as Gtk.Image;
      label_name = builder.get_object("label_username") as Gtk.Label;
      label_status = builder.get_object("label_userstatus") as Gtk.Label;

      combobox_status = builder.get_object("combobox_status") as Gtk.ComboBox;

      Gtk.ListStore liststore_status = builder.get_object("liststore_status") as Gtk.ListStore;
      
      Gtk.TreeIter iter;
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, "Online" , -1);
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, "Away"   , -1);
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, "Busy"   , -1);
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, "Offline", -1);
      combobox_status.set_active(3);


      Gtk.Image image_add_contact = builder.get_object("image_add_contact") as Gtk.Image;
      Gtk.Image image_group_chat  = builder.get_object("image_group_chat") as Gtk.Image;
      Gtk.Image image_preferences = builder.get_object("image_preferences") as Gtk.Image;
      
      Gtk.ImageMenuItem menuitem_edit_info = builder.get_object("menuitem_edit_info") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_copy_id   = builder.get_object("menuitem_copy_id") as Gtk.ImageMenuItem;
      Gtk.MenuItem menuitem_about = builder.get_object("menuitem_about") as Gtk.MenuItem;

      image_status.set_from_pixbuf(ResourceFactory.instance.offline);
      image_userimage.set_from_pixbuf(ResourceFactory.instance.default_image);

      image_add_contact.set_from_pixbuf(ResourceFactory.instance.add);
      image_group_chat.set_from_pixbuf(ResourceFactory.instance.groupchat);
      image_preferences.set_from_pixbuf(ResourceFactory.instance.settings);
      
      Gtk.Image image_arrow = builder.get_object("image_arrow") as Gtk.Image;
      image_arrow.set_from_pixbuf(ResourceFactory.instance.arrow);

      // Create and add custom treeview
      contact_list_tree_view = new ContactListTreeView();
      contact_list_tree_view.show_all();

      Gtk.ScrolledWindow scrolled_window_contact_list = builder.get_object("scrolled_window_contact_list") as Gtk.ScrolledWindow;
      scrolled_window_contact_list.add(contact_list_tree_view);
      scrolled_window_contact_list.get_vscrollbar().hide();
      
      Gtk.Menu menu_user = builder.get_object("menu_user") as Gtk.Menu;
      Gtk.Button button_user = builder.get_object("button_user") as Gtk.Button;
      Gtk.Button button_add_contact = builder.get_object("button_add_contact") as Gtk.Button;
      Gtk.Button button_group_chat = builder.get_object("button_group_chat") as Gtk.Button;
      Gtk.Button button_preferences = builder.get_object("button_preferences") as Gtk.Button;
      
      button_user.clicked.connect( () => {menu_user.popup(null, button_user, null, 0, 0);});
      button_add_contact.clicked.connect(button_add_contact_clicked);
      button_group_chat.clicked.connect(button_group_chat_clicked);
      button_preferences.clicked.connect(button_preferences_clicked);
      
      menuitem_edit_info.activate.connect( edit_user_information );
      menuitem_copy_id.activate.connect( copy_id_to_clipboard);
      menuitem_about.activate.connect( show_about_dialog );
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
      
      //groupmessage signals
      session.on_group_invite.connect(this.on_group_invite);
      session.on_group_message.connect(this.on_group_message);
      
      // Contact list treeview signals
      contact_added.connect(contact_list_tree_view.add_contact);
      contact_changed.connect(contact_list_tree_view.update_contact);
      contact_removed.connect(contact_list_tree_view.remove_contact);
      contact_list_tree_view.contact_activated.connect(on_contact_activated);
      contact_list_tree_view.key_press_event.connect(on_treeview_key_pressed);
      
      //ComboboxStatus signals
      combobox_status.changed.connect( () => {status_changed((ConnectionStatus)combobox_status.get_active());} );
      status_changed.connect( (s) => {combobox_status.set_active(s);});
      status_changed.connect( update_status );
      
      // End program when window is closed
      this.destroy.connect (Gtk.main_quit);
      
      // FIXME remove after testing is done!
      this.key_press_event.connect(on_contact_list_key_pressed);
    }
    
    // Restore friends from datafile
    private void init_contacts() {
      Gee.HashMap<int, Contact> contacts = session.get_contact_list();
      foreach(Contact c in contacts) {
        stdout.printf("Retrieved contact %s from savefile.\n", Tools.bin_to_hexstring(c.public_key));
        contact_added(c);
      }
    }
    
    private void update_status(ConnectionStatus s) {
      if(connection_status == s)
        return;
      if(connection_status == ConnectionStatus.OFFLINE) {
        session.start();
      }
        
      switch(s) {
        case ConnectionStatus.ONLINE:
          session.set_status(Tox.UserStatus.NONE);
          image_status.set_from_pixbuf(ResourceFactory.instance.online);
          break;
        case ConnectionStatus.AWAY:
          session.set_status(Tox.UserStatus.AWAY);
          image_status.set_from_pixbuf(ResourceFactory.instance.away);
          break;
        case ConnectionStatus.BUSY:
          session.set_status(Tox.UserStatus.BUSY);
          image_status.set_from_pixbuf(ResourceFactory.instance.offline_glow);
          break;
        case ConnectionStatus.OFFLINE:
          session.set_status(Tox.UserStatus.NONE);
          image_status.set_from_pixbuf(ResourceFactory.instance.offline);
          break;
      }
      
      if(s == ConnectionStatus.OFFLINE) {
        session.stop();
      }
      
      connection_status = s;
    }
    
    private void copy_id_to_clipboard() {
      string id_string = Tools.bin_to_hexstring(session.get_address());
      Gdk.Display display = get_display();
      Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD).set_text(id_string, -1);
      Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_PRIMARY).set_text(id_string, -1);
    }
    
    private void show_about_dialog() {
      AboutDialog dialog = new AboutDialog();
      dialog.show_all();
      dialog.run();
      dialog.destroy();
    }
    
    private void edit_user_information() {
      UserInfoWindow w = new UserInfoWindow();
      w.user_name  = label_name.get_text();
      w.user_status = label_status.get_text();
      w.user_image = image_userimage.get_pixbuf();

      w.show_all();
      int response = w.run();

      if(response == Gtk.ResponseType.APPLY) {
        image_userimage.set_from_pixbuf(w.user_image);

        label_name.set_text(w.user_name);
        label_status.set_text(w.user_status);

        session.setname(w.user_name);
        session.set_statusmessage(w.user_status);
      }
      w.destroy();
    }

    private void on_outgoing_message(string message, Contact receiver) {
      session.sendmessage(receiver.friend_id, message);
    }
    
    private bool on_treeview_key_pressed (Gtk.Widget source, Gdk.EventKey key) {
      if(key.keyval == Gdk.Key.Delete) {
        Contact c = contact_list_tree_view.get_selected_contact();
        remove_contact(c);
        return true;
      }
      return false;
    }

    // Session Signal callbacks
    private void on_friendrequest(Contact c, string message) {
      string public_key_string = Tools.bin_to_hexstring(c.public_key);
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

      Tox.FriendAddError friend_add_error = session.addfriend_norequest(c);
      if((int)friend_add_error < 0) {
        stderr.printf("Could not add friend: %s\n", Tools.friend_add_error_to_string(friend_add_error));
        return;
      }
      stdout.printf("Added new friend #%i\n", c.friend_id);
      contact_added(c);
    }
    private void on_friendmessage(Contact c, string message) {
      stdout.printf("<%s> %s:%s\n", new DateTime.now_local().format("%F"), c.name != null ? c.name : "<%i>".printf(c.friend_id), message);

      ConversationWindow w = open_conversation_with(c);
      if(w == null)
        return;
      w.show_all();
      incoming_message(new Message(c, message));
    }
    private void on_action(Contact c, string action) {
      stdout.printf("[ac] %i:%s\n", c.friend_id, action);
    }
    private void on_namechange(Contact c, string? old_name) {
      stdout.printf("%s changed his name to %s\n", old_name, c.name);
      contact_changed(c);
    }
    private void on_statusmessage(Contact c, string? old_status) {
      stdout.printf("%s changed his status to %s\n", c.name, c.status_message);
      contact_changed(c);
    }
    private void on_userstatus(Contact c, int old_status) {
      stdout.printf("[us] %s:%i\n", c.name, c.user_status);
      contact_changed(c);
    }
    private void on_read_receipt(Contact c, uint32 receipt) {
      stdout.printf("[rr] %s:%u\n", c.name, receipt);
    }
    private void on_connectionstatus(Contact c) {
      stdout.printf("%s is now %s.\n", c.name, c.online ? "online" : "offline");
      contact_changed(c);
    }

    private void on_ownconnectionstatus(bool status) {
      if(status) {
        image_status.set_tooltip_text("Connected to: %s".printf(session.connected_dht_server.to_string()));
      } else {
        image_status.set_tooltip_text("Not connected.");
      }
    }

    private void on_group_invite(Contact c, GroupChat g) {
      stdout.printf("Group invite from %s with public key %s\n", c.name, Tools.bin_to_hexstring(g.public_key));
    }

    private void on_group_message(GroupChat g, int friendgroupnumber, string message) {
      stdout.printf("[gm] %i@%i: %s", friendgroupnumber, g.group_id, message);
    }
    
    private ConversationWindow? open_conversation_with(Contact c) {
      ConversationWindow w = conversation_windows[c.friend_id];
      if(w == null) {
        w = new ConversationWindow(c);
        incoming_message.connect(w.on_incoming_message);
        w.new_outgoing_message.connect(on_outgoing_message);
        contact_changed.connect( (c_) => {if(c == c_) w.update_contact();} );
        contact_removed.connect( (c_) => {if(c == c_) w.destroy();} );
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
      w.present();
    }
    
    public void remove_contact(Contact c) {
      if(c == null)
        return;
      string name;
      if(c.name != null && c.name != "") {
        name = c.name;
      } else {
        name = Tools.bin_to_hexstring(c.public_key);
      }
      Gtk.MessageDialog messagedialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.YES_NO,
                                  "Do you really want to delete %s from your contact list?".printf(name));

		  int response = messagedialog.run();
		  messagedialog.destroy();
      if(response != Gtk.ResponseType.YES)
        return;

      if(!session.delfriend(c)) {
        stderr.printf("Could not remove contact %i.\n", c.friend_id);
        return;
      }
      contact_removed(c);
    }

    // GUI Events
    public void button_add_contact_clicked(Object source) {
      AddContactDialog dialog = new AddContactDialog();
      
      int response = dialog.run();
      uint8[] contact_id = Tools.hexstring_to_bin(dialog.contact_id);
      string contact_message = dialog.contact_message;
      dialog.destroy();

      if(response != Gtk.ResponseType.OK)
          return;

      // add friend
      Contact c = new Contact(contact_id);
      Tox.FriendAddError ret = session.addfriend(c, contact_message);
      if(ret < 0) {
        //TODO turn this into a message box.
        stderr.printf("Error: %s.\n", Tools.friend_add_error_to_string(ret));
        return;
      }

      stdout.printf("Friend request successfully sent. Friend added as %i.\n", (int)ret);
      contact_added(c);
    }
    
    public void button_group_chat_clicked(Object source) {
      stdout.printf("Groupchat button clicked\n");
      //TODO
    }

    public void button_preferences_clicked(Object source) {
      stdout.printf("Settings button clicked\n");
      //TODO
    }
  }
}
