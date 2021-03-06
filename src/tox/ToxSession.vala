/*
 *    ToxSession.vala
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

using ToxCore;

namespace Venom {
  public errordomain ToxError {
    GENERIC
  }

  public enum ConferenceType {
    TEXT,
    AV
  }

  public class ToxConferencePeer : GLib.Object {
    public uint32 peer_number;
    public string? peer_name;
    public uint8[] ? peer_key;
    public bool is_self;
    public bool is_known;
    public ToxConferencePeer(uint32 peer_number, string? peer_name, uint8[] ? peer_key, bool is_self, bool is_known) {
      this.peer_number = peer_number;
      this.peer_name = peer_name;
      this.peer_key = peer_key;
      this.is_self = is_self;
      this.is_known = is_known;
    }
  }

  public delegate void GetFriendListCallback(uint32 friend_number, uint8[] friend_key);

  public interface ToxSession : GLib.Object {
    public abstract void set_session_listener(ToxSelfAdapter listener);
    public abstract void set_filetransfer_listener(ToxFiletransferAdapter listener);
    public abstract void set_friend_listener(ToxFriendAdapter listener);
    public abstract void set_conference_listener(ToxConferenceAdapter listener);
    public abstract void set_call_adapter(ToxCallAdapter listener);

    public abstract void self_set_user_name(string name);
    public abstract void self_set_status_message(string status);
    public abstract void self_set_typing(uint32 friend_number, bool typing) throws ToxError;
    public abstract void self_set_user_status(UserStatus status);

    public abstract string self_get_name();
    public abstract string self_get_status_message();
    public abstract UserStatus self_get_user_status();

    public abstract uint8[] self_get_address();
    public abstract uint8[] self_get_public_key();
    public abstract void self_set_nospam(uint32 nospam);

    public abstract void self_get_friend_list_foreach(GetFriendListCallback callback) throws ToxError;
    public abstract void friend_add(uint8[] address, string message) throws ToxError;
    public abstract uint32 friend_add_norequest_direct(uint8[] public_key) throws ToxError;
    public abstract void friend_add_norequest(uint8[] address) throws ToxError;
    public abstract void friend_delete(uint32 friend_number) throws ToxError;

    public abstract void friend_send_message(uint32 friend_number, string message) throws ToxError;
    public abstract uint32 friend_send_message_direct(uint32 friend_number, string message) throws ToxError;

    public abstract string friend_get_name(uint32 friend_number) throws ToxError;
    public abstract string friend_get_status_message(uint32 friend_number) throws ToxError;
    public abstract uint64 friend_get_last_online(uint32 friend_number) throws ToxError;

    public abstract uint32 conference_new(string title) throws ToxError;
    public abstract void conference_delete(uint32 conference_number) throws ToxError;
    public abstract void conference_invite(uint32 friend_number, uint32 conference_number) throws ToxError;
    public abstract void conference_join(uint32 friend_number, ConferenceType type, uint8[] cookie) throws ToxError;
    public abstract Gee.Iterable<uint32> conference_get_chatlist();

    public abstract void conference_send_message(uint32 conference_number, string message) throws ToxError;
    public abstract void conference_set_title(uint32 conference_number, string title) throws ToxError;
    public abstract string conference_get_title(uint32 conference_number) throws ToxError;

    public abstract void file_control(uint32 friend_number, uint32 file_number, FileControl control) throws ToxError;
    public abstract void file_send_data(uint32 friend_number, GLib.File file) throws ToxError;
    public abstract void file_send_avatar(uint32 friend_number, uint8[] avatar_data, uint8[] avatar_hash) throws ToxError;
    public abstract void file_send_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data) throws ToxError;

    public abstract void call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) throws ToxError;
    public abstract void accept_call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) throws ToxError;
    public abstract void call_control(uint32 friend_number, ToxAV.CallControl control) throws ToxError;
    public abstract void audio_send_sample(uint32 friend_number, Gst.Base.Adapter adapter, Gst.Caps caps) throws ToxError;
    public abstract void video_send_sample(uint32 friend_number, Gst.Sample sample) throws ToxError;

    public abstract unowned Gee.Map<uint32, IContact> get_friends();
  }

  public interface ToxSelfAdapter : GLib.Object {
    public abstract void on_self_connection_status_changed(bool is_connected);
  }

  public interface ToxFriendAdapter : GLib.Object {
    public abstract void on_friend_status_changed(uint32 friend_number, UserStatus status);
    public abstract void on_friend_connection_status_changed(uint32 friend_number, bool connected);
    public abstract void on_friend_name_changed(uint32 friend_number, string name);
    public abstract void on_friend_status_message_changed(uint32 friend_number, string message);
    public abstract void on_friend_typing_status_changed(uint32 friend_number, bool is_typing);

    public abstract void on_friend_request(uint8[] public_key, string message);
    public abstract void on_friend_added(uint32 friend_number, uint8[] public_key);
    public abstract void on_friend_deleted(uint32 friend_number);

    public abstract void on_friend_message(uint32 friend_number, string message);
    public abstract void on_friend_message_sent(uint32 friend_number, uint32 message_id, string message);
    public abstract void on_friend_read_receipt(uint32 friend_number, uint32 message_id);
  }

  public interface ToxConferenceAdapter : GLib.Object {
    public abstract void on_conference_new(uint32 conference_number, string title);
    public abstract void on_conference_deleted(uint32 conference_number);
    public abstract void on_conference_invite_received(uint32 friend_number, Venom.ConferenceType type, uint8[] cookie);

    public abstract void on_conference_title_changed(uint32 conference_number, uint32 peer_number, string title);
    public abstract void on_conference_peer_list_changed(uint32 conference_number, ToxConferencePeer[] peers);
    public abstract void on_conference_peer_renamed(uint32 conference_number, ToxConferencePeer peer);

    public abstract void on_conference_message(uint32 conference_number, uint32 peer_number, MessageType type, string message);
    public abstract void on_conference_message_sent(uint32 conference_number, string message);
  }

  public interface ToxFiletransferAdapter : GLib.Object {
    public abstract void on_file_recv_data(uint32 friend_number, uint32 file_number, uint64 file_size, string filename);
    public abstract void on_file_recv_avatar(uint32 friend_number, uint32 file_number, uint64 file_size, uint8[] hash);

    public abstract void on_file_recv_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data);
    public abstract void on_file_recv_control(uint32 friend_number, uint32 file_number, FileControl control);

    public abstract void on_file_chunk_request(uint32 friend_number, uint32 file_number, uint64 position, uint64 length);
    public abstract void on_file_send_data_received(uint32 friend_number, uint32 file_number, uint64 file_size, string file_name, GLib.File file);
    public abstract void on_file_send_avatar_received(uint32 friend_number, uint32 file_number, uint8[] avatar_data);
  }

  public interface ToxCallAdapter : GLib.Object {
    public abstract void on_audio_bit_rate_cb(uint32 friend_number, uint32 audio_bit_rate);
    public abstract void on_audio_receive_sample_cb(uint32 friend_number, Gst.Sample sample);

    public abstract void on_call_cb(uint32 friend_number, bool audio_enabled, bool video_enabled);
    public abstract void on_call_state_cb(uint32 friend_number, ToxAV.FriendCallState state);

    public abstract void on_video_bit_rate_cb(uint32 friend_number, uint32 video_bit_rate);
    public abstract void on_video_receive_sample_cb(uint32 friend_number, Gst.Sample sample);

    public abstract void on_av_conference_audio_sample_cb(uint32 group_number, uint32 peer_number, Gst.Sample sample);
  }

  public class ToxSessionImpl : GLib.Object, ToxSession {
    public Tox handle;
    private ToxAV.ToxAV av_handle;
    private Mutex mutex;

    private DhtNodeRepository dht_node_repository;
    private ISettingsDatabase settings_database;

    private Gee.Iterable<DhtNode> dht_nodes = Gee.Collection.empty<DhtNode>();
    private Logger logger;
    private ToxThread session_thread;
    private ToxThread av_thread;

    private ToxSelfAdapter self_listener;
    private ToxFriendAdapter friend_listener;
    private ToxConferenceAdapter conference_listener;
    private ToxFiletransferAdapter filetransfer_listener;
    private ToxCallAdapter call_adapter;
    private Profile profile;
    private Gee.HashMap<uint32, IContact> friends;

    public ToxSessionImpl(Profile profile, DhtNodeRepository node_database, ISettingsDatabase settings_database, Logger logger) throws Error {
      this.dht_node_repository = node_database;
      this.settings_database = settings_database;
      this.logger = logger;
      this.mutex = Mutex();
      this.profile = profile;

      var options_error = ToxCore.ErrOptionsNew.OK;
      var options = new ToxCore.Options(out options_error);

      options.log_callback = on_tox_message;
      friends = new Gee.HashMap<uint32, IContact>();

      uint8[] savedata;
      if (Profile.exists(profile.toxfile)) {
        savedata = profile.load_sessiondata();
        options.savedata_type = SaveDataType.TOX_SAVE;
        options.set_savedata_data(savedata);
      } else {
        logger.i("No tox data file found, creating new one.");
      }

      if (settings_database.enable_proxy) {
        init_proxy(options);
      }

      options.udp_enabled = settings_database.enable_udp;
      options.ipv6_enabled = settings_database.enable_ipv6;
      options.local_discovery_enabled = settings_database.enable_local_discovery;
      options.hole_punching_enabled = settings_database.enable_hole_punching;

      // create handle
      var error = ToxCore.ErrNew.OK;
      handle = new ToxCore.Tox(options, out error);
      if (error == ErrNew.PROXY_BAD_HOST || error == ErrNew.PROXY_BAD_PORT || error == ErrNew.PROXY_NOT_FOUND) {
        var message = "Proxy could not be used: " + error.to_string();
        logger.e(message);
        handle = null;
        throw new ToxError.GENERIC(message);
      } else if (error != ToxCore.ErrNew.OK) {
        var message = "Could not create tox instance: " + error.to_string();
        logger.e(message);
        handle = null;
        throw new ToxError.GENERIC(message);
      }

      var av_error = ToxAV.ErrNew.OK;
      av_handle = new ToxAV.ToxAV(handle, out av_error);
      if (av_error != ToxAV.ErrNew.OK) {
        var message = "Could not create tox av instance: " + av_error.to_string();
        logger.e(message);
        throw new ToxError.GENERIC(message);
      }

      handle.callback_self_connection_status(on_self_connection_status_cb);
      handle.callback_friend_connection_status(on_friend_connection_status_cb);
      handle.callback_friend_message(on_friend_message_cb);
      handle.callback_friend_name(on_friend_name_cb);
      handle.callback_friend_status_message(on_friend_status_message_cb);
      handle.callback_friend_status(on_friend_status_cb);
      handle.callback_friend_read_receipt(on_friend_read_receipt_cb);
      handle.callback_friend_request(on_friend_request_cb);
      handle.callback_friend_typing(on_friend_typing_cb);

      handle.callback_conference_title(on_conference_title_cb);
      handle.callback_conference_invite(on_conference_invite_cb);
      handle.callback_conference_message(on_conference_message_cb);
      handle.callback_conference_peer_name(on_conference_peer_name_cb);
      handle.callback_conference_peer_list_changed(on_conference_peer_list_changed_cb);

      handle.callback_file_recv(on_file_recv_cb);
      handle.callback_file_recv_chunk(on_file_recv_chunk_cb);
      handle.callback_file_recv_control(on_file_recv_control_cb);
      handle.callback_file_chunk_request(on_file_chunk_request_cb);

      av_handle.callback_audio_bit_rate(on_audio_bit_rate_cb);
      av_handle.callback_audio_receive_frame(on_audio_receive_frame_cb);
      av_handle.callback_call(on_call_cb);
      av_handle.callback_call_state(on_call_state_cb);
      av_handle.callback_video_bit_rate(on_video_bit_rate_cb);
      av_handle.callback_video_receive_frame(on_video_receive_frame_cb);

      init_dht_nodes();
      session_thread = new ToxSessionThreadImpl(this, logger, dht_nodes);
      session_thread.start();

      av_thread = new DefaultToxAVThread(logger, av_handle);
      av_thread.start();
      logger.d("ToxSession created.");
    }

    ~ToxSessionImpl() {
      if (av_thread != null) {
        logger.i("ToxSession stopping av background thread.");
        av_thread.stop();
      }
      if (session_thread != null) {
        logger.i("ToxSession stopping background thread.");
        session_thread.stop();
      }
      if (handle != null) {
        logger.i("ToxSession saving session data.");
        profile.save_sessiondata(handle.get_savedata());
        av_handle = null;
        handle = null;
      }
      logger.d("ToxSession destroyed.");
    }

    private void init_proxy(ToxCore.Options options) {
      if (settings_database.enable_custom_proxy) {
        options.proxy_type = ProxyType.SOCKS5;
        options.proxy_host = settings_database.custom_proxy_host;
        options.proxy_port = (uint16) settings_database.custom_proxy_port;
        logger.i("Using custom socks5 proxy: socks5://%s:%u.".printf(options.proxy_host, options.proxy_port));
        return;
      } else {
        string[] proxy_strings = {};
        ProxyResolver proxy_resolver = ProxyResolver.get_default();
        try {
          proxy_strings = proxy_resolver.lookup("socks://tox.im");
        } catch (Error e) {
          logger.e("Error when looking up proxy settings: " + e.message);
          return;
        }

        Regex proxy_regex = null;
        try {
          proxy_regex = new GLib.Regex("^(?P<protocol>socks5)://((?P<user>[^:]*)(:(?P<password>.*))?@)?(?P<host>.*):(?P<port>.*)");
        } catch (GLib.Error e) {
          logger.f("Error creating tox uri regex: " + e.message);
          return;
        }

        foreach (var proxy in proxy_strings) {
          if (proxy.has_prefix("socks5:")) {
            GLib.MatchInfo info = null;
            if (proxy_regex != null && proxy_regex.match(proxy, 0, out info)) {
              options.proxy_type = ProxyType.SOCKS5;
              options.proxy_host = info.fetch_named("host");
              options.proxy_port = (uint16) int.parse(info.fetch_named("port"));
              logger.i("Using socks5 proxy found in system settings: socks5://%s:%u.".printf(options.proxy_host, options.proxy_port));
              return;
            } else {
              logger.i("socks5 proxy does not match regex: " + proxy);
            }
          }
        }

        logger.i("No usable proxy found in system settings, connecting directly.");
      }
    }

    private void init_dht_nodes() {
      dht_nodes = dht_node_repository.query_all();
    }

    public virtual unowned Gee.Map<uint32, IContact> get_friends() {
      return friends;
    }

    public void on_tox_message(Tox self, ToxCore.LogLevel level, string file, uint32 line, string func, string message) {
      var tag = TermColor.YELLOW + "TOX" + TermColor.RESET;
      var msg = @"[$tag] $message ($func $file:$line)";
      switch (level) {
        case ToxCore.LogLevel.TRACE:
        case ToxCore.LogLevel.DEBUG:
          logger.d(msg);
          break;
        case ToxCore.LogLevel.INFO:
          logger.i(msg);
          break;
        case ToxCore.LogLevel.WARNING:
          logger.w(msg);
          break;
        case ToxCore.LogLevel.ERROR:
          logger.e(msg);
          break;
      }
    }

    public void set_session_listener(ToxSelfAdapter listener) {
      this.self_listener = listener;
    }

    public void set_filetransfer_listener(ToxFiletransferAdapter listener) {
      this.filetransfer_listener = listener;
    }

    public void set_friend_listener(ToxFriendAdapter listener) {
      this.friend_listener = listener;
    }

    public void set_conference_listener(ToxConferenceAdapter listener) {
      this.conference_listener = listener;
    }

    public void set_call_adapter(ToxCallAdapter adapter) {
      this.call_adapter = adapter;
    }

    private static string copy_data_string(uint8[] data) {
      var t = new uint8[data.length + 1];
      Memory.copy(t, data, data.length);
      return (string) t;
    }

    private static uint8[] copy_data(uint8[] data, uint len) {
      var t = new uint8[len];
      Memory.copy(t, data, len);
      return t;
    }

    private static void on_self_connection_status_cb(Tox self, Connection connection_status, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_self_connection_status_cb");
      var user_status = from_connection(connection_status);
      Idle.add(() => { session.self_listener.on_self_connection_status_changed(user_status); return false; });
    }

    private static void on_friend_connection_status_cb(Tox self, uint32 friend_number, Connection connection_status, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_connection_status_cb");
      var user_status = from_connection(connection_status);
      Idle.add(() => { session.friend_listener.on_friend_connection_status_changed(friend_number, user_status); return false; });
    }

    private static void on_friend_name_cb(Tox self, uint32 friend_number, uint8[] name, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_name_cb");
      var name_str = copy_data_string(name);
      Idle.add(() => { session.friend_listener.on_friend_name_changed(friend_number, name_str); return false; });
    }

    private static void on_friend_request_cb(Tox self, uint8[] key, uint8[] message, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_request_cb");
      var key_copy = copy_data(key, public_key_size());
      var message_str = copy_data_string(message);
      Idle.add(() => { session.friend_listener.on_friend_request(key_copy, message_str); return false; });
    }

    private static void on_friend_message_cb(Tox self, uint32 friend_number, MessageType type, uint8[] message, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_message_cb");
      var message_str = copy_data_string(message);
      Idle.add(() => { session.friend_listener.on_friend_message(friend_number, message_str); return false; });
    }

    private static void on_friend_status_message_cb(Tox self, uint32 friend_number, uint8[] message, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_status_message_cb");
      var message_str = copy_data_string(message);
      Idle.add(() => { session.friend_listener.on_friend_status_message_changed(friend_number, message_str); return false; });
    }

    private static void on_friend_status_cb(Tox self, uint32 friend_number, ToxCore.UserStatus status, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_status_cb");
      var user_status = from_user_status(status);
      Idle.add(() => { session.friend_listener.on_friend_status_changed(friend_number, user_status); return false; });
    }

    private static void on_friend_typing_cb(Tox self, uint32 friend_number, bool is_typing, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_typing_cb");
      Idle.add(() => { session.friend_listener.on_friend_typing_status_changed(friend_number, is_typing); return false; });
    }

    private static void on_friend_read_receipt_cb(Tox self, uint32 friend_number, uint32 message_id, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_friend_read_receipt_cb");

      Idle.add(() => { session.friend_listener.on_friend_read_receipt(friend_number, message_id); return false; });
    }

    private static void on_conference_title_cb(Tox self, uint32 conference_number, uint32 peer_number, uint8[] title, void *user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_conference_title_cb");

      var title_str = copy_data_string(title);
      Idle.add(() => { session.conference_listener.on_conference_title_changed(conference_number, peer_number, title_str); return false; });
    }

    private static void on_conference_invite_cb(Tox self, uint32 friend_number, ToxCore.ConferenceType type, uint8[] cookie, void *user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_conference_invite_cb type:" + type.to_string());
      var gc_type = (type == ToxCore.ConferenceType.AV) ? ConferenceType.AV : ConferenceType.TEXT;
      var cookie_copy = copy_data(cookie, cookie.length);
      Idle.add(() => { session.conference_listener.on_conference_invite_received(friend_number, gc_type, cookie_copy); return false; });
    }

    private void on_audio_bit_rate_cb(ToxAV.ToxAV av, uint32 friend_number, uint32 audio_bit_rate) {
      logger.d(@"on_audio_bit_rate_cb friend_number:$friend_number");

      Idle.add(() => { call_adapter.on_audio_bit_rate_cb(friend_number, audio_bit_rate); return false; });
    }
    private Gst.Sample create_sample_from_pcm(int16[] pcm, size_t sample_count, uint8 channels, uint32 sampling_rate) {
      Gst.Audio.ChannelPosition[] positions = {Gst.Audio.ChannelPosition.NONE, Gst.Audio.ChannelPosition.NONE};
      var info = new Gst.Audio.Info();
      info.set_format(Gst.Audio.Format.S16, (int) sampling_rate, channels, positions);
      var buffer = new Gst.Buffer.allocate(null, sample_count * channels * sizeof(uint16), null);
      Gst.MapInfo map_info;
      buffer.map(out map_info, Gst.MapFlags.WRITE);
      GLib.Memory.copy(map_info.data, pcm, map_info.size);
      buffer.unmap(map_info);
      return new Gst.Sample(buffer, info.to_caps(), null, null);
    }
    private void on_audio_receive_frame_cb(ToxAV.ToxAV av, uint32 friend_number, int16[] pcm, size_t sample_count, uint8 channels, uint32 sampling_rate) {
      // logger.d(@"on_audio_receive_frame_cb friend_number:$friend_number");

      //FIXME push directly to pipeline
      var sample = create_sample_from_pcm(pcm, sample_count, channels, sampling_rate);

      Idle.add(() => { call_adapter.on_audio_receive_sample_cb(friend_number, sample); return false; });
    }
    private void on_call_cb(ToxAV.ToxAV av, uint32 friend_number, bool audio_enabled, bool video_enabled) {
      logger.d(@"on_call_cb friend_number:$friend_number");

      Idle.add(() => { call_adapter.on_call_cb(friend_number, audio_enabled, video_enabled); return false; });
    }
    private void on_call_state_cb(ToxAV.ToxAV av, uint32 friend_number, ToxAV.FriendCallState state) {
      logger.d(@"on_call_state_cb friend_number:$friend_number");

      Idle.add(() => { call_adapter.on_call_state_cb(friend_number, state); return false; });
    }
    private void on_video_bit_rate_cb(ToxAV.ToxAV av, uint32 friend_number, uint32 video_bit_rate) {
      logger.d(@"on_video_bit_rate_cb friend_number:$friend_number");

      Idle.add(() => { call_adapter.on_video_bit_rate_cb(friend_number, video_bit_rate); return false; });
    }
    private void on_video_receive_frame_cb(ToxAV.ToxAV av, uint32 friend_number, uint16 width, uint16 height, uint8[] y, uint8[] u, uint8[] v, int32 ystride, int32 ustride, int32 vstride) {
      // logger.d(@"on_video_receive_frame_cb friend_number:$friend_number");

      //FIXME push directly to pipeline
      var info = new Gst.Video.Info();
      info.set_format(Gst.Video.Format.I420, width, height);
      var data = new uint8[info.size];

      uint8*[] planes = {y, u, v};
      int32[] strides = {ystride, ustride, vstride};
      uint16[] heights = {height, height / 2, height / 2};

      for (var i = 0; i < planes.length; i++) {
        var stride = int.min(strides[i], info.stride[i]);
        for (var j = 0; j < heights[i]; j++) {
          uint8* src = (uint8*) planes[i] + strides[i] * j;
          uint8* dest = (uint8*) data + info.stride[i] * j + info.offset[i];
          GLib.Memory.copy(dest, src, stride);
        }
      }

      var buffer = new Gst.Buffer.wrapped(data);
      var sample = new Gst.Sample(buffer, info.to_caps(), null, null);

      Idle.add(() => { call_adapter.on_video_receive_sample_cb(friend_number, sample); return false; });
    }

    private void on_av_conference_audio_frame(ToxCore.Tox self, uint32 group_number, uint32 peer_number, int16[] pcm, uint sample_count, uint8 channels, uint32 sampling_rate) {
      // logger.d(@"on_av_conference_audio_frame: group_number:$group_number, peer_number:$peer_number");

      //FIXME push directly to pipeline
      var sample = create_sample_from_pcm(pcm, sample_count, channels, sampling_rate);
      Idle.add(() => { call_adapter.on_av_conference_audio_sample_cb(group_number, peer_number, sample); return false; });
    }

    public void audio_send_sample(uint32 friend_number, Gst.Base.Adapter adapter, Gst.Caps caps) throws ToxError {
      var info = new Gst.Audio.Info();
      info.from_caps(caps);
      var frame_size = 960 * sizeof(uint16) * info.channels; // 48000 / 1000 * 20ms
      var e = ToxAV.ErrSendFrame.OK;
      while (adapter.available() >= frame_size) {
        var buf = adapter.take(frame_size);
        av_handle.audio_send_frame(friend_number, (int16[]) buf, frame_size / sizeof(uint16), (uint8) info.channels, info.rate, out e);
        if (e != ToxAV.ErrSendFrame.OK) {
          logger.d("Sending audio frame failed: " + e.to_string());
          throw new ToxError.GENERIC("Sending audio frame failed: " + e.to_string());
        }
      }
    }

    public void video_send_sample(uint32 friend_number, Gst.Sample sample) throws ToxError {
      var buffer = sample.get_buffer();
      var caps = sample.get_caps();
      var info = new Gst.Video.Info();
      info.from_caps(caps);
      Gst.MapInfo map_info;
      buffer.map(out map_info, Gst.MapFlags.READ);

      int[] strides = {info.width, info.width / 2, info.width / 2};
      int[] heights = {info.height, info.height / 2, info.height / 2};
      int[] sizes = {strides[0]*heights[0], strides[1]*heights[1], strides[2]*heights[2]};
      var y = new uint8[sizes[0]];
      var u = new uint8[sizes[1]];
      var v = new uint8[sizes[2]];
      uint8*[] planes = {y, u, v};
      for (var i = 0; i < planes.length; i++) {
        for (var j = 0; j < heights[i]; j++) {
          GLib.Memory.copy(planes[i] + j * strides[i], (uint8*) map_info.data + j * info.stride[i] + info.offset[i], strides[i]);
        }
      }
      buffer.unmap(map_info);
      var e = ToxAV.ErrSendFrame.OK;
      av_handle.video_send_frame(friend_number, (uint16) info.width, (uint16) info.height, y, u, v, out e);
      if (e != ToxAV.ErrSendFrame.OK) {
        logger.d("Sending video frame failed: " + e.to_string());
        throw new ToxError.GENERIC("Sending video frame failed: " + e.to_string());
      }
    }

    private static void on_conference_message_cb(Tox self, uint32 conference_number, uint32 peer_number, MessageType type, uint8[] message, void *user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_conference_message_cb");
      var message_str = copy_data_string(message);
      var err = ErrConferencePeerQuery.OK;
      var is_ours = self.conference_peer_number_is_ours(conference_number, peer_number, out err);
      if (err != ErrConferencePeerQuery.OK) {
        session.logger.e("conference_peer_number_is_ours failed: " + err.to_string());
        return;
      }
      if (is_ours) {
        Idle.add(() => { session.conference_listener.on_conference_message_sent(conference_number, message_str); return false; });
      } else {
        Idle.add(() => { session.conference_listener.on_conference_message(conference_number, peer_number, type, message_str); return false; });
      }
    }

    private static void on_conference_peer_name_cb(Tox self, uint32 conference_number, uint32 peer_number, uint8[] name, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_conference_peer_name_cb");
      var peer_name = copy_data_string(name);
      var err = ErrConferencePeerQuery.OK;
      var peer_public_key = self.conference_peer_get_public_key(conference_number, peer_number, out err);
      if (err != ErrConferencePeerQuery.OK) {
        session.logger.e("conference_peer_get_public_key failed: " + err.to_string());
        return;
      }
      var is_self = self.conference_peer_number_is_ours(conference_number, peer_number, out err);
      var is_known = false;
      if (!is_self) {
        var err_pubkey = ErrFriendByPublicKey.OK;
        self.friend_by_public_key(peer_public_key, out err_pubkey);
        is_known = err_pubkey == ErrFriendByPublicKey.OK;
      }
      var peer = new ToxConferencePeer(peer_number, peer_name, peer_public_key, is_self, is_known);
      Idle.add(() => { session.conference_listener.on_conference_peer_renamed(conference_number, peer); return false; });
    }

    private static void on_conference_peer_list_changed_cb(Tox self, uint32 conference_number, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d("on_conference_peer_list_changed_cb");
      var err = ErrConferencePeerQuery.OK;
      var peer_count = self.conference_peer_count(conference_number, out err);
      if (err != ErrConferencePeerQuery.OK) {
        session.logger.e(@"Could not query peer count for conference $conference_number: " + err.to_string());
        return;
      }
      var peers = new ToxConferencePeer[peer_count];
      for (var i = 0; i < peer_count; i++) {
        var peer_public_key = self.conference_peer_get_public_key(conference_number, i, out err);
        var peer_name = self.conference_peer_get_name(conference_number, i, out err);
        var is_self = self.conference_peer_number_is_ours(conference_number, i, out err);
        var err_pubkey = ErrFriendByPublicKey.OK;
        self.friend_by_public_key(peer_public_key, out err_pubkey);
        var is_known = err_pubkey == ErrFriendByPublicKey.OK;
        peers[i] = new ToxConferencePeer(i, peer_name, peer_public_key, is_self, is_known);
      }
      Idle.add(() => { session.conference_listener.on_conference_peer_list_changed(conference_number, peers); return false; });
    }

    private static void on_file_recv_cb(Tox self, uint32 friend_number, uint32 file_number, uint32 kind, uint64 file_size, uint8[] filename, void *user_data) {
      var session = (ToxSessionImpl) user_data;
      var kind_type = (FileKind) kind;
      var kiB = file_size / 1024f;
      var filename_str = copy_data_string(filename);
      var kind_type_str = kind_type.to_string();
      session.logger.d(@"on_file_recv_cb: $friend_number:$file_number ($kind_type_str) $kiB kiB");
      switch (kind_type) {
        case FileKind.DATA:
          Idle.add(() => { session.filetransfer_listener.on_file_recv_data(friend_number, file_number, file_size, filename_str); return false; });
          break;
        case FileKind.AVATAR:
          var e = ToxCore.ErrFileGet.OK;
          var hash = self.file_get_file_id(friend_number, file_number, out e);
          Idle.add(() => { session.filetransfer_listener.on_file_recv_avatar(friend_number, file_number, file_size, hash); return false; });
          break;
      }
    }

    private static void on_file_recv_chunk_cb(Tox self, uint32 friend_number, uint32 file_number, uint64 position, uint8[] data, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d(@"on_file_recv_chunk_cb: $friend_number:$file_number $position");
      var data_copy = copy_data(data, data.length);
      Idle.add(() => { session.filetransfer_listener.on_file_recv_chunk(friend_number, file_number, position, data_copy); return false; });
    }

    private static void on_file_recv_control_cb(Tox self, uint32 friend_number, uint32 file_number, FileControl control, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      var control_str = control.to_string();
      session.logger.d(@"on_file_recv_control_cb: $friend_number:$file_number $control_str");
      Idle.add(() => { session.filetransfer_listener.on_file_recv_control(friend_number, file_number, control); return false; });
    }

    private static void on_file_chunk_request_cb(Tox self, uint32 friend_number, uint32 file_number, uint64 position, size_t length, void* user_data) {
      var session = (ToxSessionImpl) user_data;
      session.logger.d(@"on_file_chunk_request_cb: $friend_number:$file_number $position $length");
      Idle.add(() => { session.filetransfer_listener.on_file_chunk_request(friend_number, file_number, position, length); return false; });
    }

    private static bool from_connection(Connection connection_status) {
      return connection_status != Connection.NONE;
    }

    private static Venom.UserStatus from_user_status(ToxCore.UserStatus user_status) {
      switch (user_status) {
        case ToxCore.UserStatus.NONE:
          return Venom.UserStatus.NONE;
        case ToxCore.UserStatus.AWAY:
          return Venom.UserStatus.AWAY;
        case ToxCore.UserStatus.BUSY:
          return Venom.UserStatus.BUSY;
      }
      assert_not_reached();
    }

    public virtual string self_get_name() {
      return handle.self_get_name();
    }

    public virtual string self_get_status_message() {
      return handle.self_get_status_message();
    }

    public virtual void self_get_friend_list_foreach(GetFriendListCallback callback) throws ToxError {
      var friend_numbers = handle.self_get_friend_list();
      for (var i = 0; i < friend_numbers.length; i++) {
        var friend_number = friend_numbers[i];
        var friend_key = friend_get_public_key(friend_number);
        callback(friend_number, friend_key);
      }
    }

    public virtual void self_set_user_name(string name) {
      var e = ErrSetInfo.OK;
      if (!handle.self_set_name(name, out e)) {
        logger.e("set_user_name failed: " + e.to_string());
      }
    }

    public virtual uint8[] self_get_address() {
      return handle.self_get_address();
    }

    public virtual uint8[] self_get_public_key() {
      return handle.self_get_public_key();
    }

    public virtual void self_set_nospam(uint32 nospam) {
      handle.self_nospam = nospam;
    }

    public virtual void self_set_status_message(string status) {
      var e = ErrSetInfo.OK;
      if (!handle.self_set_status_message(status, out e)) {
        logger.e("set_user_status failed: " + e.to_string());
      }
    }

    public void self_set_user_status(UserStatus status) {
      switch (status) {
        case UserStatus.AWAY:
          handle.self_status = ToxCore.UserStatus.AWAY;
          break;
        case UserStatus.BUSY:
          handle.self_status = ToxCore.UserStatus.BUSY;
          break;
        default:
          handle.self_status = ToxCore.UserStatus.NONE;
          break;
      }
    }

    public UserStatus self_get_user_status() {
      return from_user_status(handle.self_status);
    }

    public virtual uint8[] friend_get_public_key(uint32 friend_number) throws ToxError {
      var e = ErrFriendGetPublicKey.OK;
      var ret = handle.friend_get_public_key(friend_number, out e);
      if (e != ErrFriendGetPublicKey.OK) {
        logger.e("friend_get_public_key failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual string friend_get_name(uint32 friend_number) throws ToxError {
      var e = ErrFriendQuery.OK;
      var ret = handle.friend_get_name(friend_number, out e);
      if (e != ErrFriendQuery.OK) {
        logger.e("friend_get_name failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual string friend_get_status_message(uint32 friend_number) throws ToxError {
      var e = ErrFriendQuery.OK;
      var ret = handle.friend_get_status_message(friend_number, out e);
      if (e != ErrFriendQuery.OK) {
        logger.e("friend_get_status_message failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual uint64 friend_get_last_online(uint32 friend_number) throws ToxError {
      var e = ErrFriendGetLastOnline.OK;
      var ret = handle.friend_get_last_online(friend_number, out e);
      if (e != ErrFriendGetLastOnline.OK) {
        logger.e("friend_get_last_online failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual void friend_add(uint8[] address, string message) throws ToxError {
      if (address.length != address_size()) {
        throw new ToxError.GENERIC(_("Address must consist of 76 hexadecimal characters"));
      }
      var e = ErrFriendAdd.OK;
      var friend_number = handle.friend_add(address, message, out e);
      if (e != ErrFriendAdd.OK) {
        logger.i("friend_add failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      var key = friend_get_public_key(friend_number);
      friend_listener.on_friend_added(friend_number, key);
    }

    public uint32 friend_add_norequest_direct(uint8[] public_key) throws ToxError {
      var e = ErrFriendAdd.OK;
      var friend_number = handle.friend_add_norequest(public_key, out e);
      if (e != ErrFriendAdd.OK) {
        logger.i("friend_add failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return friend_number;
    }

    public virtual void friend_add_norequest(uint8[] public_key) throws ToxError {
      var friend_number = friend_add_norequest_direct(public_key);
      friend_listener.on_friend_added(friend_number, public_key);
    }

    public virtual void friend_delete(uint32 friend_number) throws ToxError {
      var e = ErrFriendDelete.OK;
      if (!handle.friend_delete(friend_number, out e)) {
        logger.i("friend_delete failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      friend_listener.on_friend_deleted(friend_number);
    }

    public virtual void friend_send_message(uint32 friend_number, string message) throws ToxError {
      var ret = friend_send_message_direct(friend_number, message);
      friend_listener.on_friend_message_sent(friend_number, ret, message);
    }

    public virtual uint32 friend_send_message_direct(uint32 friend_number, string message) throws ToxError {
      var e = ErrFriendSendMessage.OK;
      var ret = handle.friend_send_message(friend_number, MessageType.NORMAL, message, out e);
      if (e != ErrFriendSendMessage.OK) {
        logger.i("friend_send_message failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual void self_set_typing(uint32 friend_number, bool typing) throws ToxError {
      var e = ErrSetTyping.OK;
      handle.self_set_typing(friend_number, typing, out e);
      if (e != ErrSetTyping.OK) {
        logger.i("self_set_typing failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public virtual void file_control(uint32 friend_number, uint32 file_number, FileControl control) throws ToxError {
      var e = ErrFileControl.OK;
      handle.file_control(friend_number, file_number, control, out e);
      if (e != ErrFileControl.OK) {
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public virtual void file_send_avatar(uint32 friend_number, uint8[] avatar_data, uint8[] avatar_hash) throws ToxError {
      var e = ErrFileSend.OK;
      var ret = handle.file_send(friend_number, FileKind.AVATAR, avatar_data.length, avatar_hash, "", out e);
      if (e != ErrFileSend.OK) {
        logger.e("file send avatar request failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      filetransfer_listener.on_file_send_avatar_received(friend_number, ret, avatar_data);
    }

    public virtual void file_send_data(uint32 friend_number, GLib.File file) throws ToxError {
      uint64 file_size = Tools.get_file_size(file);
      var file_name = file.get_basename();

      var e = ErrFileSend.OK;
      var ret = handle.file_send(friend_number, FileKind.DATA, file_size, null, file_name, out e);
      if (e != ErrFileSend.OK) {
        logger.e("file send request failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      filetransfer_listener.on_file_send_data_received(friend_number, ret, file_size, file_name, file);
    }

    public virtual void file_send_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data) throws ToxError {
      var e = ErrFileSendChunk.OK;
      handle.file_send_chunk(friend_number, file_number, position, data, out e);
      if (e != ErrFileSendChunk.OK) {
        logger.e("sending chunk failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    private void conference_set_title_private(uint32 conference_number, string title) throws ToxError {
      var e = ErrConferenceTitle.OK;
      handle.conference_set_title(conference_number, title, out e);
      if (e != ErrConferenceTitle.OK) {
        logger.e("setting conference title failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public virtual void conference_set_title(uint32 conference_number, string title) throws ToxError {
      conference_set_title_private(conference_number, title);
      conference_listener.on_conference_title_changed(conference_number, 0, title);
    }

    public virtual string conference_get_title(uint32 conference_number) throws ToxError {
      var e = ErrConferenceTitle.OK;
      var title = handle.conference_get_title(conference_number, out e);
      if (e != ErrConferenceTitle.OK) {
        logger.e("getting conference title failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return title;
    }

    public virtual uint32 conference_new(string title) throws ToxError {
      var e = ErrConferenceNew.OK;
      var conference_number = handle.conference_new(out e);
      if (e != ErrConferenceNew.OK) {
        logger.e("creating conference failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      if (title != "") {
        try {
          conference_set_title_private(conference_number, title);
        } catch (ToxError e) {
          var err_conference_delete = ErrConferenceDelete.OK;
          handle.conference_delete(conference_number, out err_conference_delete);
          throw e;
        }
      }
      conference_listener.on_conference_new(conference_number, title);
      return conference_number;
    }

    public virtual void conference_join(uint32 friend_number, ConferenceType type, uint8[] cookie) throws ToxError {
      uint32 conference_number;
      switch (type) {
        case ConferenceType.AV:
          conference_number = ToxAV.ToxAV.join_av_groupchat(handle, friend_number, cookie, on_av_conference_audio_frame);
          if (conference_number < 0) {
            var message = @"Conference AV join failed: $conference_number";
            logger.e(message);
            throw new ToxError.GENERIC(message);
          }
          break;
        default:
          var err = ErrConferenceJoin.OK;
          conference_number = handle.conference_join(friend_number, cookie, out err);
          if (err != ErrConferenceJoin.OK) {
            logger.e("Conference join failed: " + err.to_string());
            throw new ToxError.GENERIC(err.to_string());
          }
          break;
      }

      conference_listener.on_conference_new(conference_number, "");
    }

    public virtual void conference_delete(uint32 conference_number) throws ToxError {
      var e = ErrConferenceDelete.OK;
      handle.conference_delete(conference_number, out e);
      if (e != ErrConferenceDelete.OK) {
        logger.e("deleting conference failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      conference_listener.on_conference_deleted(conference_number);
    }

    public virtual void conference_invite(uint32 friend_number, uint32 conference_number) throws ToxError {
      var e = ErrConferenceInvite.OK;
      handle.conference_invite(friend_number, conference_number, out e);
      if (e != ErrConferenceInvite.OK) {
        logger.e("Sending conference invite failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public virtual void conference_send_message(uint32 conference_number, string message) throws ToxError {
      var e = ErrConferenceSendMessage.OK;
      handle.conference_send_message(conference_number, MessageType.NORMAL, message, out e);
      if (e != ErrConferenceSendMessage.OK) {
        logger.e("sending conference message failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public Gee.Iterable<uint32> conference_get_chatlist() {
      var chatlist = handle.conference_get_chatlist();
      var list = new Gee.ArrayList<uint32>();
      foreach (var c in chatlist) {
        list.add(c);
      }
      return list;
    }

    public void call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) throws ToxError {
      var e = ToxAV.ErrCall.OK;
      av_handle.call(friend_number, audio_bit_rate, video_bit_rate, out e);
      if (e != ToxAV.ErrCall.OK) {
        logger.e("starting call failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public void accept_call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) throws ToxError {
      var e = ToxAV.ErrAnswer.OK;
      av_handle.answer(friend_number, audio_bit_rate, video_bit_rate, out e);
      if (e != ToxAV.ErrAnswer.OK) {
        logger.e("accepting call failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public void call_control(uint32 friend_number, ToxAV.CallControl control) throws ToxError {
      var e = ToxAV.ErrCallControl.OK;
      av_handle.call_control(friend_number, control, out e);
      if (e != ToxAV.ErrCallControl.OK) {
        logger.e("call control failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public void @lock() {
      mutex.@lock();
    }
    public void unlock() {
      mutex.unlock();
    }
  }
}
