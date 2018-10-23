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
    public abstract bool play_sound_notifications { get; set; }
    public abstract void on_unread_message(IMessage message, IContact sender);
    public abstract void on_friend_request(FriendRequest friend_request);
    public abstract void on_filetransfer(FileTransfer transfer, IContact sender);
    public abstract void on_conference_invite(ConferenceInvite invite);
    public abstract void clear_notifications();
  }

  public class NotificationListenerImpl : NotificationListener, GLib.Object {
    public bool show_notifications { get; set; default = true; }
    public bool play_sound_notifications { get; set; default = true; }
    private const int PIXBUF_SIZE = 48;
    private ILogger logger;
    private Canberra.Context context;
    private static string message_id = "new-message";
    private static string friend_request_id = "new-friend-request";
    private static string transfer_id = "new-transfer";
    private static string invite_id = "new-invite";

    public NotificationListenerImpl(ILogger logger) {
      this.logger = logger;
      var result = Canberra.Context.create(out context);
      if (result != 0) {
        logger.e(@"Cannot create canberra context: $result");
      }
    }

    private bool is_sound_playing() {
      bool playing;
      context.playing(0, out playing);
      return playing;
    }

    private void play_sound(string event_id) {
      if (context != null && play_sound_notifications && !is_sound_playing()) {
        var result = context.play(0, Canberra.PROP_EVENT_ID, event_id);
        if (result != 0) {
          logger.e(@"Can not play sound $event_id: $result");
        }
      }
    }

    private Gdk.Pixbuf scale_icon(Gdk.Pixbuf pixbuf) {
      return pixbuf.scale_simple(PIXBUF_SIZE, PIXBUF_SIZE, Gdk.InterpType.BILINEAR);
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

      var title = _("New message from %s").printf(message.get_sender_full());
      var contact_id = new GLib.Variant.string(message.get_conversation_id());

      var notification = new Notification(title);
      notification.set_body(message.get_message_plain());
      notification.set_icon(scale_icon(message.get_sender_image()));
      notification.set_default_action_and_target_value("app.show-contact", contact_id);
      notification.add_button_with_target_value(_("Show details"), "app.show-contact-info", contact_id);
      notification.add_button_with_target_value(_("Mute conversation"), "app.mute-contact", contact_id);
      app.send_notification(message_id, notification);

      play_sound("message-new-instant");
    }

    public virtual void on_friend_request(FriendRequest friend_request) {
      logger.d("on_friend_request");
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

      var notification = new Notification(_("Friend request"));
      notification.set_body(friend_request.message);
      notification.set_icon(Identicon.generate_pixbuf(Tools.hexstring_to_bin(friend_request.id), PIXBUF_SIZE));
      notification.set_default_action("app.show-add-contact");
      app.send_notification(friend_request_id, notification);

      play_sound("message-new-instant-friend-request");
    }

    public virtual void on_filetransfer(FileTransfer transfer, IContact sender) {
      logger.d("on_filetransfer");
      if (!show_notifications || !sender.show_notifications()) {
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
      notification.set_icon(scale_icon(sender.get_image()));
      notification.set_default_action("app.show-filetransfers");
      app.send_notification(transfer_id, notification);

      play_sound("message-new-instant-filetransfer");
    }

    public virtual void on_conference_invite(ConferenceInvite invite) {
      logger.d("on_conference_invite");
      if (!show_notifications || !invite.sender.show_notifications()) {
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

      var notification = new Notification(_("Conference invite"));
      notification.set_body(_("%s invites you to a conference").printf(invite.sender.get_name_string()));
      notification.set_icon(scale_icon(invite.sender.get_image()));
      notification.set_default_action("app.show-conferences");
      app.send_notification(message_id, notification);

      play_sound("message-new-instant-invite");
    }

    public void clear_notifications() {
      var app = GLib.Application.get_default() as Gtk.Application;
      if (app == null) {
        return;
      }

      app.withdraw_notification(message_id);
      app.withdraw_notification(invite_id);
    }
  }
}
