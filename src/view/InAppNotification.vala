/*
 *    InAppNotification.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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
  public class InAppNotification : GLib.Object {
    private const int TIMEOUT = 5;

    private NotificationAction? current_action;

    private Gtk.Revealer revealer;
    private Gtk.Button dismiss;
    private Gtk.Button action;
    private Gtk.Label action_message;
    private Gtk.Label message;

    uint timeout_source = 0;

    public InAppNotification(Gtk.Revealer revealer,
                             Gtk.Button dismiss,
                             Gtk.Button action,
                             Gtk.Label action_message,
                             Gtk.Label message) {
      this.revealer = revealer;
      this.dismiss = dismiss;
      this.action = action;
      this.action_message = action_message;
      this.message = message;

      dismiss.clicked.connect(dismiss_notification);
      action.clicked.connect(on_action_clicked);
    }

    ~InAppNotification() {
      remove_callback();
    }

    public void show_notification(NotificationAction action) {
      this.current_action = action;
      message.label = action.message;
      action_message.label = action.action_message;

      revealer.set_reveal_child(true);
      remove_callback();
      timeout_source = GLib.Timeout.add_seconds(TIMEOUT, timeout_callback);
    }

    private void remove_callback() {
      if (timeout_source > 0) {
        GLib.Source.remove(timeout_source);
        timeout_source = 0;
      }
    }

    private bool timeout_callback() {
      timeout_source = 0;
      dismiss_notification();
      return GLib.Source.REMOVE;
    }

    public void dismiss_notification() {
      current_action = null;
      revealer.set_reveal_child(false);
      remove_callback();
    }

    private void on_action_clicked() {
      if (current_action != null) {
        current_action.do_action();
      }
      dismiss_notification();
    }
  }

  public abstract class NotificationAction : GLib.Object {
    public string message { get; set; }
    public string action_message { get; set; }

    public virtual void do_action() {
    }
  }
}
