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
    private Gtk.StatusIcon tray_icon;

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

        //tray_icon = new Gtk.StatusIcon.from_pixbuf(get_contact_list_window().get_icon());
        tray_icon = new Gtk.StatusIcon.from_icon_name("venom");
        tray_icon.set_tooltip_text ("Venom");
        Settings.instance.bind_property(Settings.TRAY_KEY, tray_icon, "visible", BindingFlags.SYNC_CREATE);
        tray_icon.activate.connect(()=>{
          if(contact_list_window == null){
            this.activate();
          } else {
            get_contact_list_window().show();
          }
        });
      }
      return contact_list_window;
    }

    protected override void startup() {
      add_action_entries(app_entries, this);
      base.startup();
    }

    public void show_notification(string summary, string? body, Gdk.Pixbuf image) {
      if(get_contact_list_window().is_active) {
        return;
      }
      try {
        Notify.Notification notification = new Notify.Notification(summary, body, null);
        notification.set_image_from_pixbuf(image);
        notification.show();
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, _("Error showing notification: ") + e.message);
      }
    }

    protected override void activate() {
      hold(); 
      Notify.init ("Venom");
      var window = get_contact_list_window();
      window.incoming_message.connect((m)=>{
        show_notification(
          m.get_sender_plain() + _(" says:"),
          m.get_message_plain(),
          m.from.image ?? ResourceFactory.instance.default_contact
        );
      });

      window.incoming_group_message.connect((m)=>{
        show_notification(
          m.from_contact.get_name_string() + _(" in ") + m.from.get_name_string() + _(" says:"),
          m.get_message_plain(),
          m.from.image ?? ResourceFactory.instance.default_groupchat
        );
      });
      
      window.incoming_action.connect((m)=>{
        show_notification(
          m.from.get_name_string() + _(":"),
          m.get_message_plain(),
          m.from.image ?? ResourceFactory.instance.default_contact
        );
      });

      window.incoming_group_action.connect((m)=>{
        show_notification(
          m.from_contact.get_name_string() + _(" in ") + m.from.get_name_string() + _(":"),
          m.get_message_plain(),
          m.from.image ?? ResourceFactory.instance.default_groupchat
        );
      });

      window.present();
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
