/*
 *    ApplicationWindow.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  [GtkTemplate(ui = "/im/tox/venom/ui/application_window.ui")]
  public class ApplicationWindow : Gtk.ApplicationWindow, ContactListWidgetCallback {

    private const GLib.ActionEntry win_entries[] =
    {
      { "add_contact",  on_add_contact, null, null, null },
      { "copy_id",      on_copy_id, null, null, null },
      { "filetransfer", on_filetransfer, null, null, null },
      { "groupchats",   on_create_groupchat, null, null, null },
      { "show_user",    on_show_user, null, null, null }
    };

    UserStatus user_status = UserStatus.OFFLINE;

    [GtkChild]
    private Gtk.Box contact_list_box;

    [GtkChild]
    private Gtk.Revealer content_revealer;

    [GtkChild]
    private Gtk.StatusIcon status_icon;

    private Gtk.Widget current_content_widget;
    private WidgetProvider next_content_widget;

    private Factory.IWidgetFactory widget_factory;
    private ILogger logger;
    private ISettingsDatabase settings_database;
    private IContactDatabase contact_database;
    private IDhtNodeDatabase node_database;
    private ToxSession session;
    private ToxSessionListenerImpl session_listener;
    private Contacts contacts;
    private NotificationListener notification_listener;

    private GLib.HashTable<IContact, Conversation> conversations;
    private UserInfo user_info;

    public ApplicationWindow(Gtk.Application application, Factory.IWidgetFactory widget_factory, IDhtNodeDatabase node_database,
                             ISettingsDatabase settings_database, IContactDatabase contact_database) {
      Object(application: application);

      conversations = new GLib.HashTable<IContact, Conversation>(null, null);
      user_info = new UserInfoImpl();

      this.widget_factory = widget_factory;
      this.logger = widget_factory.createLogger();
      logger.attach_to_glib();

      this.node_database = node_database;
      this.settings_database = settings_database;
      this.contact_database = contact_database;

      contacts = new ContactsImpl(logger);

      notification_listener = new NotificationListenerImpl(logger);

      var session_io = new ToxSessionIOImpl(logger);
      session = new ToxSessionImpl(session_io, node_database, logger);
      session_listener = new ToxSessionListenerImpl(logger, user_info, contacts, conversations, notification_listener);
      session_listener.attach_to_session(session);

      settings_database.bind_property("enable-send-typing", session_listener, "show-typing", BindingFlags.SYNC_CREATE);
      settings_database.bind_property("enable-urgency-notification", notification_listener, "show-notifications", BindingFlags.SYNC_CREATE);
      settings_database.bind_property("enable-tray", status_icon, "visible", BindingFlags.SYNC_CREATE);

      status_icon.activate.connect(present);
      delete_event.connect(on_delete_event);

      init_widgets();
      init_callbacks();

      show_welcome();

      logger.d("ApplicationWindow created.");
    }

    ~ApplicationWindow() {
      logger.d("ApplicationWindow destroyed.");
    }

    private bool on_delete_event() {
      if (!settings_database.enable_tray) {
        return false;
      }
      return hide_on_delete();
    }

    private void init_widgets() {
      default_height = 600;
      default_width = 600;

      var gtk_settings = Gtk.Settings.get_default();
      settings_database.bind_property("enable-dark-theme", gtk_settings, "gtk-application-prefer-dark-theme", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      //status_label.label = get_header_for_status(user_status);
      set_default_icon_name(R.icons.app);
      var icon_theme = Gtk.IconTheme.get_default();
      try {
        set_default_icon(icon_theme.load_icon(R.icons.app, 48, 0));
      } catch (Error e) {
        logger.f("Could not set icon from theme: " + e.message);
      }

      var contact_list = new ContactListWidget(logger, contacts, this, user_info);
      contact_list_box.pack_start(contact_list, true, true);
    }

    public virtual void on_contact_selected(IContact contact) {
      logger.d("ApplicationWindow on_contact_selected");
      if (contact is Contact) {
        var conv = conversations.@get(contact);
        switch_content_with(() => { return new ConversationWindow(this, logger, conv, session_listener); });
      } else if (contact is GroupchatContact) {
        var conv = conversations.@get(contact);
        switch_content_with(() => { return new ConferenceWindow(this, logger, conv, session_listener); });
      } else if (contact is FriendRequest) {
        switch_content_with(() => { return new FriendRequestWidget(this, logger, contact, session_listener); });
      }
    }

    private void init_callbacks() {
      content_revealer.notify["child-revealed"].connect(on_revealer_child_revealed);
      add_action_entries(win_entries, this);
    }

    private void on_revealer_child_revealed() {
      if (content_revealer.child_revealed || current_content_widget == null || next_content_widget == null) {
        return;
      }
      content_revealer.remove(content_revealer.get_child());
      current_content_widget = null;

      current_content_widget = next_content_widget();
      current_content_widget.show_all();
      content_revealer.add(current_content_widget);
      content_revealer.set_reveal_child(true);
      next_content_widget = null;
    }

    private string get_header_for_status(UserStatus status) {
      var title = "%s".printf(status.to_string());
      return get_urgency_hint() ? "* " + title : title;
    }

    public void show_settings() {
      switch_content_with(() => { return widget_factory.createSettingsWidget(settings_database, node_database); });
    }

    public void show_welcome() {
      switch_content_with(() => { return new WelcomeWidget(logger); });
    }

    private void on_show_user() {
      switch_content_with(() => { return new UserInfoWidget(logger, user_info); });
    }

    private void on_create_groupchat() {
      switch_content_with(() => { return new CreateGroupchatWidget(logger, session_listener); });
    }

    private void on_filetransfer() {
      switch_content_with(() => { return new DownloadsWidget(logger); });
    }

    public void on_show_friend(IContact contact) {
      switch_content_with(() => { return new FriendInfoWidget(logger, this, session_listener, contact); });
    }

    public void on_show_conference(IContact contact) {
      switch_content_with(() => { return new ConferenceInfoWidget(logger, this, session_listener, contact); });
    }

    private void on_add_contact() {
      logger.d("on_add_contact()");
      switch_content_with(() => {
        var widget = new AddContactWidget(logger, session_listener);
        return widget;
      });
    }

    private void on_copy_id() {
      logger.d("on_copy_id()");
      var clipboard = Gtk.Clipboard.@get(Gdk.SELECTION_CLIPBOARD);
      var id = user_info.get_tox_id();
      clipboard.set_text(id, id.length);
    }

    private void switch_content_with(owned WidgetProvider widget_provider) {
      bool is_first_widget = current_content_widget == null;

      if (!is_first_widget) {
        next_content_widget = (owned) widget_provider;
        content_revealer.set_reveal_child(false);
      } else {
        current_content_widget = widget_provider();
        current_content_widget.show_all();
        content_revealer.add(current_content_widget);
        content_revealer.set_reveal_child(true);
      }
    }

    public delegate Gtk.Widget WidgetProvider();
  }
}
