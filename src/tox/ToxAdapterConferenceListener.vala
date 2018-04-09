/*
 *    ToxAdapterConferenceListener.vala
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
  public class ToxAdapterConferenceListenerImpl : ToxAdapterConferenceListener, ConferenceWidgetListener, ConferenceInfoWidgetListener, CreateGroupchatWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private ObservableList contacts;
    private NotificationListener notification_listener;
    private GLib.HashTable<IContact, ObservableList> conversations;

    private GLib.HashTable<uint32, IContact> conferences;

    public ToxAdapterConferenceListenerImpl(ILogger logger, ObservableList contacts, GLib.HashTable<IContact, ObservableList> conversations, NotificationListener notification_listener) {
      logger.d("ToxAdapterConferenceListenerImpl created.");
      this.logger = logger;
      this.contacts = contacts;
      this.conversations = conversations;
      this.notification_listener = notification_listener;

      conferences = new GLib.HashTable<uint32, IContact>(null, null);
    }

    ~ToxAdapterConferenceListenerImpl() {
      logger.d("ToxAdapterConferenceListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_conference_listener(this);
    }

    public virtual void on_remove_conference(IContact c) throws Error {
      var contact = c as GroupchatContact;
      session.conference_delete(contact.tox_conference_number);
    }

    public virtual void on_change_conference_title(IContact c, string title) throws Error {
      var contact = c as GroupchatContact;
      session.conference_set_title(contact.tox_conference_number, title);
    }

    public virtual void on_send_conference_message(IContact c, string message) throws Error {
      var conference = c as GroupchatContact;
      session.conference_send_message(conference.tox_conference_number, message);
    }

    public virtual void on_create_groupchat(string title, GroupchatType type) throws Error {
      session.conference_new(title);
    }

    public virtual void on_conference_new(uint32 conference_number, string title) {
      logger.d("on_conference_new");
      var contact = new GroupchatContact(conference_number, title);
      contacts.append(contact);
      conferences.@set(conference_number, contact);
      var conversation = new ObservableList();
      conversation.set_list(new GLib.List<IMessage>());
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
      notification_listener.on_unread_message(msg);
      contact.unread_messages++;
      contact.changed();
      conversation.append(msg);
    }

    public virtual void on_conference_message_sent(uint32 conference_number, string message) {
      logger.d("on_conference_message_sent");
      var contact = conferences.@get(conference_number) as GroupchatContact;
      var conversation = conversations.@get(contact);
      var msg = new GroupMessage.outgoing(contact, message);
      msg.received = true;
      conversation.append(msg);
    }
  }
}
