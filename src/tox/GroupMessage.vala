/*
 *    GroupMessage.vala
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
  public class GroupMessage : IMessage, Object {
    public unowned GroupchatContact contact   { get; protected set; }
    public uint32 peer_number                 { get; protected set; }
    public string message                     { get; protected set; }

    public string sender_name                 { get; set; }
    public GLib.DateTime timestamp            { get; protected set; }
    public MessageDirection message_direction { get; protected set; }
    public bool important                     { get; set; }
    public bool is_action                     { get; set; }
    public uint32 message_id                  { get; set; }
    public bool received                      { get; set; }

    private GroupMessage(IContact contact, MessageDirection direction, string message, GLib.DateTime timestamp) {
      this.contact = contact as GroupchatContact;
      this.message_direction = direction;
      this.message = message;
      this.timestamp = timestamp;
      this.important = false;
      this.is_action = false;
    }

    public GroupMessage.outgoing(IContact contact, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(contact, MessageDirection.OUTGOING, message, timestamp);
    }

    public GroupMessage.incoming(IContact contact, uint32 peer_number, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(contact, MessageDirection.INCOMING, message, timestamp);
      this.peer_number = peer_number;
      var c = contact as GroupchatContact;
      this.sender_name = c.get_peers().@get(peer_number).name;
    }

    public virtual string get_sender_plain() {
      if (message_direction == MessageDirection.OUTGOING) {
        return _("me");
      } else {
        return sender_name;
      }
    }

    public virtual string get_message_plain() {
      return message;
    }

    public virtual string get_time_plain() {
      var now = new DateTime.now_local();
      if (now.difference(timestamp) > GLib.TimeSpan.DAY) {
        return timestamp.format("%c");
      } else {
        return timestamp.format("%X");
      }
    }

    public Gdk.Pixbuf get_sender_image() {
      return pixbuf_from_resource(R.icons.default_contact);
    }

    public bool equals_sender(IMessage m) {
      return false;
    }
  }
}
