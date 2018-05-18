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
    private ObservableList contacts;
    private NotificationListener notification_listener;
    private GLib.HashTable<IContact, ObservableList> conversations;
    private GLib.HashTable<uint32, Message> messages_waiting_for_rr;

    private unowned GLib.HashTable<uint32, IContact> friends;
    private Gee.Map<string, FriendRequest> tox_friend_requests;
    private ObservableList friend_requests;

    private Gee.HashMap<uint32, Bytes> friend_avatar_hashes;

    private UserInfo user_info;
    private GLib.Bytes avatar_hash;

    public bool show_typing { get; set; }

    public ToxAdapterFriendListenerImpl(ILogger logger, UserInfo user_info, ObservableList contacts, ObservableList friend_requests, GLib.HashTable<IContact, ObservableList> conversations, NotificationListener notification_listener) {
      logger.d("ToxAdapterFriendListenerImpl created.");
      this.logger = logger;
      this.user_info = user_info;
      this.contacts = contacts;
      this.friend_requests = friend_requests;
      this.conversations = conversations;
      this.notification_listener = notification_listener;

      messages_waiting_for_rr = new GLib.HashTable<uint32, Message>(null, null);
      tox_friend_requests = new Gee.HashMap<string, FriendRequest>();

      user_info.info_changed.connect(on_info_changed);
      avatar_hash = user_info.avatar.hash;
    }

    private void on_info_changed() {
      if (user_info.is_connected && avatar_hash.compare(user_info.avatar.hash) != 0) {
        avatar_hash = user_info.avatar.hash;
        start_avatar_distribution();
      }
    }

    private void start_avatar_distribution() {
      logger.i("start_avatar_distribution");
      uint8[] avatar_data;
      user_info.avatar.pixbuf.save_to_buffer(out avatar_data, "png");
      var contacts = friends.get_values();
      foreach (var contact in contacts) {
        var c = contact as Contact;
        if (c.is_connected()) {
          session.file_send_avatar((c as Contact).tox_friend_number, avatar_data);
        }
      }
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
      var friend_request = tox_friend_requests.@get(id);
      var public_key = Tools.hexstring_to_bin(id);
      session.friend_add_norequest(public_key);

      friend_requests.remove(friend_request);
      tox_friend_requests.unset(id);
    }

    public virtual void on_reject_friend_request(string id) throws Error {
      var friend_request = tox_friend_requests.@get(id);

      friend_requests.remove(friend_request);
      tox_friend_requests.unset(id);
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
      var contact = friends.@get(friend_number) as Contact;
      var conversation = conversations.@get(contact);
      var message = new Message.incoming(contact, message_str);
      notification_listener.on_unread_message(message, contact);
      contact.unread_messages++;
      contact.changed();
      conversation.append(message);
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
      var contact = friends.@get(friend_number) as Contact;
      contact.name = name;
      contact.changed();
    }

    public virtual void on_friend_status_message_changed(uint32 friend_number, string message) {
      logger.d("on_friend_status_message_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.status_message = message;
      contact.changed();
    }

    public virtual void on_friend_request(uint8[] public_key, string message) {
      logger.d("on_friend_request");
      var id = Tools.bin_to_hexstring(public_key);
      var request = new FriendRequest(id, message);
      friend_requests.append(request);
      tox_friend_requests.@set(id, request);
    }

    public virtual void on_friend_status_changed(uint32 friend_number, UserStatus status) {
      logger.d("on_friend_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.user_status = status;
      contact.changed();
    }

    public virtual void on_friend_connection_status_changed(uint32 friend_number, bool is_connected) {
      logger.d("on_friend_connection_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.connected = is_connected;
      contact.last_seen = new DateTime.from_unix_local((int64) session.friend_get_last_online(friend_number));
      contact.changed();

      if (is_connected) {
        uint8[] avatar_data;
        user_info.avatar.pixbuf.save_to_buffer(out avatar_data, "png");
        session.file_send_avatar(contact.tox_friend_number, avatar_data);
      }
    }

    public virtual void on_friend_typing_status_changed(uint32 friend_number, bool is_typing) {
      logger.d("on_friend_typing_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact._is_typing = is_typing;
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
        var conversation = new ObservableList();
        conversation.set_list(new GLib.List<IMessage>());
        conversations.@set(contact, conversation);
      }

      var filepath = GLib.Path.build_filename(R.constants.avatars_folder(), @"$str_id.png");
      var file = File.new_for_path(filepath);
      if (file.query_exists()) {
        uint8[] buf;
        try {
          file.load_contents(null, out buf, null);
          var pixbuf_loader = new Gdk.PixbufLoader();
          pixbuf_loader.write(buf);
          pixbuf_loader.close();
          contact.tox_image = pixbuf_loader.get_pixbuf();
        } catch (Error e) {
          logger.i("could not read avatar data: " + e.message);
        }
      }

      friends.@set(friend_number, contact);
      contacts.append(contact);
    }

    public virtual void on_friend_deleted(uint32 friend_number) {
      logger.d("on_friend_deleted");
      var contact = friends.@get(friend_number);
      conversations.remove(contact);
      friends.remove(friend_number);
      contacts.remove(contact);
    }

    public virtual void on_friend_message_sent(uint32 friend_number, uint32 message_id, string message) {
      logger.d("on_friend_message_sent");
      var contact = friends.@get(friend_number);
      var conversation = conversations.@get(contact);
      var msg = new Message.outgoing(contact, message);
      msg.message_id = message_id;
      conversation.append(msg);
      messages_waiting_for_rr.@set(message_id, msg);
    }
  }
}
