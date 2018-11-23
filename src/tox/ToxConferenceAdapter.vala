/*
 *    ToxConferenceAdapter.vala
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
  public class DefaultToxConferenceAdapter : ToxConferenceAdapter, ConferenceInviteEntryListener, ConferenceWidgetListener, ConferenceInfoWidgetListener, CreateGroupchatWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private Logger logger;
    private ObservableList contacts;
    private ObservableList conference_invites;
    private NotificationListener notification_listener;
    private GLib.HashTable<IContact, ObservableList> conversations;

    private GLib.HashTable<uint32, IContact> conferences;
    private unowned GLib.HashTable<uint32, IContact> friends;

    public DefaultToxConferenceAdapter(Logger logger, ObservableList contacts, ObservableList conference_invites, GLib.HashTable<IContact, ObservableList> conversations, NotificationListener notification_listener) {
      logger.d("DefaultToxConferenceAdapter created.");
      this.logger = logger;
      this.contacts = contacts;
      this.conference_invites = conference_invites;
      this.conversations = conversations;
      this.notification_listener = notification_listener;

      conferences = new GLib.HashTable<uint32, IContact>(null, null);
    }

    ~DefaultToxConferenceAdapter() {
      logger.d("DefaultToxConferenceAdapter destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_conference_listener(this);
      friends = session.get_friends();
      var chatlist = session.conference_get_chatlist();
      foreach (var conference_number in chatlist) {
        on_conference_new(conference_number, "");
      }
    }

    public virtual void on_remove_conference(IContact c) throws Error {
      var contact = c as Conference;
      session.conference_delete(contact.conference_number);
    }

    public virtual void on_change_conference_title(IContact c, string title) throws Error {
      var contact = c as Conference;
      session.conference_set_title(contact.conference_number, title);
    }

    public virtual void on_send_conference_message(IContact c, string message) throws Error {
      var conference = c as Conference;
      session.conference_send_message(conference.conference_number, message);
    }

    public virtual void on_create_groupchat(string title, ConferenceType type) throws Error {
      session.conference_new(title);
    }

    public virtual void on_send_conference_invite(IContact c, string id) throws Error {
      logger.d("on_send_conference_invite");
      if (c is Contact) {
        var contact = c as Contact;
        if (id == "") {
          var conference_number = session.conference_new("");
          session.conference_invite(contact.tox_friend_number, conference_number);
        } else {
          var index = id.last_index_of(".");
          var conference_number = int.parse(id.substring(index + 1));
          session.conference_invite(contact.tox_friend_number, conference_number);
        }
      } else {
        assert_not_reached();
      }
    }

    public virtual void on_accept_conference_invite(ConferenceInvite invite) throws Error {
      var c = invite.sender as Contact;
      session.conference_join(c.tox_friend_number, invite.conference_type, invite.get_cookie());
      conference_invites.remove(invite);
    }

    public virtual void on_reject_conference_invite(ConferenceInvite invite) throws Error {
      conference_invites.remove(invite);
    }

    private bool invite_equals(ConferenceInvite invite, uint32 friend_number, ConferenceType type, uint8[] cookie) {
      var cmp_sender = invite.sender as Contact;
      var cmp_cookie = invite.get_cookie();
      return (cmp_sender.tox_friend_number == friend_number
              && invite.conference_type == type
              && cmp_cookie.length == cookie.length
              && Memory.cmp(cookie, cmp_cookie, cookie.length) == 0);
    }

    public virtual void on_conference_invite_received(uint32 friend_number, ConferenceType type, uint8[] cookie) {
      logger.d("on_conference_invite_received");

      if (friend_number == uint32.MAX) {
        session.conference_join(friend_number, type, cookie);
      } else {
        for (var i = 0; i < conference_invites.length(); i++) {
          var invite = conference_invites.nth_data(i) as ConferenceInvite;
          if (invite_equals(invite, friend_number, type, cookie)) {
            logger.d("duplicate invite received, discarding");
            return;
          }
        }

        var contact = friends.@get(friend_number) as Contact;
        if (contact.auto_conference) {
          session.conference_join(friend_number, type, cookie);
        } else {
          var invite = new ConferenceInvite(contact, type, cookie);
          conference_invites.append(invite);

          notification_listener.on_conference_invite(invite);
        }
      }
    }

    public virtual void on_conference_new(uint32 conference_number, string title) {
      logger.d("on_conference_new");
      var contact = new Conference(conference_number, title);
      contacts.append(contact);
      conferences.@set(conference_number, contact);
      var conversation = new ObservableList();
      conversation.set_list(new GLib.List<Message>());
      conversations.@set(contact, conversation);
    }

    public virtual void on_conference_deleted(uint32 conference_number) {
      logger.d("on_conference_deleted");
      var contact = conferences.@get(conference_number);
      contacts.remove(contact);
      conversations.remove(contact);
      conferences.remove(conference_number);
    }

    public virtual void on_conference_title_changed(uint32 conference_number, uint32 peer_number, string title) {
      var contact = conferences.@get(conference_number) as Conference;
      contact.title = title;
      contact.changed();
    }

    public virtual void on_conference_peer_list_changed(uint32 conference_number, ToxConferencePeer[] peers) {
      var contact = conferences.@get(conference_number) as Conference;
      var gcpeers = contact.get_peers();
      gcpeers.clear();
      for (var i = 0; i < peers.length; i++) {
        var peer_number = peers[i].peer_number;
        var peer_key = Tools.bin_to_hexstring(peers[i].peer_key);;
        var peer = new ConferencePeer(peer_number, peer_key, peers[i].peer_name, peers[i].is_known, peers[i].is_self);
        gcpeers.@set(peer_number, peer);
      }
      contact.changed();
    }

    public virtual void on_conference_peer_renamed(uint32 conference_number, ToxConferencePeer peer) {
      var contact = conferences.@get(conference_number) as Conference;
      var peers = contact.get_peers();
      var peer_number = peer.peer_number;
      var gcpeer = peers.@get(peer_number);
      gcpeer.peer_key = Tools.bin_to_hexstring(peer.peer_key);
      gcpeer.peer_name = peer.peer_name;
      gcpeer.is_known = peer.is_known;
      gcpeer.is_self = peer.is_self;
      contact.changed();
    }

    public virtual void on_conference_message(uint32 conference_number, uint32 peer_number, ToxCore.MessageType type, string message) {
      logger.d("on_conference_message");
      var contact = conferences.@get(conference_number) as Conference;
      var conversation = conversations.@get(contact);
      var peer = contact.get_peers().@get(peer_number);
      var msg = new ConferenceMessage.incoming(contact, peer.peer_key, peer.peer_name, message);
      notification_listener.on_unread_message(msg, contact);
      contact.unread_messages++;
      contact.changed();
      conversation.append(msg);
    }

    public virtual void on_conference_message_sent(uint32 conference_number, string message) {
      logger.d("on_conference_message_sent");
      var contact = conferences.@get(conference_number) as Conference;
      var conversation = conversations.@get(contact);
      var msg = new ConferenceMessage.outgoing(contact, message);
      msg.state = TransmissionState.RECEIVED;
      conversation.append(msg);
    }
  }
}
