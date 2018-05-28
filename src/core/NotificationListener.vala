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
    public abstract void on_unread_message(IMessage message, IContact sender);
    public abstract void on_filetransfer(FileTransfer transfer, IContact sender);
    public abstract void clear_notifications();
  }

  public class NotificationListenerImpl : NotificationListener, GLib.Object {
    public bool show_notifications { get; set; }
    private ILogger logger;
    private static string message_id = "new-message";
    private static string transfer_id = "new-transfer";

    public NotificationListenerImpl(ILogger logger) {
      this.logger = logger;
    }

    public virtual void on_unread_message(IMessage message, IContact sender) {
      logger.d("on_unread_message");
      if (!show_notifications || !sender.show_notifications()) {
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
      notification.set_icon(message.get_sender_image());
      notification.set_default_action_and_target_value("app.show-contact", new GLib.Variant.string(message.get_conversation_id()));
      app.send_notification(message_id, notification);
    }

    public virtual void on_filetransfer(FileTransfer transfer, IContact sender) {
      logger.d("on_filetransfer");
      if (!show_notifications) {
        return;
      }

      var app = GLib.Application.get_default() as Gtk.Application;
      if (app == null) {
        return;
      }

      var file_name = transfer.get_file_name();
      var file_size = GLib.format_size(transfer.get_file_size());

      var notification = new Notification(_("New file from %s").printf(sender.get_name_string()));
      notification.set_body("%s (%s)".printf(file_name, file_size));
      notification.set_icon(sender.get_image());
      notification.set_default_action("app.show-filetransfers");
      app.send_notification(transfer_id, notification);
    }

    public void clear_notifications() {
      var app = GLib.Application.get_default() as Gtk.Application;
      if (app == null) {
        return;
      }

      app.withdraw_notification(message_id);
    }
  }
}
