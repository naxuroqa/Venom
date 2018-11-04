/*
 *    MockNotificationListener.vala
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

using Venom;

namespace Mock {
  public class MockNotificationListener : NotificationListener, GLib.Object {
    public bool show_notifications { get; set; }
    public bool play_sound_notifications { get; set; }
    public void on_unread_message(FormattedMessage message, IContact c) {
      var args = Arguments.builder()
                     .object(message)
                     .object(c)
                     .create();
      mock().actual_call(this, "on_unread_message", args);
    }

    public void on_friend_request(FriendRequest friend_request) {
      var args = Arguments.builder()
                     .object(friend_request)
                     .create();
      mock().actual_call(this, "on_friend_request", args);
    }

    public void on_filetransfer(FileTransfer transfer, IContact contact) {
      var args = Arguments.builder()
                     .object(transfer)
                     .object(contact)
                     .create();
      mock().actual_call(this, "on_filetransfer", args);
    }

    public void on_conference_invite(ConferenceInvite invite) {
      var args = Arguments.builder()
                     .object(invite)
                     .create();
      mock().actual_call(this, "on_conference_invite", args);
    }

    public void clear_notifications() {
      mock().actual_call(this, "clear_notifications");
    }
  }
}
