/*
 *    Conversation.vala
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
  public interface Conversation : GLib.Object {
    public signal void message_changed(GLib.Object sender, uint position);
    public signal void message_added(GLib.Object sender, uint positon);
    public signal void message_removed(GLib.Object sender, uint position);

    public abstract void add_message(GLib.Object sender, IMessage m);
    public abstract void remove_message(GLib.Object sender, IMessage m);

    public abstract bool is_empty();
    public abstract uint length();
    public abstract IMessage get_item(uint position);
    public abstract uint index(IMessage contact);
    public abstract IContact get_contact();
  }

  public class ConversationImpl : Conversation, GLib.Object {
    private GLib.List<IMessage> messages;
    private unowned IContact contact;

    public ConversationImpl(IContact contact) {
      this.contact = contact;
      messages = new GLib.List<IMessage>();
    }

    public virtual void add_message(GLib.Object sender, IMessage m) {
      var idx = length();
      messages.append(m);
      message_added(sender, idx);
    }

    public virtual void remove_message(GLib.Object sender, IMessage m) {
      var idx = index(m);
      messages.remove(m);
      message_removed(sender, idx);
    }

    public virtual bool is_empty() {
      return length() <= 0;
    }

    public virtual uint length() {
      return messages == null ? 0 : messages.length();
    }

    public virtual IMessage get_item(uint position) {
      return messages.nth_data(position);
    }

    public virtual uint index(IMessage contact) {
      return messages.index(contact);
    }

    public virtual IContact get_contact() {
      return contact;
    }
  }
}
