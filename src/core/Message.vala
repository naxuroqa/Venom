/*
 *    Message.vala
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

namespace Venom {
  public enum MessageDirection {
    INCOMING,
    OUTGOING
  }
  public interface IMessage : GLib.Object {
    public abstract DateTime timestamp {get; protected set;}
    public abstract MessageDirection message_direction {get; protected set;}
    public abstract bool important {get; set;}
    public abstract bool is_action {get; set;}

    /*
     *  Get plain sender string
     */
    public abstract string get_sender_plain();

    /*
     *  Get plain message string
     */
    public abstract string get_message_plain();

    /*
     *  Get plain time string
     */
    public virtual string get_time_plain() {
      return timestamp.format("%R:%S");
    }

    public abstract string get_notification_header();
    public abstract Gdk.Pixbuf get_sender_image();

    /*
     *  Compare this senders of two messages
     */
    public abstract bool compare_sender(IMessage to);
  }
  public class Message : IMessage, GLib.Object {
    public unowned Contact from {get; protected set;}
    public unowned Contact to {get; protected set;}
    public string message {get; protected set;}
    public DateTime timestamp {get; protected set;}
    public MessageDirection message_direction {get; protected set;}
    public bool important {get; set; default = false;}
    public bool is_action {get; set; default = false;}

    public Message.outgoing(Contact receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.OUTGOING;
      this.from = null;
      this.to = receiver;
      this.message = message;
      this.timestamp = timestamp;
    }
    public Message.incoming(Contact sender, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.INCOMING;
      this.from = sender;
      this.to = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public virtual string get_sender_plain() {
      if(from == null) {
        return User.instance.name;
      } else {
        return from.name;
      }
    }
    public virtual string get_message_plain() {
      return message;
    }
    public virtual string get_notification_header() {
      return _("%s says:").printf(get_sender_plain());
    }
    public Gdk.Pixbuf get_sender_image() {
      return from.image ?? ResourceFactory.instance.default_contact;
    }
    public bool compare_sender(IMessage to) {
      if(to is Message) {
        return (from == (to as Message).from);
      }
      return false;
    }
  }
  public class ActionMessage : Message {
    public ActionMessage.outgoing(Contact receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.OUTGOING;
      this.from = null;
      this.to = receiver;
      this.message = message;
      this.timestamp = timestamp;
      this.is_action = true;
    }
    public ActionMessage.incoming(Contact sender, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.INCOMING;
      this.from = sender;
      this.to = null;
      this.message = message;
      this.timestamp = timestamp;
      this.is_action = true;
    }
    public override string get_sender_plain() {
      return "*";
    }
    public override string get_message_plain() {
      return "%s %s".printf(message_direction == MessageDirection.INCOMING ? from.name : User.instance.name, message);
    }
    public override string get_notification_header() {
      return from.get_name_string() + ":";
    }
  }
  public class GroupMessage : IMessage, GLib.Object {
    public unowned GroupChat from {get; protected set;}
    public unowned GroupChat to {get; protected set;}
    public GroupChatContact from_contact {get; protected set;}
    public string message {get; protected set;}
    public DateTime timestamp {get; protected set;}
    public MessageDirection message_direction {get; protected set;}
    public bool important {get; set; default = false;}
    public bool is_action {get; set; default = false;}

    public GroupMessage.outgoing(GroupChat receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.OUTGOING;
      this.from = null;
      this.to = receiver;
      this.from_contact = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public GroupMessage.incoming(GroupChat sender, GroupChatContact from_contact, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.INCOMING;
      this.from = sender;
      this.to = null;
      this.from_contact = from_contact;
      this.message = message;
      this.timestamp = timestamp;
    }
    public virtual string get_sender_plain() {
      if(from == null) {
        return User.instance.name;
      } else {
        if(this.message_direction == MessageDirection.OUTGOING) {
          return User.instance.name;
        }
        return from_contact.name != null ? from_contact.name : _("<unknown>");
      }
    }
    public virtual string get_message_plain() {
      return message;
    }
    public virtual string get_notification_header() {
      return _("%s in %s says:").printf(from_contact.get_name_string(), from.get_name_string());
    }
    public Gdk.Pixbuf get_sender_image() {
      return from.image ?? ResourceFactory.instance.default_groupchat;
    }
    public bool compare_sender(IMessage to) {
      if(to is GroupMessage) {
        GroupMessage gm = to as GroupMessage;
        return ((from == gm.from) && (from_contact == gm.from_contact));
      }
      return false;
    }
  }
  public class GroupActionMessage : GroupMessage {
    public GroupActionMessage.outgoing(GroupChat receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.OUTGOING;
      this.from = null;
      this.to = receiver;
      this.from_contact = from_contact;
      this.message = message;
      this.timestamp = timestamp;
      this.is_action = true;
    }
    public GroupActionMessage.incoming(GroupChat sender, GroupChatContact from_contact, string message, DateTime timestamp = new DateTime.now_local()) {
      this.message_direction = MessageDirection.INCOMING;
      this.from = sender;
      this.to = null;
      this.from_contact = from_contact;
      this.message = message;
      this.timestamp = timestamp;
      this.is_action = true;
    }
    public override string get_sender_plain() {
      return "*";
    }
    public override string get_message_plain() {
      string name_string;
      if(message_direction == MessageDirection.INCOMING) {
        name_string = from_contact.name != null ? from_contact.name : _("<unknown>");
      } else {
        name_string = User.instance.name;
      }
      return "%s %s".printf(message_direction == MessageDirection.INCOMING ? from_contact.name : User.instance.name, message);
    }
    public override string get_notification_header() {
      return _("%s in %s:").printf(from_contact.get_name_string(), from.get_name_string());
    }
  }
}
