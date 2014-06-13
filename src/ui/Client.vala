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
    private const GLib.ActionEntry app_entries[] =
    {
      { "preferences", on_preferences },
      { "help", on_help },
      { "about", on_about },
      { "quit", on_quit }
    };
    private ContactListWindow contact_list_window;
    private SettingsWindow settings_window;

    public Client() {
      // call gobject base constructor
      GLib.Object(
        application_id: "im.tox.venom",
        flags: GLib.ApplicationFlags.HANDLES_OPEN
      );
    }

    ~Client() {
      // FIXME Workaround for some DEs keeping
      // one instance of the contactlistwindow alive
      if(contact_list_window != null) {
        contact_list_window.cleanup();
      }
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
      }
      return contact_list_window;
    }

    protected override void startup() {
      add_action_entries(app_entries, this);
      try {
        AudioManager.init();
      } catch (AudioManagerError e) {
        stderr.printf("Error creating Audio Pipeline: %s\n", e.message);      
      }

      base.startup();
    }

    protected override void activate() {
      hold();
      get_contact_list_window().present();
      release();
    }

    protected override void open(GLib.File[] files, string hint) {
      hold();
      get_contact_list_window().present();
      //FIXME allow names without tox:// prefix on command line
      contact_list_window.add_contact(files[0].get_uri());
      release();
    }

    private void on_preferences(GLib.SimpleAction action, GLib.Variant? parameter) {
      if(settings_window == null) {
        settings_window = new SettingsWindow();
        settings_window.destroy.connect( () => {settings_window = null;});
        settings_window.transient_for = contact_list_window;
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
          "There is currently no help available"
      );
      dialog.transient_for = contact_list_window;
      dialog.run();
      dialog.destroy();
    }

    private AboutDialog about_dialog;
    private void on_about(GLib.SimpleAction action, GLib.Variant? parameter) {
      if(about_dialog == null)
        about_dialog = new AboutDialog();
      about_dialog.transient_for = contact_list_window;
      about_dialog.modal = true;
      about_dialog.run();
      about_dialog.hide();
    }

    private void on_quit(GLib.SimpleAction action, GLib.Variant? parameter) {
      contact_list_window.destroy();
    }
  }
}
