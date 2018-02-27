/*
 *    ToxAdapterFriendListener.vala
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
  public class ToxAdapterFriendListenerImpl : ToxAdapterFriendListener, AddContactWidgetListener, ConversationWidgetListener, FriendInfoWidgetListener, FriendRequestWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private Contacts contacts;
    private NotificationListener notification_listener;
    private GLib.HashTable<IContact, Conversation> conversations;
    private GLib.HashTable<uint32, Message> messages_waiting_for_rr;

    private unowned GLib.HashTable<uint32, IContact> friends;
    private GLib.HashTable<string, IContact> friend_requests;

    public bool show_typing { get; set; }

    public ToxAdapterFriendListenerImpl(ILogger logger, Contacts contacts, GLib.HashTable<IContact, Conversation> conversations, NotificationListener notification_listener) {
      logger.d("ToxAdapterFriendListenerImpl created.");
      this.logger = logger;
      this.contacts = contacts;
      this.conversations = conversations;
      this.notification_listener = notification_listener;

      messages_waiting_for_rr = new GLib.HashTable<uint32, Message>(null, null);

      friend_requests = new GLib.HashTable<string, IContact>(str_hash, str_equal);
    }

    ~ToxAdapterFriendListenerImpl() {
      logger.d("ToxAdapterFriendListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_friend_listener(this);

      friends = session.get_friends();

      try {
        session.self_get_friend_list_foreach((friend_number, friend_key) => {
          on_friend_added(friend_number, friend_key);
        });
      } catch (Error e) {
        logger.f("Could not retrieve friend list: " + e.message);
      }
    }

    public virtual void on_remove_friend(IContact c) throws Error {
      var contact = c as Contact;
      session.friend_delete(contact.tox_friend_number);
    }

    public virtual void on_send_friend_request(string address, string message) throws Error {
      var bin_address = Tools.hexstring_to_bin(address);
      session.friend_add(bin_address, message);
    }

    public virtual void on_accept_friend_request(string id) throws Error {
      var friend_request = friend_requests.@get(id);
      var public_key = Tools.hexstring_to_bin(id);
      session.friend_add_norequest(public_key);
      friend_requests.remove(id);
      contacts.remove_contact(this, friend_request);
    }

    public virtual void on_reject_friend_request(string id) throws Error {
      var friend_request = friend_requests.@get(id);
      friend_requests.remove(id);
      contacts.remove_contact(this, friend_request);
    }

    public virtual void on_send_message(IContact c, string message) throws Error {
      var contact = c as Contact;
      session.friend_send_message(contact.tox_friend_number, message);
    }

    public virtual void on_set_typing(IContact c, bool typing) throws Error {
      if (!show_typing) {
        return;
      }
      var contact = c as Contact;
      session.self_set_typing(contact.tox_friend_number, typing);
    }

    public virtual void on_friend_message(uint32 friend_number, string message_str) {
      logger.d("on_friend_message");
      var contact = friends.@get(friend_number);
      var conversation = conversations.@get(contact);
      var message = new Message.incoming(contact, message_str);
      notification_listener.on_unread_message(message);
      conversation.add_message(this, message);
    }

    public virtual void on_friend_read_receipt(uint32 friend_number, uint32 message_id) {
      var message = messages_waiting_for_rr.@get(message_id);
      if (message != null) {
        message.received = true;
        messages_waiting_for_rr.remove(message_id);

        message.message_changed();
      } else {
        logger.f("Got read receipt for unknown message.");
      }
    }

    public virtual void on_friend_name_changed(uint32 friend_number, string name) {
      logger.d("on_friend_name_changed");
      try {
        var contact = friends.@get(friend_number) as Contact;
        contact.name = name;
        contact.changed();
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_friend_status_message_changed(uint32 friend_number, string message) {
      logger.d("on_friend_status_message_changed");
      try {
        var contact = friends.@get(friend_number) as Contact;
        contact.status_message = message;
        contact.changed();
      } catch (Error e) {
        logger.e("Could not find contact.");
      }
    }

    public virtual void on_friend_request(uint8[] public_key, string message) {
      logger.d("on_friend_request");
      var str_id = Tools.bin_to_hexstring(public_key);
      var contact = new FriendRequest(str_id, message);
      contacts.add_contact(this, contact);
      friend_requests.@set(str_id, contact);
    }

    public virtual void on_friend_status_changed(uint32 friend_number, UserStatus status) {
      logger.d("on_friend_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.user_status = status;
      contact.changed();
    }

    public virtual void on_friend_added(uint32 friend_number, uint8[] public_key) {
      logger.d("on_friend_added");
      var str_id = Tools.bin_to_hexstring(public_key);
      var contact = new Contact(friend_number, str_id);
      try {
        contact.name = session.friend_get_name(friend_number);
        contact.status_message = session.friend_get_status_message(friend_number);
        contact.last_seen = new DateTime.from_unix_local((int64) session.friend_get_last_online(friend_number));
      } catch (ToxError e) {
        logger.i("Restoring contact information failed");
      }

      if (!conversations.contains(contact)) {
        conversations.@set(contact, new ConversationImpl(contact));
      }
      friends.@set(friend_number, contact);
      contacts.add_contact(this, contact);
    }

    public virtual void on_friend_deleted(uint32 friend_number) {
      logger.d("on_friend_deleted");
      var contact = friends.@get(friend_number);
      conversations.remove(contact);
      friends.remove(friend_number);
      contacts.remove_contact(this, contact);
    }

    public virtual void on_friend_message_sent(uint32 friend_number, uint32 message_id, string message) {
      logger.d("on_friend_message_sent");
      var contact = friends.@get(friend_number);
      var conversation = conversations.@get(contact);
      var msg = new Message.outgoing(contact, message);
      msg.message_id = message_id;
      conversation.add_message(this, msg);
      messages_waiting_for_rr.@set(message_id, msg);
    }
  }
}
