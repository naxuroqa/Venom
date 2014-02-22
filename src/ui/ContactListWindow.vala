/*
 *    ContactListWindow.vala
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
  public class ContactListWindow : Gtk.ApplicationWindow {
    // Containers
    private GLib.HashTable<int, ConversationWidget> conversation_widgets;
    private GLib.HashTable<int, GroupConversationWidget> group_conversation_widgets;
    // Tox session wrapper
    private ToxSession session;
    private UserStatus user_status = UserStatus.OFFLINE;
    private Gtk.ImageMenuItem menuitem_status;

    // Widgets
    private Gtk.Image image_status;
    private Gtk.Spinner spinner_status;
    private Gtk.Image image_userimage;
    private Gtk.Label label_name;
    private Gtk.Label label_status;
    private ContactListTreeView contact_list_tree_view;
    private Gtk.ComboBox combobox_status;
    private Gtk.Notebook notebook_conversations;
    private Gtk.Menu menu_user;
    private Gtk.ToggleButton button_user;

    private bool cleaned_up = false;

    // Signals
    public signal void contact_added(Contact c);
    public signal void contact_changed(Contact c);
    public signal void contact_removed(Contact c);

    public signal void groupchat_added(GroupChat g);
    public signal void groupchat_changed(GroupChat g);
    public signal void groupchat_removed(GroupChat g);

    public signal void incoming_message(Message m);
    public signal void incoming_action(ActionMessage m);
    public signal void incoming_group_message(GroupMessage m);
    public signal void incoming_group_action(GroupActionMessage m);

    // Default Constructor
    public ContactListWindow (Gtk.Application application) {
      GLib.Object(application:application);
      this.conversation_widgets = new GLib.HashTable<int, ConversationWidget>(null, null);
      this.group_conversation_widgets = new GLib.HashTable<int, GroupConversationWidget>(null, null);

      init_theme();
      init_session();
      init_widgets();
      init_signals();
      init_contacts();
      init_save_session_hooks();

      // initialize session specific gui stuff
      label_name.set_text(session.getselfname());
      string user_status = "Toxing on Venom v.%s".printf(Config.VERSION);
      if(session.set_statusmessage(user_status)) {
        label_status.set_text(user_status);
      } else {
        label_status.set_text(session.get_self_statusmessage());
      }
      on_ownconnectionstatus(false);

      stdout.printf("ID: %s\n", Tools.bin_to_hexstring(session.get_address()));
      if(ResourceFactory.instance.offline_mode) {
        set_userstatus(UserStatus.OFFLINE);
      } else {
        set_userstatus(UserStatus.ONLINE);
      }
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
      save_session();

      stdout.printf("Session ended gracefully.\n");
      cleaned_up = true;
    }

    private void save_session() {
      stdout.printf("Saving tox session data\n");
      try {
        session.save_to_file(ResourceFactory.instance.data_filename);
      } catch (Error e) {
        stderr.printf("Saving session file failed: %s\n", e.message);
      }

    }

    private void init_theme() {
      Gtk.CssProvider provider = new Gtk.CssProvider();
      try {
      provider.load_from_path(ResourceFactory.instance.default_theme_filename);
      } catch (Error e) {
        string message = "Could not read theme from \"%s\"".printf(ResourceFactory.instance.default_theme_filename);
        stderr.printf("%s: %s\n", message,  e.message);
        UITools.ErrorDialog(message, e.message, this);
        return;
      }

      Gdk.Screen screen = Gdk.Screen.get_default();
      Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    // Create a new session, load/create session data
    private void init_session() {
      session = new ToxSession();
      try {
        session.load_from_file(ResourceFactory.instance.data_filename);
      } catch (Error e) {
          stdout.printf("Could not load session data (%s), creating new one.\n", e.message);
          session.set_name(ResourceFactory.instance.default_username);
          save_session();
      }
    }

    // Initialize widgets
    private void init_widgets() {
      // Set up Window
      set_default_size(230, 600);
      try {
        Gtk.IconTheme theme = Gtk.IconTheme.get_default();
        theme.append_search_path(Path.build_filename("share", "pixmaps"));
        theme.append_search_path(Path.build_filename("..", "share", "pixmaps"));
        set_default_icon(Gtk.IconTheme.get_default().load_icon("venom", 48, 0));
      } catch (Error e) {
        stderr.printf("Error while loading icon: %s\n", e.message );
      }
      set_title_from_status(user_status);

      // Load widgets from file
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/contact_list.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading contact list failed!\n");
      }

      Gtk.Paned paned = builder.get_object("paned") as Gtk.Paned;
      this.add(paned);

      image_status = builder.get_object("image_status") as Gtk.Image;
      spinner_status = builder.get_object("spinner_status") as Gtk.Spinner;
      image_userimage = builder.get_object("image_userimage") as Gtk.Image;
      label_name = builder.get_object("label_username") as Gtk.Label;
      label_status = builder.get_object("label_userstatus") as Gtk.Label;

      combobox_status = builder.get_object("combobox_status") as Gtk.ComboBox;
      Gtk.ListStore liststore_status = new Gtk.ListStore (2, typeof(string), typeof(ContactFilter));
      combobox_status.set_model(liststore_status);

      ContactFilter filter_online = new ContactFilterOnline();
      ContactFilter filter_all = new ContactFilterAll();
      ContactFilter filter_default = filter_all;
      // Add our connection status to the treeview
      Gtk.TreeIter iter;
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, "Online", 1, filter_online, -1);
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, "All", 1, filter_all, -1);
      combobox_status.set_active_iter(iter);

      // Add cellrenderer
      Gtk.CellRendererText cell_renderer_status = new Gtk.CellRendererText();
      combobox_status.pack_start(cell_renderer_status, true);
      combobox_status.add_attribute(cell_renderer_status, "text", 0);

      Gtk.Image image_add_contact = builder.get_object("image_add_contact") as Gtk.Image;
      Gtk.Image image_group_chat  = builder.get_object("image_group_chat") as Gtk.Image;
      Gtk.Image image_preferences = builder.get_object("image_preferences") as Gtk.Image;

      Gtk.ImageMenuItem menuitem_edit_info = builder.get_object("menuitem_edit_info") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_copy_id   = builder.get_object("menuitem_copy_id") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_about = builder.get_object("menuitem_about") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_quit = builder.get_object("menuitem_quit") as Gtk.ImageMenuItem;

      menuitem_status = builder.get_object("menuitem_status") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_status_online = builder.get_object("menuitem_status_online") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_status_away = builder.get_object("menuitem_status_away") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_status_busy = builder.get_object("menuitem_status_busy") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_status_offline = builder.get_object("menuitem_status_offline") as Gtk.ImageMenuItem;

      (menuitem_status.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.offline);
      (menuitem_status_online.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.online);
      (menuitem_status_away.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.away);
      (menuitem_status_busy.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.busy);
      (menuitem_status_offline.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.offline);

      image_status.set_from_pixbuf(ResourceFactory.instance.offline);
      image_userimage.set_from_pixbuf(ResourceFactory.instance.default_contact);

      image_add_contact.set_from_pixbuf(ResourceFactory.instance.add);
      image_group_chat.set_from_pixbuf(ResourceFactory.instance.groupchat);
      image_preferences.set_from_pixbuf(ResourceFactory.instance.settings);

      Gtk.Image image_arrow = builder.get_object("image_arrow") as Gtk.Image;
      image_arrow.set_from_pixbuf(ResourceFactory.instance.arrow);

      // Create and add custom treeview
      contact_list_tree_view = new ContactListTreeView();
      contact_list_tree_view.show_all();

      Gtk.TreeModel m = contact_list_tree_view.get_model();
      Gtk.TreeModelFilter contact_list_tree_model_filter = new Gtk.TreeModelFilter(m, null);
      contact_list_tree_model_filter.set_visible_func(filter_default.filter_func);
      contact_list_tree_view.set_model(contact_list_tree_model_filter);

      Gtk.ScrolledWindow scrolled_window_contact_list = builder.get_object("scrolled_window_contact_list") as Gtk.ScrolledWindow;
      scrolled_window_contact_list.add(contact_list_tree_view);

      menu_user = builder.get_object("menu_user") as Gtk.Menu;
      button_user = builder.get_object("button_user") as Gtk.ToggleButton;
      Gtk.Button button_add_contact = builder.get_object("button_add_contact") as Gtk.Button;
      Gtk.Button button_group_chat = builder.get_object("button_group_chat") as Gtk.Button;
      Gtk.Button button_preferences = builder.get_object("button_preferences") as Gtk.Button;

      // poor man's Gtk.MenuButton
      //FIXME choose monitor to display this on
      button_user.clicked.connect( () => {
        if(button_user.active) {
          menu_user.popup(null,
            null,
            user_button_menu_position_function,
            0,
            0);
        }
      });
      menu_user.deactivate.connect( () => {
        button_user.set_active(false);
      });
      /*button_user.button_press_event.connect( (widget, event) => {
        if(event.type == Gdk.EventType.BUTTON_PRESS) {
          if(event.button == Gdk.BUTTON_PRIMARY)
            menu_user.popup(null, null, null, event.button, event.time);
        }
        return false;
      });*/
      button_add_contact.clicked.connect(button_add_contact_clicked);
      button_group_chat.clicked.connect(button_group_chat_clicked);
      button_preferences.clicked.connect(button_preferences_clicked);

      menuitem_edit_info.activate.connect( edit_user_information );
      menuitem_copy_id.activate.connect( copy_id_to_clipboard);
      menuitem_about.activate.connect( show_about_dialog );
      menuitem_quit.activate.connect( () => {this.destroy();});

      menuitem_status_online.activate.connect(  () => { set_userstatus(UserStatus.ONLINE); } );
      menuitem_status_away.activate.connect(    () => { set_userstatus(UserStatus.AWAY); } );
      menuitem_status_busy.activate.connect(    () => { set_userstatus(UserStatus.BUSY); } );
      menuitem_status_offline.activate.connect( () => { set_userstatus(UserStatus.OFFLINE); } );

      notebook_conversations = builder.get_object("notebook_conversations") as Gtk.Notebook;
      notebook_conversations.set_visible(false);
    }

    // Connect
    private void init_signals() {
      // Session signals
      session.on_friend_request.connect(this.on_friendrequest);
      session.on_friend_message.connect(this.on_friendmessage);
      session.on_friend_action.connect(this.on_action);
      session.on_name_change.connect(this.on_namechange);
      session.on_status_message.connect(this.on_statusmessage);
      session.on_user_status.connect(this.on_userstatus);
      session.on_read_receipt.connect(this.on_read_receipt);
      session.on_connection_status.connect(this.on_connectionstatus);
      session.on_own_connection_status.connect(this.on_ownconnectionstatus);
      session.on_own_user_status.connect(this.on_ownuserstatus);

      //groupmessage signals
      session.on_group_invite.connect(this.on_group_invite);
      session.on_group_message.connect(this.on_group_message);
      session.on_group_action.connect(this.on_group_action);
      session.on_group_peer_changed.connect(this.on_group_peer_changed);

      //file signals
      session.on_file_sendrequest.connect(this.on_file_sendrequest);
      session.on_file_control.connect(this.on_file_control_request);
      session.on_file_data.connect(this.on_file_data);

      // Contact list treeview signals
      contact_added.connect(contact_list_tree_view.add_entry);
      groupchat_added.connect(contact_list_tree_view.add_entry);

      contact_changed.connect( (c) => {
        contact_list_tree_view.update_entry(c);
        ConversationWidget w = conversation_widgets[c.friend_id];
        if(w != null)
          w.update_contact();
      } );
      groupchat_changed.connect( (g) => {
        contact_list_tree_view.update_entry(g);
        GroupConversationWidget w = group_conversation_widgets[g.group_id];
        if(w != null)
          w.update_contact();
      } );

      contact_removed.connect( (c) => {
        contact_list_tree_view.remove_entry(c);
        ConversationWidget w = conversation_widgets[c.friend_id];
        if(w != null) {
          conversation_widgets.get(c.friend_id).destroy();
          conversation_widgets.remove(c.friend_id);
        }
      } );
      groupchat_removed.connect( (g) => {
        contact_list_tree_view.remove_entry(g);
        GroupConversationWidget w = group_conversation_widgets[g.group_id];
        if(w != null) {
          group_conversation_widgets.get(g.group_id).destroy();
          group_conversation_widgets.remove(g.group_id);
        }
      } );

      contact_list_tree_view.entry_activated.connect(on_entry_activated);
      contact_list_tree_view.key_press_event.connect(on_treeview_key_pressed);

      //ComboboxStatus signals
      combobox_status.changed.connect(combobox_status_changed);
      
      this.focus_in_event.connect((e)  => {
        this.set_urgency_hint(false);
        return false;
      });
    }

    private void init_save_session_hooks() {
      contact_added.connect(    () => {save_session();});
      contact_removed.connect(  () => {save_session();});
      groupchat_added.connect(  () => {save_session();});
      groupchat_removed.connect(() => {save_session();});
    }

    // Restore friends from datafile
    private void init_contacts() {
      GLib.HashTable<int, Contact> contacts = session.get_contact_list();
      contacts.foreach((key, val) => {
        stdout.printf("Retrieved contact %s from savefile.\n", Tools.bin_to_hexstring(val.public_key));
        contact_added(val);
      });
    }

    private void set_title_from_status(UserStatus status) {
      set_title("Venom (%s)".printf(status.to_string()));
    }

    private void combobox_status_changed() {
      Gtk.TreeModel m = combobox_status.get_model() as Gtk.TreeModel;
      Gtk.TreeIter iter;
      combobox_status.get_active_iter(out iter);
      GLib.Value value_filter_function;
      m.get_value(iter, 1, out value_filter_function);
      ContactFilter f = value_filter_function as ContactFilter;
      Gtk.TreeModelFilter old_filter = contact_list_tree_view.get_model() as Gtk.TreeModelFilter;
      Gtk.TreeModelFilter new_filter = new Gtk.TreeModelFilter(old_filter.get_model(), null);
      new_filter.set_visible_func(f.filter_func);
      contact_list_tree_view.set_model(new_filter);
    }

    private void set_userstatus(UserStatus status) {
      if(user_status == status)
        return;
      if(user_status == UserStatus.OFFLINE) {
        session.start();
        image_status.hide();
        spinner_status.show();
        spinner_status.start();
      }
      session.set_userstatus(status);

      if(status == UserStatus.OFFLINE) {
        session.stop();
        image_status.show();
        spinner_status.hide();
        spinner_status.stop();
      }

      user_status = status;
    }

    private void copy_id_to_clipboard() {
      string id_string = Tools.bin_to_hexstring(session.get_address());
      Gdk.Display display = get_display();
      Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_CLIPBOARD).set_text(id_string, -1);
      Gtk.Clipboard.get_for_display(display, Gdk.SELECTION_PRIMARY).set_text(id_string, -1);
    }

    private void show_about_dialog() {
      AboutDialog dialog = new AboutDialog();
      dialog.set_transient_for(this);
      dialog.set_modal(true);

      dialog.run();
      dialog.destroy();
    }

    private void edit_user_information() {
      UserInfoWindow w = new UserInfoWindow();
      w.user_name  = label_name.get_text();
      w.user_status = label_status.get_text();
      w.user_image = image_userimage.get_pixbuf();
      w.user_id = Tools.bin_to_hexstring(session.get_address());

      w.set_modal(true);
      w.set_transient_for(this);
      int response = w.run();

      if(response == Gtk.ResponseType.APPLY) {
        image_userimage.set_from_pixbuf(w.user_image);

        label_name.set_text(w.user_name);
        label_status.set_text(w.user_status);

        session.set_name(w.user_name);
        session.set_statusmessage(w.user_status);
      }
      w.destroy();
    }

    private void user_button_menu_position_function(Gtk.Menu menu, out int x, out int y, out bool push_in) {
      button_user.get_event_window().get_origin(out x, out y);
      Gtk.Allocation allocation;
      button_user.get_allocation(out allocation);
      y += allocation.height;
      push_in = true;
    }

    private void on_outgoing_message(Message message) {
      session.on_own_message(message.to, message.message);
      session.send_message(message.to.friend_id, message.message);
    }

    private void on_outgoing_action(ActionMessage action) {
      session.on_own_action(action.to, action.message);
      session.send_action(action.to.friend_id, action.message);
    }

    private void on_outgoing_group_message(GroupMessage message) {
      session.group_message_send(message.to.group_id, message.message);
    }
    private void on_outgoing_group_action(GroupActionMessage action) {
      session.group_action_send(action.to.group_id, action.message);
    }

    private void on_outgoing_file(FileTransfer ft) {
      stdout.printf("sending file %s to %s\n",ft.name,ft.friend.name);
      uint8 filenumber = session.send_file_request(ft.friend.friend_id,ft.file_size,ft.name);
      if(filenumber != -1) {
        //ft.filenumber = filenumber;
        GLib.HashTable<uint8, FileTransfer> transfers = session.get_filetransfers();
        transfers[filenumber] = ft;
      } else {
        stderr.printf("failed to send file %s to %s", ft.name, ft.friend.name);
        ft.status = FileTransferStatus.SENDING_FAILED;
      }
    }

    public void set_urgency () {
      if(!has_focus && VenomSettings.instance.enable_urgency_notification) {
        this.set_urgency_hint(true);
      }
    }

    private bool on_treeview_key_pressed (Gtk.Widget source, Gdk.EventKey key) {
      if(key.keyval == Gdk.Key.Delete) {
        GLib.Object o = contact_list_tree_view.get_selected_entry();
        if(o is Contact) {
          remove_contact(o as Contact);
          return true;
        } else if(o is GroupChat) {
          remove_groupchat(o as GroupChat);
          return true;
        }
      }
      return false;
    }

    // Session Signal callbacks
    private void on_friendrequest(Contact c, string message) {
      string public_key_string = Tools.bin_to_hexstring(c.public_key);
      stdout.printf("[fr] %s:%s\n", public_key_string, message);

      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.NONE,
                                  "New friend request from '%s'.\nDo you want to accept?", public_key_string);
      message_dialog.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Accept", Gtk.ResponseType.ACCEPT, null);
      message_dialog.secondary_text = message;
          int response = message_dialog.run();
          message_dialog.destroy();
      if(response != Gtk.ResponseType.ACCEPT)
        return;

      Tox.FriendAddError friend_add_error = session.addfriend_norequest(c);
      if((int)friend_add_error < 0) {
        stderr.printf("Could not add friend: %s\n", Tools.friend_add_error_to_string(friend_add_error));
        return;
      }
      stdout.printf("Added new friend #%i\n", c.friend_id);
      contact_added(c);
      this.set_urgency();
    }
    private void on_friendmessage(Contact c, string message) {
      stdout.printf("<%s> %s:%s\n", new DateTime.now_local().format("%F"), c.name != null ? c.name : "<%i>".printf(c.friend_id), message);

      ConversationWidget w = open_conversation_with(c);
      incoming_message(new Message.incoming(c, message));
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        c.unread_messages++;
        contact_list_tree_view.update_entry(c);
      }
      this.set_urgency();
    }
    private void on_action(Contact c, string action) {
      stdout.printf("[ac] %i:%s\n", c.friend_id, action);
      ConversationWidget w = open_conversation_with(c);
      incoming_action(new ActionMessage.incoming(c, action));
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        c.unread_messages++;
        contact_list_tree_view.update_entry(c);
      }
      this.set_urgency();
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
      stdout.printf("Connection to DHT %s.\n", status ? "established" : "lost");
      if(status) {
        image_status.set_tooltip_text("Connected to network");
        session.set_userstatus(user_status);
      } else {
        image_status.set_tooltip_text("Disconnected from network");
        on_ownuserstatus(UserStatus.OFFLINE);
      }
      image_status.show();
      spinner_status.hide();
      spinner_status.stop();
    }

    private void on_ownuserstatus(UserStatus status) {
      //TODO clean up, decide what to do with deprecated GtkImageItems
      if(!session.connected || status == UserStatus.OFFLINE) {
        image_status.set_from_pixbuf(ResourceFactory.instance.offline);
        (menuitem_status.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.offline);
        set_title_from_status(UserStatus.OFFLINE);
        return;
      }
      set_title_from_status(status);

     switch(status) {
      case UserStatus.ONLINE:
        image_status.set_from_pixbuf(ResourceFactory.instance.online);
        (menuitem_status.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.online);
        break;
      case UserStatus.AWAY:
        image_status.set_from_pixbuf(ResourceFactory.instance.away);
        (menuitem_status.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.away);
        break;
      case UserStatus.BUSY:
        image_status.set_from_pixbuf(ResourceFactory.instance.busy);
        (menuitem_status.image as Gtk.Image).set_from_pixbuf(ResourceFactory.instance.busy);
        break;
     }
    }

    private void on_group_invite(Contact c, GroupChat g) {
      stdout.printf("Group invite from %s with public key %s\n", c.name, Tools.bin_to_hexstring(g.public_key));
      this.set_urgency();
      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.NONE,
                                  "'%s' has invited you to a groupchat, do you want to accept?",
                                    (c.name != null && c.name != "") ? c.name : Tools.bin_to_hexstring(c.public_key));
      message_dialog.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Accept", Gtk.ResponseType.ACCEPT, null);

      int response = message_dialog.run();
      message_dialog.destroy();
      if(response != Gtk.ResponseType.ACCEPT)
        return;

      bool ret = session.join_groupchat(c, g);
      if(ret == false) {
        stderr.printf("Could not join groupchat.\n");
        return;
      }
      stdout.printf("Joined Groupchat #%i\n", g.group_id);
      groupchat_added(g);
    }

    private void on_group_message(GroupChat g, int friendgroupnumber, string message) {
      string from_name = session.group_peername(g, friendgroupnumber);
      stdout.printf("[gm] %s [%i]@%i: %s\n", from_name, friendgroupnumber, g.group_id, message);

      GroupConversationWidget w = open_group_conversation_with(g);
      incoming_group_message(new GroupMessage.incoming(g, g.peers.get(friendgroupnumber), message));
      
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        g.unread_messages++;
        contact_list_tree_view.update_entry(g);
      }
      this.set_urgency();
    }

    private void on_group_action(GroupChat g, int friendgroupnumber, string message) {
      string from_name = session.group_peername(g, friendgroupnumber);
      stdout.printf("[ga] %s [%i]@%i: %s\n", from_name, friendgroupnumber, g.group_id, message);

      GroupConversationWidget w = open_group_conversation_with(g);
      incoming_group_action(new GroupActionMessage.incoming(g, g.peers.get(friendgroupnumber), message));
      
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        g.unread_messages++;
        contact_list_tree_view.update_entry(g);
      }
      this.set_urgency();
    }

    private void on_group_peer_changed(GroupChat g, int peernumber, Tox.ChatChange change) {
      GroupConversationWidget w = open_group_conversation_with(g);
      w.update_contact();
      groupchat_changed(g);
    }

    private void on_file_sendrequest(int friendnumber, uint8 filenumber, uint64 filesize,string filename) {
      stdout.printf ("received file send request friend: %i filenumber: %i filename: %s \n",friendnumber,filenumber,filename );
      Contact contact = session.get_contact_list()[friendnumber];
      FileTransfer ft = new FileTransfer(contact, FileTransferDirection.INCOMING, filesize, filename, null);
      GLib.HashTable<uint8,FileTransfer> transfers = session.get_filetransfers();
      transfers[filenumber] = ft;
      ConversationWidget w = conversation_widgets[friendnumber];
      w.on_incoming_filetransfer(ft);
      this.set_urgency();
    }

    private void send_file(int friendnumber, uint8 filenumber) {
      int chunk_size =  session.get_recommended_data_size(friendnumber);
      FileTransfer ft = session.get_filetransfers()[filenumber];
      ft.status = FileTransferStatus.IN_PROGRESS;
      if(ft == null) {
        stderr.printf("Trying to send unknown file");
        return;
      }
      File file = File.new_for_path(ft.path);
      GLib.FileInputStream file_stream = null;
      try {
        file_stream = file.read();
        var file_info = file.query_info ("*", FileQueryInfoFlags.NONE);
        uint64 file_size = file_info.get_size();
        uint64 remaining_bytes_to_send = file_size;
        uint8[] bytes = new uint8[chunk_size];
        bool read_more = true;
        while ( remaining_bytes_to_send > 0  ) {
          if(ft.status == FileTransferStatus.SENDING_FAILED) {
            return;
          }
          if(ft.status == FileTransferStatus.PAUSED) {
            Thread.usleep(2500);
            continue;
          }
          if(remaining_bytes_to_send < chunk_size) {
            chunk_size = (int) remaining_bytes_to_send;
            bytes = new uint8[chunk_size];
          }
          if(read_more) {
            size_t res = file_stream.read(bytes);
            if(res != chunk_size) {
              stderr.printf("Read incorrect number of bytes from file\n");
            }
          }
          int res = session.send_file_data(friendnumber,filenumber,bytes);
          if(res != -1) {
            remaining_bytes_to_send -= chunk_size;
            ft.bytes_processed += chunk_size;
            read_more = true;
          } else {
            read_more = false;
            Thread.usleep(25000);
          }
        }
        session.send_filetransfer_end(friendnumber,filenumber);
        ft.status = FileTransferStatus.DONE;
      } catch(IOError e) {
        stderr.printf("I/O error while trying to read file: %s\n",e.message);
      } catch(Error e) {
        stderr.printf("Unknown error while trying to read file: %s\n",e.message); 
      } finally {
        try {
          if(file_stream != null)
            file_stream.close();
        } catch(IOError e) {
          stderr.printf("I/O error while trying to close file stream: %s\n",e.message);
        }
      }
      stdout.printf("Ended file transfer for %s to %s\n",ft.name, (session.get_contact_list()[friendnumber]).name );
    }

    private void on_file_control_request(int friendnumber,uint8 filenumber,uint8 receive_send,uint8 status, uint8[] data) {
      FileTransfer ft = session.get_filetransfers()[filenumber];
      if(ft == null)
        return;
      if(status == Tox.FileControlStatus.ACCEPT && receive_send == 1) {
        stdout.printf("Contact accepted file sending request\n");
        new Thread<bool>(null, () => {
            send_file(friendnumber,filenumber);return true;
        });
      }
      if(status == Tox.FileControlStatus.KILL && receive_send == 1) {
        if(ft.status == FileTransferStatus.PENDING) {
          ft.status = FileTransferStatus.REJECTED;
        } else if(ft.direction == FileTransferDirection.OUTGOING) {
          ft.status = FileTransferStatus.SENDING_FAILED;
        } else if(ft.direction == FileTransferDirection.INCOMING) {
          ft.status = FileTransferStatus.RECEIVING_FAILED;
        }
        stderr.printf("File transfer was rejected for file number %u", filenumber);   
      }
      if(status == Tox.FileControlStatus.FINISHED && receive_send == 0) {
        ft.status = FileTransferStatus.DONE;
        stderr.printf("File transfer finished for file number %u",filenumber);
      }
    }

    private void on_file_data(int friendnumber,uint8 filenumber,uint8[] data) {
      FileTransfer ft = session.get_filetransfers()[filenumber];
      if(ft == null) {
        session.reject_file(friendnumber,filenumber);
        return;
      }
      string path = ft.path;
      File file = File.new_for_path(path);
      try{
        if(!file.query_exists())
          file.create(FileCreateFlags.NONE);
        FileOutputStream fos = file.append_to(FileCreateFlags.NONE);
        size_t bytes_written;
        fos.write_all(data,out bytes_written);
        ft.bytes_processed += bytes_written;
        fos.close();
      } catch (Error e){
        stderr.printf("Error while trying to write data to file\n");
        ft.status = FileTransferStatus.RECEIVING_FAILED;
      }
    }


    private ConversationWidget? open_conversation_with(Contact c) {
      ConversationWidget w = conversation_widgets[c.friend_id];
      if(w == null) {
        w = new ConversationWidget(c);
        w.load_history(session.load_history_for_contact(c));
        incoming_message.connect(w.on_incoming_message);
        incoming_action.connect(w.on_incoming_message);
        w.new_outgoing_message.connect(on_outgoing_message);
        w.new_outgoing_action.connect(on_outgoing_action);
        w.new_outgoing_file.connect(on_outgoing_file);
        w.filetransfer_accepted.connect ( (ft) => {
          session.accept_file(ft.friend.friend_id,ft.filenumber);
        });
        w.filetransfer_rejected.connect ( (ft) => {
          session.reject_file(ft.friend.friend_id,ft.filenumber);
        });
        conversation_widgets[c.friend_id] = w;
        notebook_conversations.append_page(w, null);
      }
      w.show_all();
      return w;
    }
    private GroupConversationWidget? open_group_conversation_with(GroupChat g) {
      GroupConversationWidget w = group_conversation_widgets[g.group_id];
      if(w == null) {
        w = new GroupConversationWidget(g);
        incoming_group_message.connect(w.on_incoming_message);
        incoming_group_action.connect(w.on_incoming_message);
        w.new_outgoing_message.connect(on_outgoing_group_message);
        w.new_outgoing_action.connect(on_outgoing_group_action);
        group_conversation_widgets[g.group_id] = w;
        notebook_conversations.append_page(w, null);
      }
      w.show_all();
      return w;
    }

    // Contact doubleclicked in treeview
    private void on_entry_activated(GLib.Object o) {
      if(o is Contact) {
        Contact c = o as Contact;
        ConversationWidget w = open_conversation_with(c);

        notebook_conversations.set_current_page(notebook_conversations.page_num(w));
        notebook_conversations.set_visible(true);
        if(c.unread_messages != 0) {
          c.unread_messages = 0;
          contact_list_tree_view.update_entry(c);
        }
      } else if(o is GroupChat) {
        GroupChat g = o as GroupChat;
        GroupConversationWidget w = open_group_conversation_with(g);

        notebook_conversations.set_current_page(notebook_conversations.page_num(w));
        notebook_conversations.set_visible(true);
        if(g.unread_messages != 0) {
          g.unread_messages = 0;
          contact_list_tree_view.update_entry(g);
        }
      }
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
      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.WARNING,
                                  Gtk.ButtonsType.NONE,
                                  "Are you sure you want to delete '%s' from your contact list?", name);
      message_dialog.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Delete", Gtk.ResponseType.OK, null);
      int response = message_dialog.run();
      message_dialog.destroy();
      if(response != Gtk.ResponseType.OK)
        return;

      if(!session.del_friend(c)) {
        stderr.printf("Could not remove contact %i.\n", c.friend_id);
        return;
      }
      contact_removed(c);
    }

    public void remove_groupchat(GroupChat g) {
      if(g == null)
        return;
      string name = "groupchat #%i".printf(g.group_id);
      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.WARNING,
                                  Gtk.ButtonsType.NONE,
                                  "Are you sure you want to delete '%s' from your contact list?", name);
      message_dialog.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Delete", Gtk.ResponseType.OK, null);
      int response = message_dialog.run();
      message_dialog.destroy();
      if(response != Gtk.ResponseType.OK)
        return;

      if(!session.del_groupchat(g)) {
        stderr.printf("Could not remove %s.\n", name);
        return;
      }
      groupchat_removed(g);
    }

    public void add_contact(string contact_id_string, string contact_message = ResourceFactory.instance.default_add_contact_message) {
      string trimmed_id = contact_id_string.dup();
      try {
			var regex = new GLib.Regex ("\\s");
			  trimmed_id = regex.replace(trimmed_id, -1, 0, "");
		  } catch (GLib.RegexError e) {
			  GLib.assert_not_reached ();
		  }
      if(trimmed_id.length != Tox.FRIEND_ADDRESS_SIZE * 2) {
        string error_message = "Could not add friend: Invalid ID\n";
        stderr.printf(error_message);
        UITools.ErrorDialog("Adding Friend failed", error_message, this);
        return;
      }

      uint8[] contact_id = Tools.hexstring_to_bin(trimmed_id);
      // add friend
      if(contact_id == null || contact_id.length != Tox.FRIEND_ADDRESS_SIZE) {
        string error_message = "Could not add friend: Invalid ID\n";
        stderr.printf(error_message);
        UITools.ErrorDialog("Adding Friend failed", error_message, this);
        return;
      }
      Contact c = new Contact(contact_id);
      Tox.FriendAddError ret = session.addfriend(c, contact_message);
      if(ret < 0) {
        string error_message = "Could not add friend: %s.\n".printf(Tools.friend_add_error_to_string(ret));
        stderr.printf(error_message);
        UITools.ErrorDialog("Adding Friend failed", error_message, this);
        return;
      }

      stdout.printf("Friend request successfully sent. Friend added as %i.\n", (int)ret);
      contact_added(c);
    }

    // GUI Events
    public void button_add_contact_clicked(Gtk.Button source) {
      AddContactDialog dialog = new AddContactDialog();
      dialog.set_modal(true);
      dialog.set_transient_for(this);

      int response = dialog.run();
      string contact_id_string = dialog.contact_id;
      string contact_message = dialog.contact_message;
      dialog.destroy();

      if(response != Gtk.ResponseType.OK)
          return;

      add_contact(contact_id_string, contact_message);
    }

    public void button_group_chat_clicked(Gtk.Button source) {
      GroupChat g = session.add_groupchat();
      if(g == null) {
        stderr.printf("Could not create a new groupchat.\n");
        return;
      }
      groupchat_added(g);
    }

    public void button_preferences_clicked(Gtk.Button source) {
      //PreferencesWindow preferences_window = new PreferencesWindow();
      //preferences_window.run();
      //preferences_window.destroy();
    }
  }
}
