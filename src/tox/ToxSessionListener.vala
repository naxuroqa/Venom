/*
 *    ToxSessionListener.vala
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
  public class ToxSessionListenerImpl : ToxSessionListener, AddContactWidgetListener, ConversationWidgetListener, FriendInfoWidgetListener, CreateGroupchatWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private UserInfo user_info;
    private Contacts contacts;
    private GLib.HashTable<IContact, Conversation> conversations;
    private GLib.HashTable<uint32, Message> messages_waiting_for_rr;

    public ToxSessionListenerImpl(ILogger logger, UserInfo user_info, Contacts contacts, GLib.HashTable<IContact, Conversation> conversations) {
      logger.d("ToxSessionListenerImpl created.");
      this.logger = logger;
      this.user_info = user_info;
      this.contacts = contacts;
      this.conversations = conversations;

      this.messages_waiting_for_rr = new GLib.HashTable<uint32, Message>(null, null);

      user_info.info_changed.connect(on_user_info_changed);
    }

    ~ToxSessionListenerImpl() {
      logger.d("ToxSessionListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_session_listener(this);

      user_info.set_tox_id(Tools.bin_to_hexstring(session.self_get_address()));
      set_user_info();
      user_info.info_changed(this);

      try {
        session.self_get_friend_list_foreach((friend_key) => {
          on_friend_added(friend_key);
        });
      } catch (Error e) {
        logger.f("Could not retrieve friend list: " + e.message);
      }
    }

    private void set_user_info() {
      session.self_set_user_name(user_info.get_name());
      session.self_set_status_message(user_info.get_status_message());
    }

    private void on_user_info_changed(GLib.Object sender) {
      if (sender == this) {
        return;
      }

      logger.d("ToxSessionListenerImpl on_user_info_changed.");
      set_user_info();
    }

    public virtual void on_remove_friend(IContact c) throws Error {
      var bin_id = Tools.hexstring_to_bin(c.get_id());
      session.friend_delete(bin_id);
    }

    public virtual void on_send_friend_request(string id, string message) throws Error {
      var bin_id = Tools.hexstring_to_bin(id);
      session.friend_add(bin_id, message);
    }

    public virtual void on_send_message(IContact c, string message) throws Error {
      var bin_id = Tools.hexstring_to_bin(c.get_id());
      session.friend_send_message(bin_id, message);
    }

    public virtual void on_create_groupchat(string title, GroupchatType type) throws Error {
      session.conference_new(title);
    }

    public virtual void on_self_status_changed(UserStatus status) {
      user_info.set_user_status(status);
      user_info.info_changed(this);
    }

    public virtual void on_friend_message(uint8[] id, string message) {
      logger.d("on_friend_message");
      try {
        var pos = find_contact_position(id);
        var contact = contacts.get_item(pos);
        var conversation = conversations.@get(contact);
        conversation.add_message(this, new Message.incoming(contact, message));
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_friend_read_receipt(uint8[] id, uint32 message_id) {
      var message = messages_waiting_for_rr.@get(message_id);
      if (message != null) {
        message.received = true;
        messages_waiting_for_rr.remove(message_id);

        message.message_changed();
      } else {
        logger.f("Got read receipt for unknown message.");
      }
    }

    public virtual void on_friend_name_changed(uint8[] id, string name) {
      logger.d("on_friend_name_changed");
      try {
        var pos = find_contact_position(id);
        var contact = contacts.get_item(pos) as Contact;
        contact.name = name;
        contacts.contact_changed(this, pos);
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_friend_status_message_changed(uint8[] id, string message) {
      logger.d("on_friend_status_message_changed");
      try {
        var pos = find_contact_position(id);
        var contact = contacts.get_item(pos) as Contact;
        contact.status_message = message;
        contacts.contact_changed(this, pos);
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_friend_request(uint8[] id, string message) {

    }

    public virtual void on_friend_status_changed(uint8[] id, UserStatus status) {
      logger.d("on_friend_status_changed");
      try {
        var pos = find_contact_position(id);
        var contact = contacts.get_item(pos) as Contact;
        contact.user_status = status;
        contacts.contact_changed(this, pos);
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    private uint find_contact_position(uint8[] id) throws Error {
      var str_id = Tools.bin_to_hexstring(id);
      for (int i = 0; i < contacts.length(); i++) {
        var contact = contacts.get_item(i);
        if (contact.get_id() == str_id) {
          return i;
        }
      }
      throw new LookupError.GENERIC("Contact not found");
    }

    public virtual void on_friend_added(uint8[] id) {
      var str_id = Tools.bin_to_hexstring(id);
      var contact = new Contact(str_id);
      try {
        contact.name = session.friend_get_name(id);
        contact.status_message = session.friend_get_status_message(id);
        contact.last_seen = new DateTime.from_unix_local((int64) session.friend_get_last_online(id));
      } catch (ToxError e) {
        logger.i("Restoring contact information failed");
      }

      if (!conversations.contains(contact)) {
        conversations.@set(contact, new ConversationImpl(contact));
      }
      contacts.add_contact(this, contact);
    }

    public virtual void on_friend_deleted(uint8[] id) {
      logger.d("on_friend_deleted");
      try {
        var pos = find_contact_position(id);
        var contact = contacts.get_item(pos);
        conversations.remove(contact);
        contacts.remove_contact(this, contact);
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_friend_message_sent(uint8[] id, uint32 message_id, string message) {
      logger.d("on_friend_message_sent");
      try {
        var pos = find_contact_position(id);
        var contact = contacts.get_item(pos);
        var conversation = conversations.@get(contact);
        var msg = new Message.outgoing(contact, message);
        msg.message_id = message_id;
        conversation.add_message(this, msg);
        messages_waiting_for_rr.@set(message_id, msg);
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_conference_new(uint32 id, string title) {
      logger.d("on_conference_new");
      var groupchat_contact = new GroupchatContact(id, title);
      contacts.add_contact(this, groupchat_contact);
    }

    private void set_self_status(UserStatus status) {
      user_info.set_user_status(status);
      user_info.info_changed(this);
    }
  }
  private errordomain LookupError {
    GENERIC
  }
}
