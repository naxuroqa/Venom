/*
 *    ConferenceMessage.vala
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
  public class ConferenceMessage : Message, FormattedMessage, GLib.Object {
    public int id                      { get; set; }
    public int peers_index             { get; set; }
    public DateTime timestamp          { get; set; }
    public MessageSender sender        { get; set; }
    public string message              { get; set; }
    public bool is_action              { get; set; }
    public TransmissionState state     { get; set; }

    public string peer_name            { get; set; }
    public string peer_key             { get; set; }

    public unowned IContact conference { get; set; }

    public ConferenceMessage(IContact conference, MessageSender sender, string message, GLib.DateTime timestamp, bool is_action) {
      this.conference = conference;
      this.sender = sender;
      this.message = message;
      this.timestamp = timestamp;
      this.is_action = is_action;
    }

    public ConferenceMessage.outgoing(IContact conference, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(conference, MessageSender.LOCAL, message, timestamp, false);
    }

    public ConferenceMessage.incoming(IContact conference, string peer_key, string peer_name, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this(conference, MessageSender.REMOTE, message, timestamp, false);
      this.peer_key = peer_key;
      this.peer_name = peer_name;
    }

    public string get_sender_plain() {
      if (sender == MessageSender.LOCAL) {
        return _("me");
      } else {
        return peer_name;
      }
    }

    public string get_sender_full() {
      return _("%s in %s").printf(get_sender_plain(), conference.get_name_string());
    }

    public string get_conversation_id() {
      return conference.get_id();
    }

    public string get_sender_id() {
      return peer_key;
    }

    public string get_message_plain() {
      return message;
    }

    public string get_time_plain() {
      return timestamp.format("%c");
    }

    public bool is_conference_message() {
      return true;
    }

    public Gdk.Pixbuf get_sender_image() {
      if (sender == MessageSender.LOCAL) {
        return pixbuf_from_resource(R.icons.default_contact);
      }
      var pub_key = Tools.hexstring_to_bin(peer_key);
      return Identicon.generate_pixbuf(pub_key);
    }

    public bool equals_sender(Message m) {
      return m is ConferenceMessage && ((ConferenceMessage) m).peer_key == peer_key;
    }
  }
}
