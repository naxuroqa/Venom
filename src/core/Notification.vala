/*
 *    Notification.vala
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
 
 namespace Venom.Notification {
#if ENABLE_LIBNOTIFY
  public static void init(string app_name) {
    Notify.init(app_name);
  }
  public static void show_notification_for_message(IMessage m) {
    try {
      Notify.Notification notification = new Notify.Notification(
        m.get_notification_header(),
        m.get_message_plain(),
        null
      );
      notification.set_image_from_pixbuf(m.get_sender_image());
      notification.set_category("im.received");
      notification.set_hint("sound-name", new Variant.string("message-new-instant"));
      notification.show();
    } catch (Error e) {
      Logger.log(LogLevel.ERROR, "Error showing notification: " + e.message);
    }
  }
#else
  public static void init(string app_name) {}
  public static void show_notification_for_message(IMessage m) {}
#endif
 }
