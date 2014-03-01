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
    private Gtk.Box box;
    private Gtk.CheckButton enable_history_checkbox;
    private Gtk.SpinButton days_to_log_spinbutton;
    private Gtk.CheckButton enable_urgency_notification_checkbox;
    private Gtk.CheckButton dec_binary_checkbox;
    private VenomSettings settings = VenomSettings.instance;

    public SettingsWindow() {
      title = "Settings";
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/settings_window.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading conversation window failed!\n");
      }
      box = builder.get_object("box1") as Gtk.Box;
      get_content_area().add(box);

      enable_history_checkbox = builder.get_object("enable_history_checkbox") as Gtk.CheckButton;
      enable_history_checkbox.toggled.connect( () => {
          days_to_log_spinbutton.sensitive = enable_history_checkbox.active;
        });
      days_to_log_spinbutton = builder.get_object("days_to_log_spinbutton") as Gtk.SpinButton;
      enable_urgency_notification_checkbox = builder.get_object("enable_urgency_notification_checkbox") as Gtk.CheckButton;
      dec_binary_checkbox = builder.get_object("dec_binary_checkbox") as Gtk.CheckButton;

      enable_history_checkbox.active = settings.enable_logging;
      enable_history_checkbox.toggled();
      days_to_log_spinbutton.value = settings.days_to_log;
      enable_urgency_notification_checkbox.active = settings.enable_urgency_notification;
      dec_binary_checkbox.active = settings.dec_binary_prefix;

      add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Save", Gtk.ResponseType.OK, null);
      set_default_response(Gtk.ResponseType.CANCEL);

      response.connect( (id) => {
        if(id == Gtk.ResponseType.OK) {
          settings.enable_logging = enable_history_checkbox.active;
          settings.days_to_log = (int) days_to_log_spinbutton.value;
          settings.enable_urgency_notification = enable_urgency_notification_checkbox.active;
          settings.dec_binary_prefix = dec_binary_checkbox.active;

          settings.save_setting(ResourceFactory.instance.config_filename);
        }
        destroy();
      });
    }

  }
}
