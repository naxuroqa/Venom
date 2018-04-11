/*
 *    ConferenceMessage.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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
  public class ConferenceMessage : IMessage, Object {
    public GLib.DateTime timestamp            { get; protected set; }
    public MessageDirection message_direction { get; protected set; }
    public bool important                     { get; set; }
    public bool is_action                     { get; set; }
    public bool received                      { get; set; }

    public string message                     { get; protected set; }
    public string peer_name                   { get; protected set; }
    public string peer_key                    { get; protected set; }

    private ConferenceMessage(MessageDirection direction, string message, GLib.DateTime timestamp) {
      this.message_direction = direction;
      this.message = message;
      this.timestamp = timestamp;
      this.important = false;
      this.is_action = false;
    }

    public ConferenceMessage.outgoing(string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(MessageDirection.OUTGOING, message, timestamp);
    }

    public ConferenceMessage.incoming(string peer_key, string peer_name, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(MessageDirection.INCOMING, message, timestamp);
      this.peer_key = peer_key;
      this.peer_name = peer_name;
    }

    public string get_sender_plain() {
      if (message_direction == MessageDirection.OUTGOING) {
        return _("me");
      } else {
        return peer_name;
      }
    }

    public string get_message_plain() {
      return message;
    }

    public string get_time_plain() {
      return timestamp.format("%c");
    }

    public Gdk.Pixbuf get_sender_image() {
      return pixbuf_from_resource(R.icons.default_contact);
    }

    public bool equals_sender(IMessage m) {
      return m is ConferenceMessage && ((ConferenceMessage) m).peer_key == peer_key;
    }
  }
}
