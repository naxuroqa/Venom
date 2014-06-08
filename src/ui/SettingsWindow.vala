/*
 *    SettingsWindow.vala
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
  public class SettingsWindow : GLib.Object {
    private Gtk.Dialog dialog;
    public signal void destroy();

    public SettingsWindow( Gtk.Window parent ) {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/settings_window.ui");
      } catch (GLib.Error e) {
        stderr.printf(_("Loading conversation window failed!\n"));
      }
      dialog = builder.get_object("dialog") as Gtk.Dialog;
      dialog.set_transient_for(parent);

      Gtk.SpinButton history_delete_spinbutton = builder.get_object("history_delete_spinbutton") as Gtk.SpinButton;

      Settings settings = Settings.instance;

      settings.bind_property(Settings.MESSAGE_LOGGING_KEY, builder.get_object("keep_history_checkbutton"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settings.bind_property(Settings.MESSAGE_LOGGING_KEY, builder.get_object("history_box"), "sensitive", BindingFlags.SYNC_CREATE);
      settings.bind_property(Settings.DAYS_TO_LOG_KEY, builder.get_object("history_keep_radio"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL,
        (binding, srcval, ref targetval) => { if((int)srcval < 0) targetval.set_boolean(true); return true; },
        (binding, srcval, ref targetval) => { if((bool)srcval) targetval.set_int(-1); return true; }
      );
      settings.bind_property(Settings.DAYS_TO_LOG_KEY, builder.get_object("history_delete_radio"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL,
        (binding, srcval, ref targetval) => { if((int)srcval >= 0) targetval.set_boolean(true); return true; },
        (binding, srcval, ref targetval) => { if((bool)srcval) targetval.set_int((int)history_delete_spinbutton.value); return true; }
      );
      settings.bind_property(Settings.DAYS_TO_LOG_KEY, builder.get_object("history_delete_spinbutton"), "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settings.bind_property(Settings.SEND_TYPING_STATUS_KEY, builder.get_object("send_typing_checkbutton"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settings.bind_property(Settings.SHOW_TYPING_STATUS_KEY, builder.get_object("show_typing_checkbutton"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settings.bind_property(Settings.URGENCY_NOTIFICATION_KEY, builder.get_object("urgency_notification_checkbutton"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settings.bind_property(Settings.DEFAULT_HOST_KEY, builder.get_object("default_host_entry"), "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settings.bind_property(Settings.DEC_BINARY_PREFIX_KEY, builder.get_object("filesize_prefix_combobox"), "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL,
        (binding, srcval, ref targetval) => {targetval.set_int((bool)srcval ? 0 : 1); return true;},
        (binding, srcval, ref targetval) => {targetval.set_boolean((int)srcval == 0); return true;}
      );
    }

    public void show_all() {
      dialog.show_all();
      dialog.response.connect( () => {
        Settings.instance.save_settings(ResourceFactory.instance.config_filename);
        dialog.destroy();
        destroy();
      });
    }

    public void present() {
      dialog.present();
    }
  }
}
