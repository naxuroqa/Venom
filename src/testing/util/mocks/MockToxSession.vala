/*
 *    MockToxSession.vala
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

using Venom;

namespace Mock {
  public class MockToxSession : ToxSession, GLib.Object {
    private GLib.HashTable<uint32, IContact> contacts;
    public MockToxSession() {
      contacts = new GLib.HashTable<uint32, IContact>(null, null);
    }
    public void set_session_listener(ToxAdapterListener listener) {
      mock().actual_call(this, "set_session_listener");
    }
    public void set_file_transfer_listener(ToxAdapterFiletransferListener listener) {
      mock().actual_call(this, "set_file_transfer_listener");
    }
    public void set_friend_listener(ToxAdapterFriendListener listener) {
      mock().actual_call(this, "set_friend_listener");
    }
    public void set_conference_listener(ToxAdapterConferenceListener listener) {
      mock().actual_call(this, "set_conference_listener");
    }
    public void self_set_user_name(string name) {
      mock().actual_call(this, "self_set_user_name");
    }
    public void self_set_status_message(string status) {
      mock().actual_call(this, "self_set_status_message");
    }
    public void self_set_typing(uint32 friend_number, bool typing) throws ToxError {
      mock().actual_call(this, "self_set_typing").get_throws();
    }
    public string self_get_name() {
      return mock().actual_call(this, "self_get_name").get_string();
    }
    public string self_get_status_message() {
      return mock().actual_call(this, "self_get_status_message").get_string();
    }
    public uint8[] self_get_address() {
      mock().actual_call(this, "self_get_address");
      return new uint8[0];
    }
    public void self_get_friend_list_foreach(GetFriendListCallback callback) throws ToxError {
      mock().actual_call(this, "self_get_friend_list_foreach").get_throws();
    }
    public void friend_add(uint8[] address, string message) throws ToxError {
      mock().actual_call(this, "friend_add").get_throws();
    }
    public void friend_add_norequest(uint8[] address) throws ToxError {
      mock().actual_call(this, "friend_add_norequest").get_throws();
    }
    public void friend_delete(uint32 friend_number) throws ToxError {
      mock().actual_call(this, "friend_delete").get_throws();
    }
    public void friend_send_message(uint32 friend_number, string message) throws ToxError {
      mock().actual_call(this, "friend_send_message").get_throws();
    }
    public string friend_get_name(uint32 friend_number) throws ToxError {
      return mock().actual_call(this, "friend_get_name").get_string();
    }
    public string friend_get_status_message(uint32 friend_number) throws ToxError {
      return mock().actual_call(this, "friend_get_status_message").get_string();
    }
    public uint64 friend_get_last_online(uint32 friend_number) throws ToxError {
      return mock().actual_call(this, "friend_get_last_online").get_int();
    }
    public void conference_new(string title) throws ToxError {
      mock().actual_call(this, "conference_new").get_throws();
    }
    public void conference_delete(uint32 conference_number) throws ToxError {
      mock().actual_call(this, "conference_delete").get_throws();
    }
    public void conference_send_message(uint32 conference_number, string message) throws ToxError {
      mock().actual_call(this, "conference_send_message").get_throws();
    }
    public void conference_set_title(uint32 conference_number, string title) throws ToxError {
      mock().actual_call(this, "conference_set_title").get_throws();
    }
    public string conference_get_title(uint32 conference_number) throws ToxError {
      return mock().actual_call(this, "conference_get_title").get_string();
    }
    public void file_control(uint32 friend_number, uint32 file_number, ToxCore.FileControl control) throws ToxError {
      mock().actual_call(this, "file_control").get_throws();
    }
    public void file_send(uint32 friend_number, ToxCore.FileKind kind, GLib.File file) throws ToxError {
      mock().actual_call(this, "file_send").get_throws();
    }
    public void file_send_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data) throws ToxError {
      mock().actual_call(this, "file_send_chunk").get_throws();
    }
    public unowned GLib.HashTable<uint32, IContact> get_friends() {
      mock().actual_call(this, "get_friends");
      return contacts;
    }
  }
}
