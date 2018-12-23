/*
 *    ToxFriendAdapter.vala
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
  public class FriendDeletedNotification : NotificationAction {
    private Contact contact;
    private DefaultToxFriendAdapter listener;
    public FriendDeletedNotification(Contact contact, DefaultToxFriendAdapter listener) {
      this.contact = contact;
      this.listener = listener;
      message = _("%s has been removed from your contact list.").printf(contact.get_name_string());
      action_message = _("Undo");
    }

    public override void do_action() {
      listener.on_friend_undelete(contact);
    }
  }

  public class DefaultToxFriendAdapter : ToxFriendAdapter, AddContactWidgetListener, ConversationWidgetListener, FriendInfoWidgetListener, FriendRequestWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private Logger logger;
    private ObservableList contacts;
    private NotificationListener notification_listener;
    private ContactRepository contact_repository;
    private MessageRepository message_repository;
    private FriendRequestRepository friend_request_repository;
    private GLib.HashTable<IContact, ObservableList> conversations;
    private GLib.HashTable<uint32, Message> messages_waiting_for_rr;
    private QueuedMessageStorage queued_messages;

    private unowned Gee.Map<uint32, IContact> friends;
    private Gee.Map<string, FriendRequest> tox_friend_requests;
    private ObservableList friend_requests;

    private Gee.HashMap<uint32, Bytes> friend_avatar_hashes;
    private InAppNotification in_app_notification;

    private UserInfo user_info;
    private GLib.Bytes avatar_hash;

    public bool show_typing { get; set; }
    public bool enable_logging { get; set; }

    private class QueuedMessageStorage : GLib.Object {
      private Gee.Map<uint32, Gee.Queue<Message> > messages = new Gee.HashMap<uint32,Gee.Queue<Message> >();
      public void offer(uint32 id, Message message) {
        Gee.Queue<Message> queue;
        if (!messages.has_key(id)) {
          queue = new Gee.LinkedList<Message>();
          messages.@set(id, queue);
        } else {
          queue = messages.@get(id);
        }
        queue.offer(message);
      }
      public void unset(uint32 id) {
        messages.unset(id);
      }
      public Message ? peek(uint32 id) {
        if (!messages.has_key(id)) {
          return null;
        }
        return messages.@get(id).peek();
      }
      public Message ? poll(uint32 id) {
        if (!messages.has_key(id)) {
          return null;
        }
        return messages.@get(id).poll();
      }
    }

    public DefaultToxFriendAdapter(Logger logger, UserInfo user_info, MessageRepository message_repository,
                                        FriendRequestRepository friend_request_repository, ContactRepository contact_repository,
                                        ObservableList contacts, ObservableList friend_requests, GLib.HashTable<IContact, ObservableList> conversations,
                                        NotificationListener notification_listener, InAppNotification in_app_notification) {
      logger.d("DefaultToxFriendAdapter created.");
      this.logger = logger;
      this.user_info = user_info;
      this.message_repository = message_repository;
      this.contact_repository = contact_repository;
      this.friend_request_repository = friend_request_repository;
      this.contacts = contacts;
      this.friend_requests = friend_requests;
      this.conversations = conversations;
      this.notification_listener = notification_listener;
      this.in_app_notification = in_app_notification;

      messages_waiting_for_rr = new GLib.HashTable<uint32, Message>(null, null);
      queued_messages = new QueuedMessageStorage();
      tox_friend_requests = new Gee.HashMap<string, FriendRequest>();
      foreach (var request in friend_requests.get_all()) {
        var r = (FriendRequest) request;
        tox_friend_requests.@set(r.id, r);
      }

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
      logger.d("start_avatar_distribution");
      uint8[] avatar_data;
      user_info.avatar.pixbuf.save_to_buffer(out avatar_data, "png");
      var hash = ToxCore.Tox.hash(avatar_data);
      foreach (var contact in friends) {
        var c = contact as Contact;
        if (c.is_connected()) {
          session.file_send_avatar((c as Contact).tox_friend_number, avatar_data, hash);
        }
      }
    }

    ~DefaultToxFriendAdapter() {
      logger.d("DefaultToxFriendAdapter destroyed.");
    }

    public void attach_to_session(ToxSession session) {
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

    public void on_remove_friend(IContact c) throws Error {
      var contact = c as Contact;
      session.friend_delete(contact.tox_friend_number);
    }

    public void on_apply_friend_settings(IContact contact) {
      contact_repository.update(contact);
    }

    public void on_send_friend_request(string address, string message) throws Error {
      var bin_address = Tools.hexstring_to_bin(address);
      session.friend_add(bin_address, message);
    }

    public void on_accept_friend_request(string id) throws Error {
      var friend_request = tox_friend_requests.@get(id);
      var public_key = Tools.hexstring_to_bin(id);
      session.friend_add_norequest(public_key);

      friend_requests.remove(friend_request);
      friend_request_repository.delete (friend_request);
      tox_friend_requests.unset(id);
    }

    public void on_reject_friend_request(string id) throws Error {
      var friend_request = tox_friend_requests.@get(id);

      friend_requests.remove(friend_request);
      friend_request_repository.delete (friend_request);
      tox_friend_requests.unset(id);
    }

    public void on_send_message(IContact c, string message) throws Error {
      var contact = c as Contact;
      if (contact.connected) {
        logger.d("on_send_message message sent ");
        session.friend_send_message(contact.tox_friend_number, message);
      } else {
        logger.d("on_send_message message queued ");
        var msg = new ToxMessage.outgoing(contact, message);
        queued_messages.offer(contact.tox_friend_number, msg);
        if (enable_logging) {
          message_repository.create(msg);
        }
        var conversation = conversations.@get(contact);
        conversation.append(msg);
      }
    }

    public void on_set_typing(IContact c, bool typing) throws Error {
      if (!show_typing) {
        return;
      }
      var contact = c as Contact;
      session.self_set_typing(contact.tox_friend_number, typing);
    }

    public void on_friend_message(uint32 friend_number, string message_str) {
      logger.d("on_friend_message");
      var contact = friends.@get(friend_number) as Contact;
      var conversation = conversations.@get(contact);
      var message = new ToxMessage.incoming(contact, message_str);
      if (enable_logging) {
        message_repository.create(message);
      }
      notification_listener.on_unread_message(message, contact);
      contact.unread_messages++;
      contact.changed();
      conversation.append(message);
    }

    public void on_friend_read_receipt(uint32 friend_number, uint32 message_id) {
      var message = messages_waiting_for_rr.@get(message_id);
      if (message != null) {
        message.state = TransmissionState.RECEIVED;
        messages_waiting_for_rr.remove(message_id);
        if (enable_logging) {
          message_repository.update(message);
        }
      } else {
        logger.f("Got read receipt for unknown message.");
      }
    }

    public void on_friend_name_changed(uint32 friend_number, string name) {
      var contact = friends.@get(friend_number) as Contact;
      contact.name = name;
      contact.changed();
    }

    public void on_friend_status_message_changed(uint32 friend_number, string message) {
      logger.d("on_friend_status_message_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.status_message = message;
      contact.changed();
    }

    public void on_friend_request(uint8[] public_key, string message) {
      logger.d("on_friend_request");
      var id = Tools.bin_to_hexstring(public_key);
      if (tox_friend_requests.has_key(id)) {
        logger.d("Friend request already in list, ignoring.");
        return;
      }
      var request = new FriendRequest(id, message);
      friend_requests.append(request);
      friend_request_repository.create(request);
      tox_friend_requests.@set(id, request);
      notification_listener.on_friend_request(request);
    }

    public void on_friend_status_changed(uint32 friend_number, UserStatus status) {
      logger.d("on_friend_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.user_status = status;
      contact.changed();
    }

    public void on_friend_connection_status_changed(uint32 friend_number, bool is_connected) {
      logger.d("on_friend_connection_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact.connected = is_connected;
      contact.last_seen = new DateTime.from_unix_local((int64) session.friend_get_last_online(friend_number));
      contact.changed();

      if (is_connected) {
        uint8[] avatar_data;
        user_info.avatar.pixbuf.save_to_buffer(out avatar_data, "png");
        var hash = ToxCore.Tox.hash(avatar_data);
        session.file_send_avatar(friend_number, avatar_data, hash);

        try {
          Message ? message = queued_messages.peek(friend_number);
          while (message != null) {
            var message_id = session.friend_send_message_direct(friend_number, message.message);
            message.state = TransmissionState.SENT;
            if (enable_logging) {
              message_repository.update(message);
            }

            messages_waiting_for_rr.@set(message_id, message);
            queued_messages.poll(friend_number);
            message = queued_messages.peek(friend_number);
          }
        } catch (Error e) {
          logger.e("on_friend_connection_status_changed error when sending queued messages");
        }
      }
    }

    public void on_friend_typing_status_changed(uint32 friend_number, bool is_typing) {
      logger.d("on_friend_typing_status_changed");
      var contact = friends.@get(friend_number) as Contact;
      contact._is_typing = is_typing;
      contact.changed();
    }

    private void init_friend_in_contacts(Contact contact) {
      contact_repository.create(contact);

      if (!conversations.contains(contact)) {
        var conversation = new ObservableList();
        conversation.set_list(new GLib.List<Message>());
        conversations.@set(contact, conversation);

        if (enable_logging) {
          // FIXME move this into SqlSpecification
          var messages = ((SqliteMessageRepository) message_repository).query_all_for_contact(contact);
          foreach (var msg in messages) {
            if (msg.sender == MessageSender.LOCAL && msg.state == TransmissionState.NONE) {
              logger.d("on_friend_added restoring queued message...");
              queued_messages.offer(contact.tox_friend_number, msg);
            }
            conversation.append(msg);
          }
        }
      }

      friends.@set(contact.tox_friend_number, contact);
      contacts.append(contact);
    }

    public void on_friend_added(uint32 friend_number, uint8[] public_key) {
      logger.d("on_friend_added");
      var str_id = Tools.bin_to_hexstring(public_key);
      var contact = new Contact(friend_number, str_id);
      try {
        contact.name = session.friend_get_name(friend_number);
        contact.status_message = session.friend_get_status_message(friend_number);
        contact.last_seen = new DateTime.from_unix_local((int64) session.friend_get_last_online(friend_number));
      } catch (ToxError e) {
        logger.e("on_friend_added getting contact information failed");
      }

      var filepath = GLib.Path.build_filename(R.constants.avatars_folder(), @"$str_id.png");
      var file = File.new_for_path(filepath);
      if (!file.query_exists()) {
        contact.tox_image = Identicon.generate_pixbuf(public_key);
        contact.tox_image_hash = null;
      } else {
        uint8[] buf;
        try {
          file.load_contents(null, out buf, null);
          var pixbuf_loader = new Gdk.PixbufLoader();
          pixbuf_loader.write(buf);
          pixbuf_loader.close();
          contact.tox_image = pixbuf_loader.get_pixbuf();
          contact.tox_image_hash = ToxCore.Tox.hash(buf);
        } catch (Error e) {
          logger.i("could not read avatar data: " + e.message);
        }
      }

      init_friend_in_contacts(contact);
    }

    public void on_friend_undelete(Contact contact) {
      var public_key = Tools.hexstring_to_bin(contact.tox_id);
      contact.tox_friend_number = session.friend_add_norequest_direct(public_key);
      init_friend_in_contacts(contact);
      contact_repository.update(contact);
    }

    public void on_friend_deleted(uint32 friend_number) {
      logger.d("on_friend_deleted");
      var contact = friends.@get(friend_number) as Contact;
      contact.connected = false;
      contact_repository.delete (contact);
      conversations.remove(contact);
      friends.remove(friend_number);
      contacts.remove(contact);
      queued_messages.unset(friend_number);
      in_app_notification.show_notification(new FriendDeletedNotification(contact, this));
    }

    public void on_friend_message_sent(uint32 friend_number, uint32 message_id, string message) {
      logger.d("on_friend_message_sent");
      var contact = friends.@get(friend_number);
      var conversation = conversations.@get(contact);
      var msg = new ToxMessage.outgoing(contact, message);
      msg.state = TransmissionState.SENT;
      msg.tox_id = message_id;
      if (enable_logging) {
        message_repository.create(msg);
      }
      conversation.append(msg);
      messages_waiting_for_rr.@set(message_id, msg);
    }
  }
}
