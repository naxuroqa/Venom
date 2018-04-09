/*
 *    Message.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  public enum MessageDirection {
    INCOMING,
    OUTGOING
  }

  public interface IMessage : Object {
    public signal void message_changed();

    public abstract DateTime timestamp                 { get; protected set; }
    public abstract MessageDirection message_direction { get; protected set; }
    public abstract bool important                     { get; set; }
    public abstract bool is_action                     { get; set; }
    public abstract bool received                      { get; set; }

    public abstract string get_sender_plain();
    public abstract string get_message_plain();
    public abstract string get_time_plain();

    public abstract Gdk.Pixbuf get_sender_image();
    public abstract bool equals_sender(IMessage m);
  }

  public class Message : IMessage, ILoggedMessage, Object {
    public unowned IContact from              { get; protected set; }
    public unowned IContact to                { get; protected set; }
    public string message                     { get; protected set; }
    public GLib.DateTime timestamp            { get; protected set; }
    public MessageDirection message_direction { get; protected set; }
    public bool important                     { get; set; default = false; }
    public bool is_action                     { get; set; default = false; }
    public uint32 message_id                  { get; set; }
    public bool received                      { get; set; }

    public Message.outgoing(IContact receiver, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this.message_direction = MessageDirection.OUTGOING;
      this.from = null;
      this.to = receiver;
      this.message = message;
      this.timestamp = timestamp;
    }

    public Message.incoming(IContact sender, string message, GLib.DateTime timestamp = new GLib.DateTime.now_local()) {
      this.message_direction = MessageDirection.INCOMING;
      this.from = sender;
      this.to = null;
      this.message = message;
      this.timestamp = timestamp;
    }

    public virtual string get_sender_plain() {
      if (from == null) {
        return _("me");
      } else {
        return from.get_name_string();
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
      return from != null ? from.get_image() : pixbuf_from_resource(R.icons.default_contact);
    }

    public bool equals_sender(IMessage m) {
      if (m is Message) {
        return (from == (m as Message).from);
      }
      return false;
    }
  }
}
