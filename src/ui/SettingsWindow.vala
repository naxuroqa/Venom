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
  public class SettingsWindow : Gtk.Window {
    private Gtk.Box box;
    private Gtk.CheckButton enable_history_checkbox;
    private Gtk.Entry days_to_log_entry;
    private Gtk.CheckButton enable_urgency_notification_checkbox;
    private Gtk.CheckButton dec_binary_checkbox;
    private VenomSettings settings = VenomSettings.instance;

    public SettingsWindow() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/settings_window.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading conversation window failed!\n");
      }
      box = builder.get_object("box1") as Gtk.Box;
      this.add(box);

      Gtk.Button save_button = builder.get_object("save_button") as Gtk.Button;
      save_button.clicked.connect(save);
      Gtk.Button cancel_button = builder.get_object("cancel_button") as Gtk.Button;
      cancel_button.clicked.connect(cancel);

      enable_history_checkbox = builder.get_object("enable_history_checkbox") as Gtk.CheckButton;
      enable_history_checkbox.toggled.connect( () => {
          days_to_log_entry.sensitive = enable_history_checkbox.active;
        });
      days_to_log_entry = builder.get_object("days_to_log_entry") as Gtk.Entry;
      enable_urgency_notification_checkbox = builder.get_object("enable_urgency_notification_checkbox") as Gtk.CheckButton;
      dec_binary_checkbox = builder.get_object("dec_binary_checkbox") as Gtk.CheckButton;

      enable_history_checkbox.active = settings.enable_logging;
      enable_history_checkbox.toggled();
      days_to_log_entry.text = settings.days_to_log.to_string();
      enable_urgency_notification_checkbox.active = settings.enable_urgency_notification;
      dec_binary_checkbox.active = settings.dec_binary_prefix;

      this.title = "Settings";
    }

    private void save(){
      settings.enable_logging = enable_history_checkbox.active;
      settings.days_to_log = int.parse(days_to_log_entry.text);
      settings.enable_urgency_notification = enable_urgency_notification_checkbox.active;
      settings.dec_binary_prefix = dec_binary_checkbox.active;

      settings.save_setting(ResourceFactory.instance.config_filename);
      this.destroy();
    }

    private void cancel(){
      this.destroy();
    }
  }
}
