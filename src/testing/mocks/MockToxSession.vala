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
    private Gee.Map<uint32, IContact> contacts;
    public MockToxSession() {
      contacts = new Gee.HashMap<uint32, IContact>();
    }
    public void set_session_listener(ToxSelfAdapter listener) {
      var args = Arguments.builder()
                     .object(listener)
                     .create();
      mock().actual_call(this, "set_session_listener", args);
    }
    public void set_filetransfer_listener(ToxFiletransferAdapter listener) {
      var args = Arguments.builder()
                     .object(listener)
                     .create();
      mock().actual_call(this, "set_filetransfer_listener", args);
    }
    public void set_friend_listener(ToxFriendAdapter listener) {
      var args = Arguments.builder()
                     .object(listener)
                     .create();
      mock().actual_call(this, "set_friend_listener", args);
    }
    public void set_conference_listener(ToxConferenceAdapter listener) {
      var args = Arguments.builder()
                     .object(listener)
                     .create();
      mock().actual_call(this, "set_conference_listener", args);
    }
    public void set_call_adapter(ToxCallAdapter adapter) {
      var args = Arguments.builder()
                     .object(adapter)
                     .create();
      mock().actual_call(this, "set_call_adapter", args);
    }
    public void self_set_user_name(string name) {
      var args = Arguments.builder()
                     .string(name)
                     .create();
      mock().actual_call(this, "self_set_user_name", args);
    }
    public void self_set_user_status(UserStatus status) {
      var args = Arguments.builder()
                     .int(status)
                     .create();
      mock().actual_call(this, "self_set_user_status", args);
    }
    public void self_set_nospam(uint32 nospam) {
      var args = Arguments.builder()
                     .uint(nospam)
                     .create();
      mock().actual_call(this, "self_set_nospam", args);
    }
    public UserStatus self_get_user_status() {
      return (UserStatus) mock().actual_call(this, "self_get_user_status").get_int();
    }
    public void self_set_status_message(string status) {
      var args = Arguments.builder()
                     .string(status)
                     .create();
      mock().actual_call(this, "self_set_status_message", args);
    }
    public void self_set_typing(uint32 friend_number, bool typing) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .bool(typing)
                     .create();
      mock().actual_call(this, "self_set_typing", args).get_throws();
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
    public uint8[] self_get_public_key() {
      mock().actual_call(this, "self_get_public_key");
      return new uint8[0];
    }
    public void self_get_friend_list_foreach(GetFriendListCallback callback) throws ToxError {
      mock().actual_call(this, "self_get_friend_list_foreach").get_throws();
    }
    public void friend_add(uint8[] address, string message) throws ToxError {
      var args = Arguments.builder()
                     .string(message)
                     .create();
      mock().actual_call(this, "friend_add", args).get_throws();
    }
    public void friend_add_norequest(uint8[] address) throws ToxError {
      mock().actual_call(this, "friend_add_norequest").get_throws();
    }
    public uint32 friend_add_norequest_direct(uint8[] address) throws ToxError {
      return mock().actual_call(this, "friend_add_norequest_direct").get_int();
    }
    public void friend_delete(uint32 friend_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      mock().actual_call(this, "friend_delete", args).get_throws();
    }
    public void friend_send_message(uint32 friend_number, string message) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .string(message)
                     .create();
      mock().actual_call(this, "friend_send_message", args).get_throws();
    }
    public uint32 friend_send_message_direct(uint32 friend_number, string message) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .string(message)
                     .create();
      return mock().actual_call(this, "friend_send_message_direct", args).get_int();
    }
    public string friend_get_name(uint32 friend_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      return mock().actual_call(this, "friend_get_name", args).get_string();
    }
    public string friend_get_status_message(uint32 friend_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      return mock().actual_call(this, "friend_get_status_message", args).get_string();
    }
    public uint64 friend_get_last_online(uint32 friend_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      return mock().actual_call(this, "friend_get_last_online", args).get_int();
    }
    public uint32 conference_new(string title) throws ToxError {
      var args = Arguments.builder()
                     .string(title)
                     .create();
      return mock().actual_call(this, "conference_new", args).get_int();
    }
    public void conference_delete(uint32 conference_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(conference_number)
                     .create();
      mock().actual_call(this, "conference_delete", args).get_throws();
    }
    public void conference_invite(uint32 friend_number, uint32 conference_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .uint(conference_number)
                     .create();
      mock().actual_call(this, "conference_invite", args).get_throws();
    }
    public void conference_join(uint32 friend_number, ConferenceType type, uint8[] cookie) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .int(type)
                     .create();
      mock().actual_call(this, "conference_join", args).get_throws();
    }
    public void conference_send_message(uint32 conference_number, string message) throws ToxError {
      var args = Arguments.builder()
                     .uint(conference_number)
                     .string(message)
                     .create();
      mock().actual_call(this, "conference_send_message", args).get_throws();
    }
    public void conference_set_title(uint32 conference_number, string title) throws ToxError {
      var args = Arguments.builder()
                     .uint(conference_number)
                     .string(title)
                     .create();
      mock().actual_call(this, "conference_set_title", args).get_throws();
    }
    public string conference_get_title(uint32 conference_number) throws ToxError {
      var args = Arguments.builder()
                     .uint(conference_number)
                     .create();
      return mock().actual_call(this, "conference_get_title", args).get_string();
    }
    public Gee.Iterable<uint32> conference_get_chatlist() {
      return (Gee.Iterable<uint32>) mock().actual_call(this, "conference_get_chatlist").get_object();
    }
    public void file_control(uint32 friend_number, uint32 file_number, ToxCore.FileControl control) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .uint(file_number)
                     .int(control)
                     .create();
      mock().actual_call(this, "file_control", args).get_throws();
    }
    public void file_send_data(uint32 friend_number, GLib.File file) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      mock().actual_call(this, "file_send_data", args).get_throws();
    }
    public void file_send_avatar(uint32 friend_number, uint8[] avatar_data, uint8[] avatar_hash) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      mock().actual_call(this, "file_send_avatar", args).get_throws();
    }
    public void file_send_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data) throws ToxError {
      mock().actual_call(this, "file_send_chunk").get_throws();
    }
    public void call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .uint(audio_bit_rate)
                     .uint(video_bit_rate)
                     .create();
      mock().actual_call(this, "call", args).get_throws();
    }
    public void accept_call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .uint(audio_bit_rate)
                     .uint(video_bit_rate)
                     .create();
      mock().actual_call(this, "accept_call", args).get_throws();
    }
    public void call_control(uint32 friend_number, ToxAV.CallControl control) throws ToxError {
      var args = Arguments.builder()
                     .uint(friend_number)
                     .uint(control)
                     .create();
      mock().actual_call(this, "call_control", args).get_throws();
    }
    public void audio_send_sample(uint32 friend_number, Gst.Base.Adapter adapter, Gst.Caps caps) throws ToxError {
      //FIXME?
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      mock().actual_call(this, "audio_send_sample", args).get_throws();
    }
    public void video_send_sample(uint32 friend_number, Gst.Sample sample) throws ToxError {
      //FIXME?
      var args = Arguments.builder()
                     .uint(friend_number)
                     .create();
      mock().actual_call(this, "video_send_sample", args).get_throws();
    }
    public unowned Gee.Map<uint32, IContact> get_friends() {
      mock().actual_call(this, "get_friends");
      return contacts;
    }
  }
}
