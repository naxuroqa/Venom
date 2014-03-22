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
  public class SettingsWindow : Gtk.Dialog {
    private Gtk.CheckButton keep_history_checkbutton;
    private Gtk.RadioButton history_keep_radio;
    private Gtk.RadioButton history_delete_radio;
    private Gtk.SpinButton  history_delete_spinbutton;
    private Gtk.CheckButton send_typing_checkbutton;
    private Gtk.CheckButton show_typing_checkbutton;
    private Gtk.CheckButton urgency_notification_checkbutton;
    private Gtk.ListStore filesize_prefix_liststore;
    private Gtk.ComboBox filesize_prefix_combobox;
    private Gtk.CheckButton enable_tray_checkbutton;

    public bool keep_history {
      get { return keep_history_checkbutton.active; }
      set { keep_history_checkbutton.active = value; }
    }
    public int delete_history_after {
      get { return history_keep_radio.active ? -1 : (int) history_delete_spinbutton.value; }
      set {
        if( value < 0 ) {
          history_keep_radio.active = true;
        } else {
          history_delete_radio.active = true;
          history_delete_spinbutton.value = value;
        }
      }
    }
    
    public bool enable_tray {
      get { return enable_tray_checkbutton.active; }
      set { enable_tray_checkbutton.active = value; }
    }
    
    public bool send_typing {
      get { return send_typing_checkbutton.active; }
      set { send_typing_checkbutton.active = value; }
    }
    public bool show_typing {
      get { return show_typing_checkbutton.active; }
      set { show_typing_checkbutton.active = value; }
    }
    public bool urgency_notification {
      get { return urgency_notification_checkbutton.active; }
      set { urgency_notification_checkbutton.active = value; }
    }

    public bool dec_binary_prefix {
      get { return filesize_prefix_combobox.active == 0; }
      set { filesize_prefix_combobox.active = value ? 0 : 1; }
    }

    public SettingsWindow() {
      this.title = "Settings";
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/settings_window.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading conversation window failed!\n");
      }
      Gtk.Box settings_box = builder.get_object("settings_box") as Gtk.Box;
      this.get_content_area().add(settings_box);

      keep_history_checkbutton = builder.get_object("keep_history_checkbutton") as Gtk.CheckButton;
      history_keep_radio = builder.get_object("history_keep_radio") as Gtk.RadioButton;
      history_delete_radio = builder.get_object("history_delete_radio") as Gtk.RadioButton;
      history_delete_spinbutton = builder.get_object("history_delete_spinbutton") as Gtk.SpinButton;
      send_typing_checkbutton = builder.get_object("send_typing_checkbutton") as Gtk.CheckButton;
      show_typing_checkbutton = builder.get_object("show_typing_checkbutton") as Gtk.CheckButton;
      enable_tray_checkbutton = builder.get_object("urgency_notification_checkbutton") as Gtk.CheckButton;
      urgency_notification_checkbutton = builder.get_object("enable_tray_checkbutton") as Gtk.CheckButton;
      filesize_prefix_combobox = builder.get_object("filesize_prefix_combobox") as Gtk.ComboBox;
      filesize_prefix_liststore = builder.get_object("filesize_prefix_liststore") as Gtk.ListStore;

      Gtk.Box history_box = builder.get_object("history_box") as Gtk.Box;
      keep_history_checkbutton.toggled.connect( () => {
        history_box.sensitive = keep_history_checkbutton.active;
      });
      keep_history_checkbutton.toggled();

      Gtk.CellRendererText renderer = new Gtk.CellRendererText();
      filesize_prefix_combobox.pack_start(renderer, true);
      filesize_prefix_combobox.add_attribute(renderer, "text", 0);

      Settings settings = Settings.instance;
      keep_history = settings.enable_logging;
      delete_history_after = settings.days_to_log;
      urgency_notification = settings.enable_urgency_notification;
      send_typing = settings.send_typing_status;
      show_typing = settings.show_typing_status;
      dec_binary_prefix = settings.dec_binary_prefix;
      enable_tray = settings.enable_tray;

      add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Save", Gtk.ResponseType.OK, null);
      set_default_response(Gtk.ResponseType.CANCEL);

      response.connect( (id) => {
        if(id == Gtk.ResponseType.OK) {
          settings.enable_logging = keep_history;
          settings.days_to_log = delete_history_after;
          settings.send_typing_status = send_typing;
          settings.show_typing_status = show_typing;
          settings.enable_urgency_notification = urgency_notification;
          settings.dec_binary_prefix = dec_binary_prefix;
          settings.enable_tray = enable_tray;

          settings.save_settings(ResourceFactory.instance.config_filename);
        }
        destroy();
      });
    }

  }
}
