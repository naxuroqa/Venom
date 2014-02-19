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
  public interface IMessage : GLib.Object {
    public abstract DateTime timestamp {get; protected set;}
    public abstract string get_sender_plain();
    public abstract string get_message_plain();
    public virtual string get_time_plain() {
      return timestamp.format("%R");
    }

    public abstract string get_sender_markup();
    public abstract string get_message_markup();
    public virtual string get_time_markup() {
      return "<span color='#939598'>%s</span>".printf(timestamp.format("%R"));
    }
  }
  public class Message : IMessage, GLib.Object {
    public unowned Contact from {get; protected set;}
    public unowned Contact to {get; protected set;}
    public string message {get; protected set;}
    public DateTime timestamp {get; protected set;}

    public Message.outgoing(Contact receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = null;
      this.to = receiver;
      this.message = message;
      this.timestamp = timestamp;
    }
    public Message.incoming(Contact sender, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = sender;
      this.to = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public virtual string get_sender_plain() {
      if(from == null) {
        return "Me";
      } else {
        return from.name;
      }
    }
    public virtual string get_message_plain() {
      return message;
    }
    public virtual string get_sender_markup() {
      if(from == null) {
        return "<span color='#939598'font_weight='bold'>Me</span>";
      } else {
        return "<b>%s</b>".printf(Markup.escape_text(from.name));
      }
    }
    public virtual string get_message_markup() {
      return Markup.escape_text(message);
    }
  }
  public class ActionMessage : Message {
    public ActionMessage.outgoing(Contact receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = null;
      this.to = receiver;
      this.message = message;
      this.timestamp = timestamp;
    }
    public ActionMessage.incoming(Contact sender, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = sender;
      this.to = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public override string get_sender_plain() {
      return "*";
    }
    public override string get_message_plain() {
      return "%s %s".printf(from != null ? from.name : "me", message);
    }
    public override string get_sender_markup() {
      return "*";
    }
    public override string get_message_markup() {
      return "<b>%s</b> %s".printf(from != null ? Markup.escape_text(from.name) : "me", Markup.escape_text(message));
    }
  }
  public class NameChangeMessage : Message {
    public NameChangeMessage.outgoing(Contact receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = null;
      this.to = receiver;
      this.message = message;
      this.timestamp = timestamp;
    }
    public NameChangeMessage.incoming(Contact sender, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = sender;
      this.to = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public override string get_sender_plain() {
      return "*";
    }
    public override string get_message_plain() {
      return "%s is now known as %s".printf(message, from != null ? from.name : "me");
    }
    public override string get_sender_markup() {
      return "*";
    }
    public override string get_message_markup() {
      return "<b>%s</b> is now known as <b>%s</b>".printf(from != null ? Markup.escape_text(from.name) : "me", Markup.escape_text(message));
    }
  }
  public class GroupMessage : IMessage, GLib.Object {
    public unowned GroupChat from {get; protected set;}
    public unowned GroupChat to {get; protected set;}
    public string from_name {get; protected set;}
    public string message {get; protected set;}
    public DateTime timestamp {get; protected set;}

    public GroupMessage.outgoing(GroupChat receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = null;
      this.to = receiver;
      this.from_name = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public GroupMessage.incoming(GroupChat sender, string from_name, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = sender;
      this.to = null;
      this.from_name = from_name;
      this.message = message;
      this.timestamp = timestamp;
    }
    public virtual string get_sender_plain() {
      if(from == null) {
        return "Me";
      } else {
        return from_name;
      }
    }
    public virtual string get_message_plain() {
      return message;
    }
    public virtual string get_sender_markup() {
      if(from == null) {
        return "<span color='#939598'font_weight='bold'>Me</span>";
      } else {
        return "<b>%s</b>".printf(Markup.escape_text(from_name));
      }
    }
    public virtual string get_message_markup() {
      return Markup.escape_text(message);
    }
  }
  public class GroupActionMessage : GroupMessage {
    public GroupActionMessage.outgoing(GroupChat receiver, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = null;
      this.to = receiver;
      this.from_name = null;
      this.message = message;
      this.timestamp = timestamp;
    }
    public GroupActionMessage.incoming(GroupChat sender, string from_name, string message, DateTime timestamp = new DateTime.now_local()) {
      this.from = sender;
      this.to = null;
      this.from_name = from_name;
      this.message = message;
      this.timestamp = timestamp;
    }
    public override string get_sender_plain() {
      return "*";
    }
    public override string get_message_plain() {
      return "%s %s".printf(from != null ? from_name : "me", message);
    }
    public override string get_sender_markup() {
      return "*";
    }
    public override string get_message_markup() {
      return "<b>%s</b> %s".printf(from != null ? Markup.escape_text(from_name) : "me", Markup.escape_text(message));
    }
  }
  public class FileTransferMessage : IMessage, GLib.Object {
    public FileTransfer file_transfer {get; private set;}
    public DateTime timestamp {get; protected set;}

    public FileTransferMessage(FileTransfer file_transfer) {
      this.file_transfer = file_transfer;
      this.timestamp = file_transfer.time_sent;
    }
    public string get_sender_plain() {
       return "ft";
    }
    public string get_message_plain() {
      return file_transfer.name;
    }
    public string get_sender_markup() {
      return "ft";
    }
    public string get_message_markup() {
      return Markup.escape_text(file_transfer.name);
    }
  }
}
