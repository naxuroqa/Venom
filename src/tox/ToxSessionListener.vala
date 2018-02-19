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
  public class ToxSessionListenerImpl : ToxSessionListener, AddContactWidgetListener, ConversationWidgetListener, ConferenceWidgetListener, FriendInfoWidgetListener, ConferenceInfoWidgetListener, CreateGroupchatWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private UserInfo user_info;
    private Contacts contacts;
    private GLib.HashTable<IContact, Conversation> conversations;
    private GLib.HashTable<uint32, Message> messages_waiting_for_rr;

    private GLib.HashTable<uint32, IContact> friends;
    private GLib.HashTable<uint32, IContact> conferences;

    public bool show_typing { get; set; }

    public ToxSessionListenerImpl(ILogger logger, UserInfo user_info, Contacts contacts, GLib.HashTable<IContact, Conversation> conversations) {
      logger.d("ToxSessionListenerImpl created.");
      this.logger = logger;
      this.user_info = user_info;
      this.contacts = contacts;
      this.conversations = conversations;

      messages_waiting_for_rr = new GLib.HashTable<uint32, Message>(null, null);

      friends = new GLib.HashTable<uint32, IContact>(null, null);
      conferences = new GLib.HashTable<uint32, IContact>(null, null);

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
        session.self_get_friend_list_foreach((friend_number, friend_key) => {
          on_friend_added(friend_number, friend_key);
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
      var contact = c as Contact;
      session.friend_delete(contact.tox_friend_number);
    }

    public virtual void on_remove_conference(IContact c) throws Error {
      var contact = c as GroupchatContact;
      session.conference_delete(contact.tox_conference_number);
    }

    public virtual void on_change_conference_title(IContact c, string title) throws Error {
      var contact = c as GroupchatContact;
      session.conference_set_title(contact.tox_conference_number, title);
    }

    public virtual void on_send_friend_request(string address, string message) throws Error {
      var bin_address = Tools.hexstring_to_bin(address);
      session.friend_add(bin_address, message);
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

    public virtual void on_send_conference_message(IContact c, string message) throws Error {
      var conference = c as GroupchatContact;
      session.conference_send_message(conference.tox_conference_number, message);
    }

    public virtual void on_create_groupchat(string title, GroupchatType type) throws Error {
      session.conference_new(title);
    }

    public virtual void on_self_status_changed(UserStatus status) {
      user_info.set_user_status(status);
      user_info.info_changed(this);
    }

    public virtual void on_friend_message(uint32 friend_number, string message) {
      logger.d("on_friend_message");
      var contact = friends.@get(friend_number);
      var conversation = conversations.@get(contact);
      conversation.add_message(this, new Message.incoming(contact, message));
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
    }

    public virtual void on_friend_status_changed(uint32 friend_number, UserStatus status) {
      logger.d("on_friend_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.user_status = status;
      contact.changed();
    }

    public virtual void on_friend_added(uint32 friend_number, uint8[] public_key) {
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

    public virtual void on_conference_new(uint32 conference_number, string title) {
      logger.d("on_conference_new");
      var contact = new GroupchatContact(conference_number, title);
      contacts.add_contact(this, contact);
      conferences.@set(conference_number, contact);
      conversations.@set(contact, new ConversationImpl(contact));
    }

    public virtual void on_conference_deleted(uint32 conference_number) {
      logger.d("on_conference_deleted");
      var contact = conferences.@get(conference_number);
      contacts.remove_contact(this, contact);
      conversations.remove(contact);
      conferences.remove(conference_number);
    }

    public virtual void on_conference_title_changed(uint32 conference_number, uint32 peer_number, string title) {
      var contact = conferences.@get(conference_number) as GroupchatContact;
      contact.title = title;
      contact.changed();
    }

    public virtual void on_conference_peer_joined(uint32 conference_number, uint32 peer_number) {
      var contact = conferences.@get(conference_number) as GroupchatContact;
      var peers = contact.get_peers();
      peers.@set(peer_number, new GroupchatPeerImpl(peer_number));
      contact.changed();
    }

    public virtual void on_conference_peer_exited(uint32 conference_number, uint32 peer_number) {
      var contact = conferences.@get(conference_number) as GroupchatContact;
      var peers = contact.get_peers();
      peers.remove(peer_number);
      contact.changed();
    }

    public virtual void on_conference_peer_renamed(uint32 conference_number, uint32 peer_number, bool is_self, uint8[] peer_public_key, string peer_name, bool peer_known) {
      var contact = conferences.@get(conference_number) as GroupchatContact;
      var peers = contact.get_peers();
      var peer = peers.@get(peer_number);
      peer.tox_public_key = Tools.bin_to_hexstring(peer_public_key);
      peer.name = peer_name;
      peer.known = peer_known;
      contact.changed();
    }

    public virtual void on_conference_message(uint32 conference_number, uint32 peer_number, ToxCore.MessageType type, string message) {
      logger.d("on_conference_message");
      var contact = conferences.@get(conference_number) as GroupchatContact;
      var conversation = conversations.@get(contact);
      var msg = new GroupMessage.incoming(contact, peer_number, message);
      conversation.add_message(this, msg);
    }

    public virtual void on_conference_message_sent(uint32 conference_number, string message) {
      logger.d("on_conference_message_sent");
      var contact = conferences.@get(conference_number) as GroupchatContact;
      var conversation = conversations.@get(contact);
      var msg = new GroupMessage.outgoing(contact, message);
      msg.received = true;
      conversation.add_message(this, msg);
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
