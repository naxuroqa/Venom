/*
 *    NotificationListener.vala
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
  public interface NotificationListener : GLib.Object {
    public abstract bool show_notifications { get; set; }
    public abstract void on_unread_message(IMessage message);
  }

  public class NotificationListenerImpl : NotificationListener, GLib.Object {
    public bool show_notifications { get; set; }
    private ILogger logger;

    public NotificationListenerImpl(ILogger logger) {
      this.logger = logger;
    }

    public virtual void on_unread_message(IMessage message) {
      logger.d("on_unread_message");
      if (!show_notifications) {
        return;
      }

      var app = GLib.Application.get_default() as Gtk.Application;
      if (app == null) {
        return;
      }

      var window = app.get_active_window();
      if (window == null || window.is_active) {
        return;
      }

      var notification = new Notification(_("New message from %s").printf(message.get_sender_plain()));
      notification.set_body(message.get_message_plain());
      app.send_notification("new-message", notification);
    }
  }
}
