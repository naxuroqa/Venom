/*
 *    toxcore.vapi
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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

[CCode(cheader_filename = "tox/tox.h", cprefix = "Tox_", lower_case_cprefix = "tox_")]
namespace ToxCore {
  namespace Version {
    public const uint32 MAJOR;
    public const uint32 MINOR;
    public const uint32 PATCH;

    public static uint32 major();
    public static uint32 minor();
    public static uint32 patch();

    public static bool is_compatible(uint32 major, uint32 minor, uint32 patch);
  }

  public static uint32 public_key_size();
  public static uint32 secret_key_size();
  public static uint32 nospam_size();
  public static uint32 address_size();
  public static uint32 max_name_length();
  public static uint32 max_status_message_length();
  public static uint32 max_friend_request_length();
  public static uint32 max_message_length();
  public static uint32 max_custom_packet_size();
  public static uint32 hash_length();
  public static uint32 file_id_length();
  public static uint32 max_filename_length();

  [CCode(cname = "TOX_USER_STATUS", cprefix = "TOX_USER_STATUS_", has_type_id = false)]
  public enum UserStatus {
    NONE,
    AWAY,
    BUSY
  }

  [CCode(cname = "TOX_MESSAGE_TYPE", cprefix = "TOX_MESSAGE_TYPE_", has_type_id = false)]
  public enum MessageType {
    NORMAL,
    ACTION
  }

  [CCode(cname = "TOX_PROXY_TYPE", cprefix = "TOX_PROXY_TYPE_", has_type_id = false)]
  public enum ProxyType {
    NONE,
    HTTP,
    SOCKS5
  }

  [CCode(cname = "TOX_SAVEDATA_TYPE", cprefix = "TOX_SAVEDATA_TYPE_", has_type_id = false)]
  public enum SaveDataType {
    NONE,
    TOX_SAVE,
    SECRET_KEY
  }

  [CCode(cname = "TOX_LOG_LEVEL", cprefix = "TOX_LOG_LEVEL_", has_type_id = false)]
  public enum LogLevel {
    TRACE,
    DEBUG,
    INFO,
    WARNING,
    ERROR
  }

  [CCode(cname = "TOX_ERR_OPTIONS_NEW", cprefix = "TOX_ERR_OPTIONS_NEW_", has_type_id = false)]
  public enum ErrOptionsNew {
    OK,
    MALLOC
  }

  [CCode(cname = "TOX_ERR_NEW", cprefix = "TOX_ERR_NEW_", has_type_id = false)]
  public enum ErrNew {
    OK,
    NULL,
    MALLOC,
    PORT_ALLOC,
    PROXY_BAD_TYPE,
    PROXY_BAD_HOST,
    PROXY_BAD_PORT,
    PROXY_NOT_FOUND,
    LOAD_ENCRYPTED,
    LOAD_BAD_FORMAT
  }

  [CCode(cname = "TOX_ERR_BOOTSTRAP", cprefix = "TOX_ERR_BOOTSTRAP_", has_type_id = false)]
  public enum ErrBootstrap {
    OK,
    NULL,
    BAD_HOST,
    BAD_PORT
  }

  [CCode(cname = "TOX_ERR_SET_INFO", cprefix = "TOX_ERR_SET_INFO_", has_type_id = false)]
  public enum ErrSetInfo {
    OK,
    NULL,
    TOO_LONG
  }

  [CCode(cname = "TOX_CONNECTION", cprefix = "TOX_CONNECTION_", has_type_id = false)]
  public enum Connection {
    NONE,
    TCP,
    UDP
  }

  [CCode(cname = "TOX_ERR_FRIEND_ADD", cprefix = "TOX_ERR_FRIEND_ADD_", has_type_id = false)]
  public enum ErrFriendAdd {
    OK,
    NULL,
    TOO_LONG,
    NO_MESSAGE,
    OWN_KEY,
    ALREADY_SENT,
    BAD_CHECKSUM,
    SET_NEW_NOSPAM,
    MALLOC
  }

  [CCode(cname = "TOX_ERR_FRIEND_DELETE", cprefix = "TOX_ERR_FRIEND_DELETE_", has_type_id = false)]
  public enum ErrFriendDelete {
    OK,
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_BY_PUBLIC_KEY", cprefix = "TOX_ERR_FRIEND_BY_PUBLIC_KEY_", has_type_id = false)]
  public enum ErrFriendByPublicKey {
    OK,
    NULL,
    NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_GET_PUBLIC_KEY", cprefix = "TOX_ERR_FRIEND_GET_PUBLIC_KEY_", has_type_id = false)]
  public enum ErrFriendGetPublicKey {
    OK,
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_GET_LAST_ONLINE", cprefix = "TOX_ERR_FRIEND_GET_LAST_ONLINE_", has_type_id = false)]
  public enum ErrFriendGetLastOnline {
    OK,
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_QUERY", cprefix = "TOX_ERR_FRIEND_QUERY_", has_type_id = false)]
  public enum ErrFriendQuery {
    OK,
    NULL,
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_SET_TYPING", cprefix = "TOX_ERR_SET_TYPING_", has_type_id = false)]
  public enum ErrSetTyping {
    OK,
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_SEND_MESSAGE", cprefix = "TOX_ERR_FRIEND_SEND_MESSAGE_", has_type_id = false)]
  public enum ErrFriendSendMessage {
    OK,
    NULL,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    SENDQ,
    TOO_LONG,
    EMPTY
  }

  [CCode(cname = "TOX_FILE_KIND", cprefix = "TOX_FILE_KIND_", has_type_id = false)]
  public enum FileKind {
    DATA,
    AVATAR
  }

  [CCode(cname = "TOX_FILE_CONTROL", cprefix = "TOX_FILE_CONTROL_", has_type_id = false)]
  public enum FileControl {
    RESUME,
    PAUSE,
    CANCEL
  }

  [CCode(cname = "TOX_ERR_FILE_CONTROL", cprefix = "TOX_ERR_FILE_CONTROL_", has_type_id = false)]
  public enum ErrFileControl {
    OK,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    NOT_FOUND,
    NOT_PAUSED,
    DENIED,
    ALREADY_PAUSED,
    SENDQ
  }

  [CCode(cname = "TOX_ERR_FILE_SEEK", cprefix = "TOX_ERR_FILE_SEEK_", has_type_id = false)]
  public enum ErrFileSeek {
    OK,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    NOT_FOUND,
    DENIED,
    INVALID_POSITION,
    SENDQ
  }

  [CCode(cname = "TOX_ERR_FILE_GET", cprefix = "TOX_ERR_FILE_GET_", has_type_id = false)]
  public enum ErrFileGet {
    OK,
    NULL,
    FRIEND_NOT_FOUND,
    NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FILE_SEND", cprefix = "TOX_ERR_FILE_SEND_", has_type_id = false)]
  public enum ErrFileSend {
    OK,
    NULL,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    NAME_TOO_LONG,
    TOO_MANY
  }

  [CCode(cname = "TOX_ERR_FILE_SEND_CHUNK", cprefix = "TOX_ERR_FILE_SEND_CHUNK_", has_type_id = false)]
  public enum ErrFileSendChunk {
    OK,
    NULL,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    NOT_FOUND,
    NOT_TRANSFERRING,
    INVALID_LENGTH,
    SENDQ,
    WRONG_POSITION
  }

  [CCode(cname = "TOX_CONFERENCE_TYPE", cprefix = "TOX_CONFERENCE_TYPE_", has_type_id = false)]
  public enum ConferenceType {
    TEXT,
    AV
  }

  [CCode(cname = "TOX_CONFERENCE_STATE_CHANGE", cprefix = "TOX_CONFERENCE_STATE_CHANGE_", has_type_id = false)]
  public enum ConferenceStateChange {
    PEER_JOIN,
    PEER_EXIT,
    PEER_NAME_CHANGE
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_NEW", cprefix = "TOX_ERR_CONFERENCE_NEW_", has_type_id = false)]
  public enum ErrConferenceNew {
    OK,
    INIT
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_DELETE", cprefix = "TOX_ERR_CONFERENCE_DELETE_", has_type_id = false)]
  public enum ErrConferenceDelete {
    OK,
    CONFERENCE_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_PEER_QUERY", cprefix = "TOX_ERR_CONFERENCE_PEER_QUERY_", has_type_id = false)]
  public enum ErrConferencePeerQuery {
    OK,
    CONFERENCE_NOT_FOUND,
    PEER_NOT_FOUND,
    NO_CONNECTION
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_INVITE", cprefix = "TOX_ERR_CONFERENCE_INVITE_", has_type_id = false)]
  public enum ErrConferenceInvite {
    OK,
    CONFERENCE_NOT_FOUND,
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_JOIN", cprefix = "TOX_ERR_CONFERENCE_JOIN_", has_type_id = false)]
  public enum ErrConferenceJoin {
    OK,
    INVALID_LENGTH,
    WRONG_TYPE,
    FRIEND_NOT_FOUND,
    DUPLICATE,
    INIT_FAIL,
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_SEND_MESSAGE", cprefix = "TOX_ERR_CONFERENCE_SEND_MESSAGE_", has_type_id = false)]
  public enum ErrConferenceSendMessage {
    OK,
    CONFERENCE_NOT_FOUND,
    TOO_LONG,
    NO_CONNECTION,
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_TITLE", cprefix = "TOX_ERR_CONFERENCE_TITLE_", has_type_id = false)]
  public enum ErrConferenceTitle {
    OK,
    CONFERENCE_NOT_FOUND,
    INVALID_LENGTH,
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_GET_TYPE", cprefix = "TOX_ERR_CONFERENCE_GET_TYPE", has_type_id = false)]
  public enum ErrConferenceGetType {
    OK,
    CONFERENCE_NOT_FOUND
  }

  [CCode(cname = "tox_log_cb")]
  public delegate void LogCallback(Tox self, LogLevel level, string file, uint32 line, string func, string message);

  [CCode(cname = "struct Tox_Options", destroy_function = "tox_options_free", has_type_id = false)]
  [Compact]
  public class Options {
    public Options(ref ErrOptionsNew error);

    public bool ipv6_enabled;
    public bool udp_enabled;
    public bool local_discovery_enabled;
    public ProxyType proxy_type;
    public string? proxy_host;
    public uint16 proxy_port;
    public uint16 start_port;
    public uint16 end_port;
    public uint16 tcp_port;
    public bool hole_punching_enabled;
    public SaveDataType savedata_type;
    [CCode(array_length_cname = "savedata_length", array_length_type = "size_t")]
    public uint8[] savedata_data;
    [CCode(delegate_target_cname = "log_user_data")]
    public unowned LogCallback log_callback;

    public void default ();
  }

  [CCode(cname = "Tox", free_function = "tox_kill", cprefix = "tox_", has_type_id = false)]
  [Compact]
  public class Tox {
    public Tox(Options? options = null, ref ErrNew error);

    [CCode(cname = "tox_get_savedata_size")]
    private size_t _get_savedata_size();
    [CCode(cname = "tox_get_savedata")]
    private void _get_savedata([CCode(array_length = false)] uint8[] data);
    [CCode(cname = "vala_tox_get_savedata")]
    public uint8[] get_savedata() {
      var t = new uint8[_get_savedata_size()];
      _get_savedata(t);
      return t;
    }

    public bool bootstrap(string address, uint16 port, [CCode(array_length = false)] uint8[] public_key, ref ErrBootstrap error);

    public bool add_tcp_relay(string address, uint16 port, [CCode(array_length = false)] uint8[] public_key, ref ErrBootstrap error);

    public Connection self_get_connection_status();

    [CCode(cname = "tox_self_connection_status_cb", has_target = false, has_type_id = false)]
    public delegate void SelfConnectionStatusCallback (Tox self, Connection connection_status, void *user_data);
    public void callback_self_connection_status(SelfConnectionStatusCallback callback);

    public uint32 iteration_interval();

    [CCode(simple_generics = true)]
    public void iterate<T>(T? user_data = null);

    [CCode(cname = "tox_self_get_address")]
    private void _self_get_address([CCode(array_length = false)] uint8[] data);
    [CCode(cname = "vala_tox_self_get_address")]
    public uint8[] self_get_address() {
      var t = new uint8[address_size()];
      _self_get_address(t);
      return t;
    }

    public uint32 nospam {
      [CCode(cname = "tox_self_get_nospam")] get;
      [CCode(cname = "tox_self_set_nospam")] set;
    }

    [CCode(cname = "tox_self_get_public_key")]
    private void _self_get_public_key([CCode(array_length = false)] uint8[] public_key);
    [CCode(cname = "vala_tox_self_get_public_key")]
    public uint8[] self_get_public_key() {
      var t = new uint8[public_key_size()];
      _self_get_public_key(t);
      return t;
    }

    [CCode(cname = "tox_self_get_secret_key")]
    private void _self_get_secret_key([CCode(array_length = false)] uint8[] secret_key);
    [CCode(cname = "vala_tox_self_get_secret_key")]
    public uint8[] self_get_secret_key() {
      var t = new uint8[secret_key_size()];
      _self_get_secret_key(t);
      return t;
    }

    [CCode(cname = "tox_self_set_name")]
    private bool _self_set_name(uint8[] name, ref ErrSetInfo error);
    [CCode(cname = "vala_tox_self_set_name")]
    public bool self_set_name(string name, ref ErrSetInfo error) {
      return _self_set_name(name.data, ref error);
    }

    [CCode(cname = "tox_self_get_name_size")]
    private size_t _self_get_name_size();
    [CCode(cname = "tox_self_get_name")]
    private void _self_get_name([CCode(array_length = false)] uint8[] name);
    [CCode(cname = "vala_tox_self_get_name")]
    public string self_get_name() {
      var t = new uint8[_self_get_name_size() + 1];
      _self_get_name(t);
      return (string) t;
    }

    [CCode(cname = "tox_self_set_status_message")]
    private bool _self_set_status_message(uint8[] message, ref ErrSetInfo error);
    [CCode(cname = "vala_tox_self_set_status_message")]
    public bool self_set_status_message(string message, ref ErrSetInfo error) {
      return _self_set_status_message(message.data, ref error);
    }

    [CCode(cname = "tox_self_get_status_message_size")]
    private size_t _self_get_status_message_size();
    [CCode(cname = "tox_self_get_status_message")]
    private void _self_get_status_message([CCode(array_length = false)] uint8[] status_message);
    [CCode(cname = "vala_tox_self_get_status_message")]
    public string self_get_status_message() {
      var t = new uint8[_self_get_status_message_size() + 1];
      _self_get_status_message(t);
      return (string) t;
    }

    public UserStatus user_status {
      [CCode(cname = "tox_self_get_status")] get;
      [CCode(cname = "tox_self_set_status")] set;
    }

    [CCode(cname = "tox_friend_add")]
    private uint32 _friend_add([CCode(array_length = false)] uint8[] address, uint8[] message, ref ErrFriendAdd error);
    [CCode(cname = "vala_tox_friend_add")]
    public uint32 friend_add(uint8[] address, string message, ref ErrFriendAdd error) {
      return _friend_add(address, message.data, ref error);
    }

    public uint32 friend_add_norequest([CCode(array_length = false)] uint8[] public_key, ref ErrFriendAdd error);

    public bool friend_delete(uint32 friend_number, ref ErrFriendDelete error);

    public uint32 friend_by_public_key([CCode(array_length = false)] uint8[] public_key, ref ErrFriendByPublicKey error);

    public bool friend_exists(uint32 friend_number);

    [CCode(cname = "tox_self_get_friend_list_size")]
    private size_t _self_get_friend_list_size();
    [CCode(cname = "tox_self_get_friend_list")]
    private void _self_get_friend_list([CCode(array_length = false)] uint32[] friend_list);
    [CCode(cname = "vala_tox_self_get_friend_list")]
    public uint32[] self_get_friend_list() {
      var t = new uint32[_self_get_friend_list_size()];
      _self_get_friend_list(t);
      return t;
    }

    [CCode(cname = "tox_friend_get_public_key")]
    private bool _friend_get_public_key(uint32 friend_number, [CCode(array_length = false)] uint8[] public_key, ref ErrFriendGetPublicKey error);
    [CCode(cname = "vala_tox_friend_get_public_key")]
    public uint8[] friend_get_public_key(uint32 friend_number, ref ErrFriendGetPublicKey error) {
      var t = new uint8[public_key_size()];
      return (_friend_get_public_key(friend_number, t, ref error) ? t : null);
    }

    public uint64 friend_get_last_online(uint32 friend_number, ref ErrFriendGetLastOnline error);

    [CCode(cname = "tox_friend_get_name_size")]
    private size_t _friend_get_name_size(uint32 friend_number, ref ErrFriendQuery error);
    [CCode(cname = "tox_friend_get_name")]
    private bool _friend_get_name(uint32 friend_number, [CCode(array_length = false)] uint8[] name, ref ErrFriendQuery error);
    [CCode(cname = "vala_tox_friend_get_name")]
    public string? friend_get_name(uint32 friend_number, ref ErrFriendQuery error) {
      var len = _friend_get_name_size(friend_number, ref error);
      if (error != ErrFriendQuery.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _friend_get_name(friend_number, t, ref error) ? (string) t : null;
    }

    [CCode(cname = "tox_friend_name_cb", has_target = false, has_type_id = false)]
    public delegate void FriendNameCallback (Tox self, uint32 friend_number, uint8[] name, void *user_data);
    public void callback_friend_name(FriendNameCallback callback);

    [CCode(cname = "tox_friend_get_status_message_size")]
    private size_t _friend_get_status_message_size(uint32 friend_number, ref ErrFriendQuery error);
    [CCode(cname = "tox_friend_get_status_message")]
    private bool _friend_get_status_message(uint32 friend_number, [CCode(array_length = false)] uint8[] status_message, ref ErrFriendQuery error);
    [CCode(cname = "vala_tox_friend_get_status_message")]
    public string? friend_get_status_message(uint32 friend_number, ref ErrFriendQuery error) {
      var len = _friend_get_status_message_size(friend_number, ref error);
      if (error != ErrFriendQuery.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _friend_get_status_message(friend_number, t, ref error) ? (string) t : null;
    }

    [CCode(cname = "tox_friend_status_message_cb", has_target = false, has_type_id = false)]
    public delegate void FriendStatusMessageCallback (Tox self, uint32 friend_number, uint8[] message, void *user_data);
    public void callback_friend_status_message(FriendStatusMessageCallback callback);

    public UserStatus friend_get_status(uint32 friend_number, ref ErrFriendQuery error);

    [CCode(cname = "tox_friend_status_cb", has_target = false, has_type_id = false)]
    public delegate void FriendStatusCallback (Tox self, uint32 friend_number, UserStatus status, void *user_data);
    public void callback_friend_status(FriendStatusCallback callback);

    public Connection friend_get_connection_status(uint32 friend_number, ref ErrFriendQuery error);

    [CCode(cname = "tox_friend_connection_status_cb", has_target = false, has_type_id = false)]
    public delegate void FriendConnectionStatusCallback (Tox self, uint32 friend_number, Connection connection_status, void* userdata);
    public void callback_friend_connection_status(FriendConnectionStatusCallback callback);

    public bool friend_get_typing(uint32 friend_number, ref ErrFriendQuery error);

    [CCode(cname = "tox_friend_typing_cb", has_target = false, has_type_id = false)]
    public delegate void FriendTypingCallback (Tox self, uint32 friend_number, bool is_typing, void* userdata);
    public void callback_friend_typing(FriendTypingCallback callback);

    public bool self_set_typing(uint32 friend_number, bool typing, ref ErrSetTyping error);

    [CCode(cname = "tox_friend_send_message")]
    private uint32 _friend_send_message(uint32 friend_number, MessageType type, uint8[] message, ref ErrFriendSendMessage error);
    [CCode(cname = "vala_tox_friend_send_message")]
    public uint32 friend_send_message(uint32 friend_number, MessageType type, string message, ref ErrFriendSendMessage error) {
      return _friend_send_message(friend_number, type, message.data, ref error);
    }

    [CCode(cname = "tox_friend_read_receipt_cb", has_target = false, has_type_id = false)]
    public delegate void FriendReadReceptCallback(Tox self, uint32 friend_number, uint32 message_id, void *user_data);
    public void callback_friend_read_receipt(FriendReadReceptCallback callback);

    [CCode(cname = "tox_friend_request_cb", has_target = false, has_type_id = false)]
    public delegate void FriendRequestCallback(Tox self, [CCode(array_length = "public_key_size()")] uint8[] key, uint8[] message, void *user_data);
    public void callback_friend_request(FriendRequestCallback callback);

    [CCode(cname = "tox_friend_message_cb", has_target = false, has_type_id = false)]
    public delegate void FriendMessageCallback(Tox self, uint32 friend_number, MessageType type, uint8[] message, void *user_data);
    public void callback_friend_message(FriendMessageCallback callback);

    [CCode(cname = "tox_hash")]
    private static bool _hash([CCode(array_length = false)] uint8[] hash, uint8[] data);
    [CCode(cname = "vala_tox_hash")]
    public static uint8[] ? hash(uint8[] data) {
      var buf = new uint8[hash_length()];
      return _hash(buf, data) ? buf : null;
    }

    public bool file_control(uint32 friend_number, uint32 file_number, FileControl control, ref ErrFileControl error);

    [CCode(cname = "tox_file_recv_control_cb", has_target = false, has_type_id = false)]
    public delegate void FileRecvControlCallback(Tox self, uint32 friend_number, uint32 file_number, FileControl control, void *user_data);
    public void callback_file_recv_control(FileRecvControlCallback callback);

    public bool file_seek(uint32 friend_number, uint32 file_number, uint64 position, ref ErrFileSeek error);

    [CCode(cname = "tox_file_get_file_id")]
    private bool _file_get_file_id(uint32 friend_number, uint32 file_number, [CCode(array_length = false)] uint8[] file_id, ref ErrFileGet error);
    [CCode(cname = "vala_tox_file_get_file_id")]
    public uint8[] ? file_get_file_id(uint32 friend_number, uint32 file_number, ref ErrFileGet error) {
      var buf = new uint8[file_id_length()];
      return _file_get_file_id(friend_number, file_number, buf, ref error) ? buf : null;
    }

    public uint32 file_send(uint32 friend_number, uint32 kind, uint64 file_size, [CCode(array_length = false)] uint8[] file_id, uint8[] filename, ref ErrFileSeek error);

    public bool file_send_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data, ref ErrFileSendChunk error);

    [CCode(cname = "tox_file_chunk_request_cb", has_target = false, has_type_id = false)]
    public delegate void FileChunkRequestCallback(Tox self, uint32 friend_number, uint32 file_number, uint64 position, size_t length, void *user_data);
    public void callback_file_chunk_request(FileChunkRequestCallback callback);

    [CCode(cname = "tox_file_recv_cb", has_target = false, has_type_id = false)]
    public delegate void FileRecvCallback(Tox self, uint32 friend_number, uint32 file_number, uint32 kind, uint64 file_size, uint8[] filename, void *user_data);
    public void callback_file_recv(FileRecvCallback callback);

    [CCode(cname = "tox_file_recv_chunk_cb", has_target = false, has_type_id = false)]
    public delegate void FileRecvChunkCallback(Tox self, uint32 friend_number, uint32 file_number, uint64 position, uint8[] data, void* user_data);
    public void callback_file_recv_chunk(FileRecvChunkCallback callback);

    [CCode(cname = "tox_conference_invite_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceInviteCallback (Tox self, uint32 friend_number, ConferenceType type, uint8[] cookie, void *user_data);
    public void callback_conference_invite(ConferenceInviteCallback callback);

    [CCode(cname = "tox_conference_message_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceMessageCallback (Tox self, uint32 conference_number, uint32 peer_number, MessageType type, uint8[] message, void *user_data);
    public void callback_conference_message(ConferenceMessageCallback callback);

    [CCode(cname = "tox_conference_title_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceTitleCallback (Tox self, uint32 conference_number, uint32 peer_number, uint8[] title, void *user_data);
    public void callback_conference_title(ConferenceTitleCallback callback);

    [CCode(cname = "tox_conference_namelist_change_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceNamelistChangeCallback (Tox self, uint32 conference_number, uint32 peer_number, ConferenceStateChange change, void *user_data);
    public void callback_conference_namelist_change(ConferenceNamelistChangeCallback callback);

    public uint32 conference_new(ref ErrConferenceNew error);

    public bool conference_delete(uint32 conference_number, ref ErrConferenceDelete error);

    public uint32 conference_peer_count(uint32 conference_number, ref ErrConferencePeerQuery error);

    [CCode(cname = "tox_conference_peer_get_name_size")]
    private size_t _conference_peer_get_name_size(uint32 conference_number, uint32 peer_number, ref ErrConferencePeerQuery error);
    [CCode(cname = "tox_conference_peer_get_name")]
    private bool _conference_peer_get_name(uint32 conference_number, uint32 peer_number, [CCode(array_length = false)] uint8[] name, ref ErrConferencePeerQuery error);
    [CCode(cname = "vala_tox_conference_peer_get_name")]
    public string? conference_peer_get_name(uint32 conference_number, uint32 peer_number, ref ErrConferencePeerQuery error) {
      var len = _conference_peer_get_name_size(conference_number, peer_number, ref error);
      if (error != ErrConferencePeerQuery.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _conference_peer_get_name(conference_number, peer_number, t, ref error) ? (string) t : null;
    }

    [CCode(cname = "tox_conference_peer_get_public_key")]
    private bool _conference_peer_get_public_key(uint32 conference_number, uint32 peer_number, [CCode(array_length = false)] uint8[] public_key, ref ErrConferencePeerQuery error);
    [CCode(cname = "vala_tox_conference_peer_get_public_key")]
    public uint8[] conference_peer_get_public_key(uint32 conference_number, uint32 peer_number, ref ErrConferencePeerQuery error) {
      var t = new uint8[public_key_size()];
      return _conference_peer_get_public_key(conference_number, peer_number, t, ref error) ? t : null;
    }

    public bool conference_peer_number_is_ours(uint32 conference_number, uint32 peer_number, ref ErrConferencePeerQuery error);

    public bool conference_invite(uint32 friend_number, uint32 conference_number, ref ErrConferenceInvite error);

    public uint32 conference_join(uint32 friend_number, uint8[] cookie, ref ErrConferenceJoin error);

    [CCode(cname = "tox_conference_send_message")]
    private bool _conference_send_message(uint32 conference_number, MessageType type, uint8[] message, ref ErrConferenceSendMessage error);
    [CCode(cname = "vala_tox_conference_send_message")]
    public bool conference_send_message(uint32 conference_number, MessageType type, string message, ref ErrConferenceSendMessage error) {
      return _conference_send_message(conference_number, type, message.data, ref error);
    }

    [CCode(cname = "tox_conference_get_title_size")]
    private size_t _conference_get_title_size(uint32 conference_number, ref ErrConferenceTitle error);
    [CCode(cname = "tox_conference_get_title")]
    private bool _conference_get_title(uint32 conference_number, [CCode(array_length = false)] uint8[] title, ref ErrConferenceTitle error);
    [CCode(cname = "vala_tox_conference_get_title")]
    public string? conference_get_title(uint32 conference_number, ref ErrConferenceTitle error) {
      var len = _conference_get_title_size(conference_number, ref error);
      if (error != ErrConferenceTitle.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _conference_get_title(conference_number, t, ref error) ? (string) t : null;
    }

    [CCode(cname = "tox_conference_set_title")]
    private bool _conference_set_title(uint32 conference_number, uint8[] title, ref ErrConferenceTitle error);
    [CCode(cname = "vala_tox_conference_set_title")]
    public bool conference_set_title(uint32 conference_number, string title, ref ErrConferenceTitle error) {
      return _conference_set_title(conference_number, title.data, ref error);
    }

    [CCode(cname = "tox_conference_get_chatlist_size")]
    private size_t _conference_get_chatlist_size();
    [CCode(cname = "tox_conference_get_chatlist")]
    private void _conference_get_chatlist([CCode(array_length = false)] uint32[] chatlist);
    [CCode(cname = "vala_tox_conference_get_chatlist")]
    public uint32[] conference_get_chatlist() {
      var t = new uint32[_conference_get_chatlist_size()];
      _conference_get_chatlist(t);
      return t;
    }

    public ConferenceType conference_get_type(uint32 conference_number, ref ErrConferenceGetType error);
  }
}
