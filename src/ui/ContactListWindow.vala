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
    private const GLib.ActionEntry win_entries[] =
    {
      { "edit-user", edit_user_information }
    };
    private const GLib.ActionEntry app_entries[] =
    {
      { "copy-id", copy_id_to_clipboard }
    };
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
    private EditableLabel label_name;
    private EditableLabel label_status;
    private ContactListTreeView contact_list_tree_view;
    private Gtk.ComboBox combobox_status;
    private Gtk.Notebook notebook_conversations;
    private Gtk.Menu menu_user;
    private Gtk.ToggleButton button_user;

    private bool cleaned_up = false;

    private string our_title = "";

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
      init_user();

      //on_ownconnectionstatus(false);

      Logger.log(LogLevel.INFO, "ID: " + Tools.bin_to_hexstring(session.get_address()));
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

      Logger.log(LogLevel.DEBUG, "Ending session...");
      // Stop background thread
      session.stop();
      // wait for background thread to finish
      session.join();

      // Save session before shutdown
      save_session();

      Logger.log(LogLevel.DEBUG, "Session ended gracefully.");
      cleaned_up = true;
    }

    private void save_session() {
      Logger.log(LogLevel.INFO, "Saving tox session data");
      try {
        session.save_to_file(ResourceFactory.instance.data_filename);
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Saving session file failed: " + e.message);
      }

    }

    private void init_theme() {
      Gtk.CssProvider provider = new Gtk.CssProvider();
      try {
        provider.load_from_path(ResourceFactory.instance.default_theme_filename);
      } catch (Error e) {
        string message = _("Could not read theme from \"%s\"").printf(ResourceFactory.instance.default_theme_filename);
        Logger.log(LogLevel.ERROR, message);
        UITools.show_error_dialog(message, e.message, this);
        return;
      }

      Gdk.Screen screen = Gdk.Screen.get_default();
      Gtk.StyleContext.add_provider_for_screen(screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }

    // Create a new session, load/create session data
    private void init_session() {
      session = new ToxSession();
      AVManager.instance.tox_session = session;
      try {
        session.load_from_file(ResourceFactory.instance.data_filename);
      } catch (Error e) {
          Logger.log(LogLevel.INFO, "Could not load session data (%s), creating new one.".printf(e.message));

          session.set_name(ResourceFactory.instance.default_username);
          session.set_status_message(ResourceFactory.instance.default_statusmessage);

          save_session();
      }
    }

    // Initialize widgets
    private void init_widgets() {
      // Set up Window
      set_default_size(Settings.instance.contactlist_width, Settings.instance.contactlist_height);
      show_menubar = false;
      add_action_entries(win_entries, this);
      application.add_action_entries(app_entries, this);
      try {
        Gtk.IconTheme theme = Gtk.IconTheme.get_default();
        theme.append_search_path(Path.build_filename("share", "pixmaps"));
        theme.append_search_path(Path.build_filename("..", "share", "pixmaps"));
        set_default_icon(Gtk.IconTheme.get_default().load_icon("venom", 48, 0));
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error while loading icon: " + e.message);
      }
      set_title_from_status(user_status);

      // Load widgets from file
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/contact_list.ui");
      } catch (GLib.Error e) {
        Logger.log(LogLevel.FATAL, "Loading contact list failed: " + e.message);
      }

      Gtk.Paned paned = builder.get_object("paned") as Gtk.Paned;
      this.add(paned);

      image_status = builder.get_object("image_status") as Gtk.Image;
      spinner_status = builder.get_object("spinner_status") as Gtk.Spinner;
      image_userimage = builder.get_object("image_userimage") as Gtk.Image;

      Gtk.Label label_name_child = builder.get_object("label_username") as Gtk.Label;
      Gtk.Label label_status_child = builder.get_object("label_userstatus") as Gtk.Label;
      Gtk.Box box_self_info_text = builder.get_object("box_self_info_text") as Gtk.Box;
      box_self_info_text.remove(label_name_child);
      box_self_info_text.remove(label_status_child);
      label_name = new EditableLabel.with_label(label_name_child);
      label_status = new EditableLabel.with_label(label_status_child);
      box_self_info_text.pack_start(label_name, false);
      box_self_info_text.pack_start(label_status, false);
      box_self_info_text.show_all();

      combobox_status = builder.get_object("combobox_status") as Gtk.ComboBox;
      Gtk.ListStore liststore_status = new Gtk.ListStore (2, typeof(string), typeof(ContactFilter));
      combobox_status.set_model(liststore_status);

      ContactFilter filter_online = new ContactFilterOnline();
      ContactFilter filter_all = new ContactFilterAll();
      ContactFilter filter_default = filter_all;
      // Add our connection status to the treeview
      Gtk.TreeIter iter;
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, _("Online"), 1, filter_online, -1);
      liststore_status.append(out iter);
      liststore_status.set(iter, 0, _("All"), 1, filter_all, -1);
      combobox_status.set_active_iter(iter);

      // Add cellrenderer
      Gtk.CellRendererText cell_renderer_status = new Gtk.CellRendererText();
      combobox_status.pack_start(cell_renderer_status, true);
      combobox_status.add_attribute(cell_renderer_status, "text", 0);

      Gtk.Image image_add_contact = builder.get_object("image_add_contact") as Gtk.Image;
      Gtk.Image image_group_chat  = builder.get_object("image_group_chat") as Gtk.Image;
      Gtk.Image image_preferences = builder.get_object("image_preferences") as Gtk.Image;
      Gtk.Image image_filetransfer = builder.get_object("image_filetransfer") as Gtk.Image;

      Gtk.ImageMenuItem menuitem_edit_info = builder.get_object("menuitem_edit_info") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_copy_id   = builder.get_object("menuitem_copy_id") as Gtk.ImageMenuItem;

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

      Gtk.MenuItem menuitem_export = builder.get_object("menuitem_export") as Gtk.MenuItem;
      Gtk.MenuItem menuitem_import = builder.get_object("menuitem_import") as Gtk.MenuItem;

      Gtk.ImageMenuItem menuitem_about = builder.get_object("menuitem_about") as Gtk.ImageMenuItem;
      Gtk.ImageMenuItem menuitem_quit  = builder.get_object("menuitem_quit") as Gtk.ImageMenuItem;

      image_status.set_from_pixbuf(ResourceFactory.instance.offline);
      image_userimage.set_from_pixbuf(ResourceFactory.instance.default_contact);

      image_add_contact.set_from_pixbuf(ResourceFactory.instance.add);
      image_group_chat.set_from_pixbuf(ResourceFactory.instance.groupchat);
      image_preferences.set_from_pixbuf(ResourceFactory.instance.settings);
      image_filetransfer.set_from_pixbuf(ResourceFactory.instance.filetransfer);

      // Create and add custom treeview
      contact_list_tree_view = new ContactListTreeView();
      contact_list_tree_view.show_all();

      Gtk.TreeModel m = contact_list_tree_view.model;
      Gtk.TreeModelFilter contact_list_tree_model_filter = new Gtk.TreeModelFilter(m, null);
      contact_list_tree_model_filter.set_visible_func(filter_default.filter_func);
      contact_list_tree_view.model = contact_list_tree_model_filter;

      Gtk.ScrolledWindow scrolled_window_contact_list = builder.get_object("scrolled_window_contact_list") as Gtk.ScrolledWindow;
      scrolled_window_contact_list.add(contact_list_tree_view);

      menu_user = builder.get_object("menu_user") as Gtk.Menu;
      menu_user.attach_widget = this;
      button_user = builder.get_object("button_user") as Gtk.ToggleButton;
      Gtk.Button button_add_contact = builder.get_object("button_add_contact") as Gtk.Button;
      Gtk.Button button_group_chat = builder.get_object("button_group_chat") as Gtk.Button;

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
        button_user.active = false;
      });
      /*button_user.button_press_event.connect( (widget, event) => {
        if(event.type == Gdk.EventType.BUTTON_PRESS) {
          if(event.button == Gdk.BUTTON_PRIMARY)
            menu_user.popup(null, null, null, event.button, event.time);
        }
        return false;
      });*/
      button_add_contact.clicked.connect(() => { add_contact(); });
      button_group_chat.clicked.connect(button_group_chat_clicked);

      // Workaround for gtk+ 3.4 MenuItems not deriving from Gtk.Actionable
      menuitem_copy_id.activate.connect(  () => {application.activate_action("copy-id",  null);});
      menuitem_edit_info.activate.connect(() => {activate_action("edit-user",  null);});
      menuitem_export.activate.connect(() => {UITools.export_datafile(this, session);});
      menuitem_import.activate.connect(() => {UITools.import_datafile(this, session);});
      menuitem_about.activate.connect(() => {application.activate_action("about", null);});
      menuitem_quit.activate.connect( () => {application.activate_action("quit",  null);});

      menuitem_status_online.activate.connect(  () => { set_userstatus(UserStatus.ONLINE); } );
      menuitem_status_away.activate.connect(    () => { set_userstatus(UserStatus.AWAY); } );
      menuitem_status_busy.activate.connect(    () => { set_userstatus(UserStatus.BUSY); } );
      menuitem_status_offline.activate.connect( () => { set_userstatus(UserStatus.OFFLINE); } );

      notebook_conversations = builder.get_object("notebook_conversations") as Gtk.Notebook;
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
      session.on_typing_change.connect(this.on_typing_change);

      //Window signals
      this.delete_event.connect((e) => {
        if(Settings.instance.enable_tray) {
          this.hide();
            return true;
        }
        return false;
      });
        
      this.window_state_event.connect( (e) => {
		if ((e.new_window_state == Gdk.WindowState.ICONIFIED) && Settings.instance.enable_tray){
          this.hide();
          return true;
        }
		return false;
      } ) ;

      //groupmessage signals
      session.on_group_invite.connect(this.on_group_invite);
      session.on_group_message.connect(this.on_group_message);
      session.on_group_action.connect(this.on_group_action);
      session.on_group_peer_changed.connect(this.on_group_peer_changed);

      /*=== AV signals ===*/
      session.on_av_invite.connect(this.on_av_invite);
      session.on_av_start.connect(AVManager.instance.on_start_call);
      session.on_av_end.connect(AVManager.instance.on_end_call);
      //av responses
      session.on_av_starting.connect(AVManager.instance.on_start_call);
      session.on_av_ending.connect(AVManager.instance.on_end_call);
      //av protocol
      session.on_av_peer_timeout.connect(AVManager.instance.on_end_call);
      //disconnecting peers
      session.on_connection_status.connect((c) => {
        if(!c.online && c.call_state != CallState.ENDED) {
          AVManager.instance.on_end_call(c);
        }
      });

      //file signals
      session.on_file_sendrequest.connect(this.on_file_sendrequest);
      session.on_file_control.connect(this.on_file_control_request);
      session.on_file_data.connect(this.on_file_data);

      // Contact list treeview signals
      contact_added.connect(contact_list_tree_view.add_entry);
      groupchat_added.connect(contact_list_tree_view.add_entry);

      contact_changed.connect( (c) => {
        session.save_extended_contact_data(c);
        contact_list_tree_view.update_entry(c);
        ConversationWidget w = conversation_widgets[c.friend_id];
        if(w != null)
          w.update_contact();
      } );
      groupchat_changed.connect( (g) => {
        contact_list_tree_view.update_entry(g);
        GroupConversationWidget w = group_conversation_widgets[g.group_id];
        if(w != null)
          w.update_groupchat_info();
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
      contact_list_tree_view.button_release_event.connect(
        on_treeview_button_release);

      //ComboboxStatus signals
      combobox_status.changed.connect(combobox_status_changed);

      this.focus_in_event.connect((e)  => {
        this.set_urgency_hint(false);
        this.set_title(this.our_title);
        return false;
      });

      this.configure_event.connect((sender, event) => {
        // only save unmaximized window sizes
        if((get_window().get_state() & Gdk.WindowState.MAXIMIZED) == 0) {
          if(notebook_conversations.visible) {
            Settings.instance.window_width  = event.width;
            Settings.instance.window_height = event.height;
          } else {
            Settings.instance.contactlist_width  = event.width;
            Settings.instance.contactlist_height = event.height;
          }
          Settings.instance.save_settings_with_timeout(ResourceFactory.instance.config_filename);
        }
        return false;
      });

      label_name.label_changed.connect((str) => {
        if(str != "") {
          User.instance.name = str;
        }
      });
      label_status.label_changed.connect((str) => {
        if(str != "") {
          User.instance.status_message = str;
        }
      });

#if DEBUG
      key_press_event.connect((source, key) => {
        if(key.keyval == Gdk.Key.F5) {
          init_theme();
          Logger.log(LogLevel.INFO, "Theme refreshed");
          return true;
        }
        return false;
      });
#endif
    }

    private void init_save_session_hooks() {
      contact_added.connect(             () => {save_session();});
      contact_removed.connect(           () => {save_session();});
      groupchat_added.connect(           () => {save_session();});
      groupchat_removed.connect(         () => {save_session();});
      label_name.label_changed.connect(  () => {save_session();});
      label_status.label_changed.connect(() => {save_session();});
    }

    // Restore friends from datafile
    private void init_contacts() {
      GLib.HashTable<int, Contact> contacts = session.get_contact_list();
      contacts.foreach((key, val) => {
        Logger.log(LogLevel.INFO, "Retrieved contact %s from savefile.".printf(Tools.bin_to_hexstring(val.public_key)));
        contact_added(val);
      });
    }

    private void init_user() {
      User.instance.name = session.get_self_name();
      User.instance.status_message = session.get_self_status_message();

      label_name.label.label = User.instance.name;
      label_name.label.tooltip_text = User.instance.name;

      label_status.label.label = User.instance.status_message;
      label_status.label.tooltip_text = User.instance.status_message;

      User.instance.notify["name"].connect(() => {
        if( session.set_name(User.instance.name) ) {
          label_name.label.label = User.instance.name;
          label_name.label.tooltip_text = User.instance.name;
        } else {
          Logger.log(LogLevel.ERROR, "Could not change user name!");
        }
      });
      User.instance.notify["status-message"].connect(() => {
        if( session.set_status_message(User.instance.status_message) ) {
          label_status.label.label = User.instance.status_message;
          label_status.label.tooltip_text = User.instance.status_message;
        } else {
          Logger.log(LogLevel.ERROR, "Could not change user statusmessage!");
        }
      });
    }

    private bool on_treeview_button_release (Gdk.EventButton event) {
      if(event.button == Gdk.BUTTON_SECONDARY) {
        GLib.Object o = contact_list_tree_view.get_selected_entry();
        Gtk.Menu menu = null;
        if(o is Contact) {
          menu = UITools.show_contact_context_menu(this, (Contact)o);
        } else if(o is GroupChat) {
          menu = UITools.show_groupchat_context_menu(this, (GroupChat)o);
        } else {
          // empty treeview clicked
          return false;
        }
        menu.show_all();
        menu.attach_to_widget(this, null);
        menu.hide.connect(() => {menu.detach();});
        menu.popup(null, null, null, 0, 0);
        return false;
      }
      return false;
    }

    private void set_title_from_status(UserStatus status) {
      this.our_title = "Venom (%s)".printf(status.to_string());
      string notify = "";
      if (this.get_urgency_hint()) {
        notify = "* ";
      }
      set_title(notify + this.our_title);
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
      session.set_user_status(status);

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
      Logger.log(LogLevel.INFO, "Copied Tox ID to clipboard");
    }

    private void edit_user_information() {
      UserInfoWindow w = new UserInfoWindow();

      w.application = application;
      w.user_name = User.instance.name;
      w.max_name_length = Tox.MAX_NAME_LENGTH;
      w.user_status = label_status.label.label;
      w.max_status_length = Tox.MAX_STATUSMESSAGE_LENGTH;
      w.user_image = image_userimage.get_pixbuf();
      w.user_id = Tools.bin_to_hexstring(session.get_address());

      w.set_modal(true);
      w.set_transient_for(this);
      int response = w.run();

      if(response == Gtk.ResponseType.APPLY) {
        //TODO once possible in core
        image_userimage.set_from_pixbuf(w.user_image);

        User.instance.name = w.user_name;
        User.instance.status_message = w.user_status;
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

    public unowned GLib.HashTable<int, GroupChat> get_groupchats() {
      return session.get_groupchats();
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
      Logger.log(LogLevel.INFO, "sending file %s to %s\n".printf(ft.name,ft.friend.name));
      uint8 filenumber = session.send_file_request(ft.friend.friend_id,ft.file_size,ft.name);
      if(filenumber != -1) {
        ft.filenumber = filenumber;
        GLib.HashTable<uint8, FileTransfer> transfers = session.get_contact_list()[ft.friend.friend_id].get_filetransfers();
        transfers[filenumber] = ft;
      } else {
        Logger.log(LogLevel.ERROR, "failed to send file %s to %s".printf(ft.name, ft.friend.name));
        ft.status = FileTransferStatus.SENDING_FAILED;
      }
    }

    public void set_urgency (string? sound = null) {
      if(is_active) {
        return;
      }
      if(Settings.instance.enable_urgency_notification) {
        this.set_urgency_hint(true);
      }
      if(sound != null && Settings.instance.enable_notify_sounds) {
        AVManager.instance.play_sound(sound);
      }
      this.set_title("* %s".printf(this.our_title));
    }

    private bool on_treeview_key_pressed (Gtk.Widget source, Gdk.EventKey key) {
      if(key.keyval == Gdk.Key.Delete) {
        IContact c = contact_list_tree_view.get_selected_entry();
        if(c is Contact) {
          remove_contact(c as Contact);
          return true;
        } else if(c is GroupChat) {
          remove_groupchat(c as GroupChat);
          return true;
        }
      }
      return false;
    }

    // Session Signal callbacks
    private void on_friendrequest(Contact c, string message) {
      string public_key_string = Tools.bin_to_hexstring(c.public_key);
      Logger.log(LogLevel.INFO, "[fr] " + public_key_string + ":" + message);

      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.NONE,
                                  _("New friend request from '%s'.\nDo you want to accept?"), public_key_string);
      message_dialog.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Accept"), Gtk.ResponseType.ACCEPT, null);
      message_dialog.secondary_text = message;
          int response = message_dialog.run();
          message_dialog.destroy();
      if(response != Gtk.ResponseType.ACCEPT)
        return;

      int friend_add_error = session.add_friend_norequest(c);
      if(friend_add_error < 0) {
        Logger.log(LogLevel.ERROR, "Friend could not be added.");
        return;
      }
      Logger.log(LogLevel.INFO, "Added new friend #%i".printf(c.friend_id));
      contact_added(c);
    }
    private void on_typing_change(Contact c, bool is_typing) {
      if(Settings.instance.show_typing_status) {
        ConversationWidget w = open_conversation_with(c);
        w.on_typing_changed(is_typing);
      }
    }
    private void on_friendmessage(Contact c, string message) {
      Logger.log(LogLevel.DEBUG, "<%s> %s:%s".printf(new DateTime.now_local().format("%F"), c.name != null ? c.name : "<%i>".printf(c.friend_id), message));

      ConversationWidget w = open_conversation_with(c);
      incoming_message(new Message.incoming(c, message));
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        c.unread_messages++;
        contact_list_tree_view.update_entry(c);
      }
      this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "new-message.wav"));
    }
    private void on_action(Contact c, string action) {
      Logger.log(LogLevel.DEBUG, "[ac] %i:%s".printf(c.friend_id, action));
      ConversationWidget w = open_conversation_with(c);
      incoming_action(new ActionMessage.incoming(c, action));
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        c.unread_messages++;
        contact_list_tree_view.update_entry(c);
      }
      this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "new-message.wav"));
    }
    private void on_namechange(Contact c, string? old_name) {
      Logger.log(LogLevel.INFO, old_name + " changed name to " + c.name);
      contact_changed(c);
    }
    private void on_statusmessage(Contact c, string? old_status) {
      Logger.log(LogLevel.INFO, c.name + " changed status to " + c.status_message);
      contact_changed(c);
    }
    private void on_userstatus(Contact c, uint8 old_status) {
      Logger.log(LogLevel.INFO, "[us] %s:%i".printf(c.name, c.user_status));
      contact_changed(c);
    }
    private void on_read_receipt(Contact c, uint32 receipt) {
      Logger.log(LogLevel.INFO, "[rr] %s:%u".printf(c.name, receipt));
    }
    private void on_connectionstatus(Contact c) {
      Logger.log(LogLevel.INFO, "%s is now %s.".printf(c.name, c.online ? "online" : "offline"));
      contact_changed(c);
    }

    private void on_ownconnectionstatus(bool status) {
      Logger.log(LogLevel.INFO, "Connection to DHT " + (status ? "established" : "lost"));
      if(status) {
        image_status.set_tooltip_text(_("Connected to the network"));
        session.set_user_status(user_status);
        if(Settings.instance.enable_notify_sounds) {
          AVManager.instance.play_sound(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "log-in.wav"));
        }
      } else {
        image_status.set_tooltip_text(_("Disconnected from the network"));
        on_ownuserstatus(UserStatus.OFFLINE);
        if(Settings.instance.enable_notify_sounds) {
          AVManager.instance.play_sound(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "log-out.wav"));
        }
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
      Logger.log(LogLevel.INFO, "Group invite from %s with public key %s".printf(c.name, Tools.bin_to_hexstring(g.public_key)));
      this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "new-message.wav"));
      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.NONE,
                                  _("'%s' has invited you to a groupchat, do you want to accept?"),
                                    (c.name != null && c.name != "") ? c.name : Tools.bin_to_hexstring(c.public_key));
      message_dialog.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Accept"), Gtk.ResponseType.ACCEPT, null);

      int response = message_dialog.run();
      message_dialog.destroy();
      if(response != Gtk.ResponseType.ACCEPT)
        return;

      bool ret = session.join_groupchat(c, g);
      if(ret == false) {
        Logger.log(LogLevel.ERROR, "Could not join groupchat.");
        return;
      }
      Logger.log(LogLevel.INFO, "Joined Groupchat #%i".printf(g.group_id));
      groupchat_added(g);
    }

    private void on_group_message(GroupChat g, int friendgroupnumber, string message) {
      string from_name = session.group_peername(g, friendgroupnumber);
      Logger.log(LogLevel.DEBUG, "[gm] %s [%i]@%i: %s".printf(from_name, friendgroupnumber, g.group_id, message));

      GroupConversationWidget w = open_group_conversation_with(g);

      //FIXME remove this workaround as soon as the problem gets fixed in the core
      /** BEGIN **/
      GroupChatContact gcc = g.peers.get(friendgroupnumber);
      if(gcc == null) {
        Logger.log(LogLevel.ERROR, "Group message from unknown contact #%i [%i]".printf(friendgroupnumber, g.group_id));
        gcc = new GroupChatContact(friendgroupnumber);
        g.peers.set(friendgroupnumber, gcc);
        on_group_peer_changed(g, friendgroupnumber, Tox.ChatChange.PEER_ADD);
      }
      /** END **/
      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        g.unread_messages++;
        contact_list_tree_view.update_entry(g);
      }
      GroupMessage group_message = new GroupMessage.incoming(g, gcc, message);
      // only set urgency in groupchat if the message contains our name
      if(User.instance.name in message) {
        this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "new-message.wav"));
        group_message.important = true;
      }
      incoming_group_message(group_message);
    }

    private void on_group_action(GroupChat g, int friendgroupnumber, string message) {
      string from_name = session.group_peername(g, friendgroupnumber);
      Logger.log(LogLevel.DEBUG, "[ga] %s [%i]@%i: %s".printf(from_name, friendgroupnumber, g.group_id, message));

      GroupConversationWidget w = open_group_conversation_with(g);

      //FIXME remove this workaround as soon as the problem gets fixed in the core
      /** BEGIN **/
      GroupChatContact gcc = g.peers.get(friendgroupnumber);
      if(gcc == null) {
        Logger.log(LogLevel.ERROR, "Group action from unknown contact #%i [%i]".printf(friendgroupnumber, g.group_id));
        gcc = new GroupChatContact(friendgroupnumber);
        g.peers.set(friendgroupnumber, gcc);
        on_group_peer_changed(g, friendgroupnumber, Tox.ChatChange.PEER_ADD);
      }
      /** END **/

      if(notebook_conversations.get_current_page() != notebook_conversations.page_num(w)) {
        g.unread_messages++;
        contact_list_tree_view.update_entry(g);
      }
      GroupActionMessage group_message = new GroupActionMessage.incoming(g, gcc, message);
      // only set urgency in groupchat if the message contains our name
      if(User.instance.name in message) {
        this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "new-message.wav"));
        group_message.important = true;
      }
      incoming_group_action(group_message);
    }

    private void on_group_peer_changed(GroupChat g, int peernumber, Tox.ChatChange change) {
      GroupConversationWidget w = open_group_conversation_with(g);
      w.update_contact(peernumber, change);
      groupchat_changed(g);
    }

    private void on_av_invite(Contact c) {
      this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, (c.video ? "incoming-video-call.wav" : "incoming-call")));
      if(c.auto_video && c.video || c.auto_audio && !c.video) {
        //Auto accept
        session.answer_call(c);
        return;
      }
      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.QUESTION,
                                  Gtk.ButtonsType.NONE,
                                  "");
      message_dialog.set_markup(_("'%s' is calling (%s) ...").printf(c.get_name_string(), c.video ? _("Video call") : _("Audio only")));
      message_dialog.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Accept"), Gtk.ResponseType.ACCEPT, null);
      //close message dialog when callstate changes (timeout, cancel, ...)
      c.notify["call-state"].connect(() => {
        message_dialog.destroy();
      });

      int response = message_dialog.run();
      message_dialog.destroy();

      if(c.call_state != CallState.CALLING) {
        //when remote cancels the request
        Logger.log(LogLevel.DEBUG, "call with %s already canceled".printf(c.name));
        return;
      }

      if(response == Gtk.ResponseType.ACCEPT) {
        session.answer_call(c);
      } else {
        session.reject_call(c);
      }
    }

    private void on_start_audio_call(Contact c) {
      session.start_audio_call(c);
    }

    private void on_start_video_call(Contact c) {
      session.start_video_call(c);
    }

    private void on_stop_audio_call(Contact c) {
      Logger.log(LogLevel.DEBUG, "on_stop_audio_call");
      switch(c.call_state) {
        case CallState.RINGING:
          Logger.log(LogLevel.DEBUG, "cancelling call with %s".printf(c.name));
          session.cancel_call(c);
          break;
        case CallState.CALLING:
          Logger.log(LogLevel.DEBUG, "rejecting call from %s".printf(c.name));
          session.reject_call(c);
          break;
        case CallState.STARTED:
          Logger.log(LogLevel.DEBUG, "hanging up on %s".printf(c.name));
          session.hangup_call(c);
          break;
        case CallState.ENDED:
          Logger.log(LogLevel.DEBUG, "call with %s already ended".printf(c.name));
          break;
        default:
          assert_not_reached();
      }
    }

    private void on_stop_video_call(Contact c) {
      //TODO
    }

    private void on_file_sendrequest(int friendnumber, uint8 filenumber, uint64 filesize,string filename) {
      Logger.log(LogLevel.INFO, "received file send request friend: %i filenumber: %i filename: %s ".printf(friendnumber, filenumber, filename));
      Contact contact = session.get_contact_list()[friendnumber];
      FileTransfer ft;
      if((filename.has_suffix(".png") || filename.has_suffix(".jpg") || filename.has_suffix(".jpeg")) && filesize <= 0x100000) {
        ft = new FileTransfer.recvdata(contact, filename, filesize);
      } else {
        ft = new FileTransfer(contact, FileTransferDirection.INCOMING, filesize, filename, null);
      }

      ft.filenumber = filenumber;
      GLib.HashTable<uint8,FileTransfer> transfers = session.get_contact_list()[friendnumber].get_filetransfers();
      transfers[filenumber] = ft;
      ConversationWidget w = conversation_widgets[friendnumber];
      w.on_incoming_filetransfer(ft);

      if(!ft.isfile) {
        session.accept_file(friendnumber, filenumber);
        ft.status = FileTransferStatus.IN_PROGRESS;
      }

      this.set_urgency(Path.build_filename("file://" + ResourceFactory.instance.sounds_directory, "transfer-pending.wav"));
    }

    private void send_file(int friendnumber, uint8 filenumber) {
      int chunk_size =  session.get_recommended_data_size(friendnumber);
      FileTransfer ft = session.get_contact_list()[friendnumber].get_filetransfers()[filenumber];
      ft.status = FileTransferStatus.IN_PROGRESS;
      if(ft == null) {
        Logger.log(LogLevel.ERROR, "Trying to send unknown file");
        return;
      }

      GLib.FileInputStream file_stream = null;
      File file = null;

      if(ft.isfile) {
        file = File.new_for_path(ft.path);
      }

      try {
        uint64 file_size;

        if(ft.isfile) {
          file_stream = file.read();
          var file_info = file.query_info ("*", FileQueryInfoFlags.NONE);
          file_size = file_info.get_size();
        } else {
          file_size = ft.file_size;
        }

        uint64 remaining_bytes_to_send = file_size - ft.bytes_processed;
        uint8[] bytes = new uint8[chunk_size];
        bool read_more = true;
        while ( remaining_bytes_to_send > 0 ) {
          if(ft.status == FileTransferStatus.SENDING_FAILED || ft.status == FileTransferStatus.CANCELED
             || ft.status == FileTransferStatus.SENDING_BROKEN) {
            return;
          }
          if(ft.status == FileTransferStatus.PAUSED) {
            Thread.usleep(1000);
            continue;
          }

          if(remaining_bytes_to_send < chunk_size) {
            chunk_size = (int) remaining_bytes_to_send;
            bytes = new uint8[chunk_size];
          }
          if(read_more) {
            if(ft.isfile) {
              size_t res = file_stream.read(bytes);
              if(res != chunk_size) {
                Logger.log(LogLevel.ERROR, "Read incorrect number of bytes from file");
              }
            } else {
              Memory.copy(bytes, (uint8*)ft.data + ft.bytes_processed, chunk_size);
            }
          }
          int res = session.send_file_data(friendnumber,filenumber,bytes);
          if(res != -1) {
            remaining_bytes_to_send -= chunk_size;
            ft.bytes_processed += chunk_size;
            read_more = true;
          } else {
            read_more = false;
            Thread.usleep(1000);
          }
        }
        session.send_filetransfer_end(friendnumber,filenumber);
        ft.status = FileTransferStatus.DONE;
      } catch(IOError e) {
        Logger.log(LogLevel.ERROR, "I/O error while trying to read file: " + e.message);
      } catch(Error e) {
        Logger.log(LogLevel.ERROR, "Unknown error while trying to read file: " + e.message);
      } finally {
        try {
          if(file_stream != null)
            file_stream.close();
        } catch(IOError e) {
          Logger.log(LogLevel.ERROR, "I/O error while trying to close file stream: " + e.message);
        }
      }
      Logger.log(LogLevel.INFO, "Ended file transfer for %s to %s".printf(ft.name, (session.get_contact_list()[friendnumber]).name));
    }

    private void on_file_control_request(int friendnumber,uint8 filenumber,uint8 receive_send,uint8 status, uint8[] data) {
      FileTransfer ft = session.get_contact_list()[friendnumber].get_filetransfers()[filenumber];
      if(ft == null)
        return;
      if(status == Tox.FileControlStatus.ACCEPT && receive_send == 1) {
        Logger.log(LogLevel.INFO, "Contact accepted file sending request");
        new Thread<bool>(null, () => {
            send_file(friendnumber,filenumber);return true;
        });
      }

      if(status == Tox.FileControlStatus.ACCEPT && receive_send == 0) {
        ft.status = FileTransferStatus.IN_PROGRESS;
      }

      if(status == Tox.FileControlStatus.KILL && receive_send == 1) {
        if(ft.status == FileTransferStatus.PENDING) {
          ft.status = FileTransferStatus.REJECTED;
        } else if(ft.direction == FileTransferDirection.OUTGOING) {
          ft.status = FileTransferStatus.SENDING_FAILED;
        } else if(ft.direction == FileTransferDirection.INCOMING) {
          ft.status = FileTransferStatus.RECEIVING_FAILED;
        }
        Logger.log(LogLevel.INFO, "File transfer was rejected for file number %u".printf(filenumber));
      }
      if(status == Tox.FileControlStatus.FINISHED && receive_send == 0) {
        ft.status = FileTransferStatus.DONE;
        Logger.log(LogLevel.INFO, "File transfer finished for file number %u".printf(filenumber));
      }

      if(status == Tox.FileControlStatus.RESUME_BROKEN && receive_send == 1) {
        ft.bytes_processed = ((uint64[])data)[0];
        ft.status = FileTransferStatus.IN_PROGRESS;
        session.accept_file_resume(friendnumber, filenumber);
        new Thread<bool>(null, () => {
            send_file(friendnumber,filenumber);return true;
        });
      }
    }

    private void on_file_data(int friendnumber,uint8 filenumber,uint8[] data) {
      FileTransfer ft = session.get_contact_list()[friendnumber].get_filetransfers()[filenumber];
      if(ft == null) {
        session.reject_file(friendnumber,filenumber);
        return;
      }

      if(ft.isfile) {
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
          Logger.log(LogLevel.ERROR, "Error while trying to write data to file");
          ft.status = FileTransferStatus.RECEIVING_FAILED;
        }
      } else {
        ByteArray buffer = new ByteArray.take(ft.data);
        buffer.append(data);
        ft.data = buffer.data;
        ft.bytes_processed += data.length;
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
        w.start_audio_call.connect(on_start_audio_call);
        w.stop_audio_call.connect(on_stop_audio_call);
        w.start_video_call.connect(on_start_video_call);
        w.stop_video_call.connect(on_stop_video_call);
        w.typing_status.connect( (is_typing) => {
          if(Settings.instance.send_typing_status) {
            session.set_user_is_typing(c.friend_id, is_typing);
          }
        });
        w.filetransfer_accepted.connect ( (ft) => {
          session.accept_file(ft.friend.friend_id,ft.filenumber);
        });
        w.filetransfer_rejected.connect ( (ft) => {
          session.reject_file(ft.friend.friend_id,ft.filenumber);
        });
        w.contact_changed.connect((contact) => {contact_changed(contact);});
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
        w.groupchat_changed.connect((groupchat) => {groupchat_changed(groupchat);});
        group_conversation_widgets[g.group_id] = w;
        notebook_conversations.append_page(w, null);
      }
      w.show_all();
      return w;
    }

    // Contact doubleclicked in treeview
    private void on_entry_activated(IContact ic) {
      Gtk.Widget conversation_widget = null;
      if(ic is Contact) {
        Contact c = ic as Contact;
        conversation_widget = open_conversation_with(c);

        if(c.unread_messages != 0) {
          c.unread_messages = 0;
          contact_list_tree_view.update_entry(c);
        }
      } else if(ic is GroupChat) {
        GroupChat g = ic as GroupChat;
        conversation_widget = open_group_conversation_with(g);

        if(g.unread_messages != 0) {
          g.unread_messages = 0;
          contact_list_tree_view.update_entry(g);
        }
      } else {
        GLib.assert_not_reached();
      }
      int current_page = notebook_conversations.page_num(conversation_widget);
      notebook_conversations.set_current_page(current_page);
      if(notebook_conversations.visible == false) {
        notebook_conversations.visible = true;
        resize(Settings.instance.window_width, Settings.instance.window_height);
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
                                  _("Are you sure you want to remove '%s' from your contact list?"), name);
      message_dialog.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Delete"), Gtk.ResponseType.OK, null);
      int response = message_dialog.run();
      message_dialog.destroy();
      if(response != Gtk.ResponseType.OK)
        return;

      if(!session.del_friend(c)) {
        Logger.log(LogLevel.ERROR, "Could not remove " + name);
        return;
      }
      contact_removed(c);
    }

    public void invite_to_groupchat(Contact c, int groupchat_number = -1) {
      GroupChat g = null;
      if(groupchat_number < 0) {
        g = session.add_groupchat();
        if(g == null) {
          Logger.log(LogLevel.ERROR, "Could not create a new groupchat.");
          return;
        }
        groupchat_added(g);
      } else {
        g = get_groupchats().get(groupchat_number);
      }
      session.invite_friend(c, g);
    }

    public void remove_groupchat(GroupChat g) {
      if(g == null)
        return;
      string name = "groupchat #%i".printf(g.group_id);
      Gtk.MessageDialog message_dialog = new Gtk.MessageDialog (this,
                                  Gtk.DialogFlags.MODAL,
                                  Gtk.MessageType.WARNING,
                                  Gtk.ButtonsType.NONE,
                                  _("Are you sure you want to remove '%s' from your contact list?"), name);
      message_dialog.add_buttons(_("_Cancel"), Gtk.ResponseType.CANCEL, _("_Delete"), Gtk.ResponseType.OK, null);
      int response = message_dialog.run();
      message_dialog.destroy();
      if(response != Gtk.ResponseType.OK)
        return;

      if(!session.del_groupchat(g)) {
        Logger.log(LogLevel.ERROR, "Could not remove " + name);
        return;
      }
      groupchat_removed(g);
    }

    private bool add_contact_real(string contact_id_string, string contact_message = "", string contact_alias = "") {
      string stripped_id = Tools.remove_whitespace(contact_id_string);
      string alias = contact_alias;

      // Try to resolve the tox id from an address if the size does not match
      if(stripped_id.length != Tox.FRIEND_ADDRESS_SIZE * 2) {
        if (ToxDns.tox_uri_regex != null && ToxDns.tox_uri_regex.match(stripped_id)) {
          ToxDns dns_resolver = new ToxDns();
          dns_resolver.default_host = Settings.instance.default_host;
          string resolved_id = dns_resolver.resolve_id(stripped_id, open_get_pin_dialog);
          if(alias == "") {
            alias = dns_resolver.authority_user;
          }
          if(resolved_id != null) {
            stripped_id = resolved_id;
          } else {
            Logger.log(LogLevel.ERROR, "Could not resolve ID from DNS record");
            UITools.show_error_dialog(_("Resolving ID failed"), _("Could not resolve ID from DNS record\n"), this);
            return false;
          }
        }
      }

      uint8[] contact_id = Tools.hexstring_to_bin(stripped_id);
      // add friend
      if(contact_id == null || contact_id.length != Tox.FRIEND_ADDRESS_SIZE) {
        Logger.log(LogLevel.INFO, "Could not add friend: Invalid ID");
        UITools.show_error_dialog(_("Adding Friend failed"), _("Could not add friend: Invalid ID\n"), this);
        return false;
      }
      Contact c = new Contact(contact_id);
      Logger.log(LogLevel.INFO, "setting alias: " + alias);
      if(alias != "") {
        c.alias = alias;
      }
      Tox.FriendAddError ret = session.add_friend(c, contact_message);
      if(ret < 0) {
        Logger.log(LogLevel.ERROR, "Could not add friend: %s.".printf(Tools.friend_add_error_to_string(ret)));
        UITools.show_error_dialog(_("Adding Friend failed"), _("Could not add friend: %s.\n").printf(Tools.friend_add_error_to_string(ret)), this);
        return false;
      }

      session.save_extended_contact_data(c);
      Logger.log(LogLevel.INFO, "Friend request successfully sent. Friend added as %i.".printf((int)ret));
      contact_added(c);
      return true;
    }

    private string? open_get_pin_dialog(string? username) {
      string pin = "";
      PinDialog dialog = new PinDialog( username );
      dialog.transient_for = this;
      dialog.modal = true;
      dialog.show_all();

      int result = dialog.run();
      if(result == Gtk.ResponseType.OK) {
        pin = dialog.pin;
      }
      dialog.destroy();
      return pin;
    }

    public void add_contact(string? contact_id = null, string? contact_message = null) {
      AddContactDialog dialog = new AddContactDialog();
      if(contact_id != null) {
        dialog.id = contact_id;
      }
      if(contact_message != null) {
        dialog.message = contact_message;
      }
      dialog.set_transient_for(this);

      string contact_id_string = "";
      string contact_alias = "";
      string contact_message_string = "";
      int response = Gtk.ResponseType.CANCEL;
      do {
        response = dialog.run();
        contact_id_string = dialog.id;
        contact_alias = dialog.contact_alias;
        contact_message_string = dialog.message;
      } while(response == Gtk.ResponseType.OK && !add_contact_real(contact_id_string, contact_message_string, contact_alias));

      dialog.destroy();
    }

    public void button_group_chat_clicked(Gtk.Button source) {
      GroupChat g = session.add_groupchat();
      if(g == null) {
        Logger.log(LogLevel.ERROR, "Could not create a new groupchat.");
        return;
      }
      groupchat_added(g);
    }
  }
}
