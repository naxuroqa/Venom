/*
 *    Client.vala
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
  class Client : Gtk.Application {
    private const string APPLICATION_NAME = "Venom";
    private const GLib.ActionEntry app_entries[] =
    {
      { "preferences", on_preferences },
      { "help", on_help },
      { "about", on_about },
      { "quit", on_quit }
    };
    private ContactListWindow contact_list_window;
    private SettingsWindow settings_window;
    private Gtk.StatusIcon tray_icon;

    public Client() {
      // call gobject base constructor
      GLib.Object(
        application_id: "im.tox.venom",
        flags: GLib.ApplicationFlags.HANDLES_OPEN
      );
    }

    private ContactListWindow get_contact_list_window() {
      if( get_windows () == null ) {
        contact_list_window = new ContactListWindow(this);

        // Create menu
        GLib.Menu menu_prefs = new GLib.Menu();
        GLib.MenuItem item = new GLib.MenuItem ("P_references", "app.preferences");
        menu_prefs.append_item(item);

        GLib.Menu menu_common = new GLib.Menu();
        item = new GLib.MenuItem ("_Help", "app.help");
        item.set_attribute("accel", "s", "F1");
        menu_common.append_item(item);

        item = new GLib.MenuItem ("_About", "app.about");
        menu_common.append_item(item);

        item = new GLib.MenuItem ("_Quit", "app.quit");
        item.set_attribute("accel", "s", "<Primary>q");
        menu_common.append_item(item);

        GLib.Menu menu = new GLib.Menu();
        menu.append_section(null, menu_prefs);
        menu.append_section(null, menu_common);

        set_app_menu(menu);

        create_tray_menu();
        tray_icon = new Gtk.StatusIcon.from_icon_name("venom");
        tray_icon.set_tooltip_text(APPLICATION_NAME);
        Settings.instance.bind_property(Settings.TRAY_KEY, tray_icon, "visible", BindingFlags.SYNC_CREATE);
        tray_icon.activate.connect(on_trayicon_activate);
        tray_icon.popup_menu.connect(on_trayicon_popup_menu);
      }
      return contact_list_window;
    }

    private Gtk.Menu tray_menu;
    private void create_tray_menu() {
      tray_menu = new Gtk.Menu();
      Gtk.MenuItem tray_menu_show = new Gtk.MenuItem.with_mnemonic(_("_Show/Hide Venom"));
      tray_menu_show.activate.connect(on_trayicon_activate);
      tray_menu.append(tray_menu_show);
      Gtk.MenuItem tray_menu_quit = new Gtk.MenuItem.with_mnemonic(_("_Quit"));
      tray_menu_quit.activate.connect(simple_on_quit);
      tray_menu.append(tray_menu_quit);
      tray_menu.show_all();
    }

    private void on_trayicon_activate() {
      var w = get_contact_list_window();
      if(w.visible) {
        w.hide();
      } else {
		w.deiconify();				//Avoid the window to stay hid when "minimized on tray"
        w.show();
      }
    }

    private void on_trayicon_popup_menu(uint button, uint time) {
      tray_menu.popup(null, null, null, button, time);
    }

    protected override void startup() {
      add_action_entries(app_entries, this);
      try {
        AVManager.init();
      } catch (AVManagerError e) {
        Logger.log(LogLevel.FATAL, "Error creating Audio Pipeline: " + e.message);
      }
      Notification.init(APPLICATION_NAME);
      Logger.init();

      base.startup();
    }

    protected override void shutdown() {
      Logger.log(LogLevel.DEBUG, "Application shutting down...");
      // FIXME Workaround for some DEs keeping
      // one instance of the contactlistwindow alive
      if(contact_list_window != null) {
        contact_list_window.cleanup();
      }
      AVManager.free();
      base.shutdown();
    }

    private void show_notification_for_message(IMessage m) {
      if(get_contact_list_window().is_active || !Settings.instance.enable_notify) {
        return;
      }
      Notification.show_notification_for_message(m);
    }

    protected override void activate() {
      hold();

      var window = get_contact_list_window();
      window.incoming_message.connect(show_notification_for_message);
      window.incoming_group_message.connect(show_notification_for_message);
      window.incoming_action.connect(show_notification_for_message);
      window.incoming_group_action.connect(show_notification_for_message);

      window.present();
      release();
    }

    protected override void open(GLib.File[] files, string hint) {
      hold();
      get_contact_list_window().present();
      //FIXME allow names without tox:// prefix on command line
      string id = files[0].get_uri();
      try {
      var regex = new GLib.Regex("^tox:/*");
        id = regex.replace(id, -1, 0, "");
      } catch (GLib.RegexError e) {
        GLib.assert_not_reached();
      }
      Logger.log(LogLevel.DEBUG, "Adding contact from commandline: " + id);
      contact_list_window.add_contact(id);
      release();
    }

    private void on_preferences(GLib.SimpleAction action, GLib.Variant? parameter) {
      if(settings_window == null) {
        settings_window = new SettingsWindow(contact_list_window);
        settings_window.destroy.connect( () => {settings_window = null;});
        settings_window.show_all();
      } else {
        settings_window.present();
      }
    }

    private void on_help(GLib.SimpleAction action, GLib.Variant? parameter) {
      Gtk.MessageDialog dialog = new Gtk.MessageDialog(
          contact_list_window,
          Gtk.DialogFlags.MODAL,
          Gtk.MessageType.INFO,
          Gtk.ButtonsType.OK,
          _("There is currently no help available")
      );
      dialog.transient_for = contact_list_window;
      dialog.run();
      dialog.destroy();
    }

    private void on_about(GLib.SimpleAction action, GLib.Variant? parameter) {
      AboutDialog about_dialog = new AboutDialog();
      about_dialog.transient_for = contact_list_window;
      about_dialog.modal = true;
      about_dialog.run();
      about_dialog.destroy();
    }

    private void on_quit(GLib.SimpleAction action, GLib.Variant? parameter) {
      simple_on_quit();
    }
    private void simple_on_quit() {
      if(contact_list_window != null) {
        contact_list_window.destroy();
      }
    }
  }
}
