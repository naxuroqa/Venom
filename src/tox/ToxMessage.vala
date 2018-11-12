/*
 *    ToxMessage.vala
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
  public class ToxMessage : Message, FormattedMessage, GLib.Object {
    public int id                  { get; set; }
    public int peers_index         { get; set; }
    public DateTime timestamp      { get; set; }
    public MessageSender sender    { get; set; }
    public string message          { get; set; }
    public bool is_action          { get; set; }
    public TransmissionState state { get; set; }

    public uint32 tox_id           { get; set; }
    public IContact contact;

    public ToxMessage(IContact contact, MessageSender sender, string message, GLib.DateTime timestamp) {
      this.sender = sender;
      this.contact = contact;
      this.message = message;
      this.timestamp = timestamp;
    }

    public ToxMessage.outgoing(IContact receiver, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(receiver, MessageSender.LOCAL, message, timestamp);
    }

    public ToxMessage.incoming(IContact sender, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(sender, MessageSender.REMOTE, message, timestamp);
    }

    public string get_sender_plain() {
      if (sender == MessageSender.LOCAL) {
        return _("me");
      } else {
        return contact.get_name_string();
      }
    }

    public string get_sender_full() {
      return get_sender_plain();
    }

    public string get_sender_id() {
      return contact.get_id();
    }

    public string get_conversation_id() {
      return get_sender_id();
    }

    public string get_message_plain() {
      return message;
    }

    public string get_time_plain() {
      return timestamp.format("%c");
    }

    public bool is_conference_message() {
      return false;
    }

    public Gdk.Pixbuf get_sender_image() {
      if (sender == MessageSender.LOCAL) {
        return pixbuf_from_resource(R.icons.default_contact);
      } else {
        return contact.get_image();
      }
    }

    public bool equals_sender(Message m) {
      return m is ToxMessage && contact == ((ToxMessage)m).contact;
    }
  }
}