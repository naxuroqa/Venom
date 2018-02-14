/*
 *    ToxSession.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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

  public delegate void GetFriendListCallback(uint8[] friend_key);

  public interface ToxSession : GLib.Object {
    public abstract void set_session_listener(ToxSessionListener listener);

    public abstract void self_set_user_name(string name);
    public abstract void self_set_status_message(string status);

    public abstract uint8[] self_get_address();

    public abstract void self_get_friend_list_foreach(GetFriendListCallback callback) throws ToxError;
    public abstract void friend_add(uint8[] id, string message) throws ToxError;
    public abstract void friend_delete(uint8[] id) throws ToxError;
    public abstract void friend_send_message(uint8[] id, string message) throws ToxError;

    public abstract string friend_get_name(uint8[] id) throws ToxError;
    public abstract string friend_get_status_message(uint8[] id) throws ToxError;
    public abstract uint64 friend_get_last_online(uint8[] id) throws ToxError;

    public abstract void conference_new(string title) throws ToxError;
    public abstract void conference_set_title(uint32 id, string title) throws ToxError;
  }

  public interface ToxSessionListener : GLib.Object {
    public abstract void on_self_status_changed(UserStatus status);
    public abstract void on_friend_status_changed(uint8[] id, UserStatus status);
    public abstract void on_friend_message(uint8[] id, string message);
    public abstract void on_friend_read_receipt(uint8[] id, uint32 message_id);
    public abstract void on_friend_name_changed(uint8[] id, string name);
    public abstract void on_friend_status_message_changed(uint8[] id, string message);
    public abstract void on_friend_request(uint8[] id, string message);

    public abstract void on_friend_added(uint8[] id);
    public abstract void on_friend_deleted(uint8[] id);
    public abstract void on_friend_message_sent(uint8[] id, uint32 message_id, string message);
    public abstract void on_conference_new(uint32 id, string title);
  }

  public class ToxSessionImpl : GLib.Object, ToxSession {
    public Tox handle;
    private Mutex mutex;

    private IDhtNodeDatabase dht_node_storage;

    private List<IDhtNode> dht_nodes = new List<IDhtNode>();
    private ILogger logger;
    private ToxSessionThread sessionThread;

    private ToxSessionListener listener;
    private ToxSessionIO iohandler;

    public ToxSessionImpl(ToxSessionIO iohandler, IDhtNodeDatabase nodeDatabase, ILogger logger) {
      this.dht_node_storage = nodeDatabase;
      this.logger = logger;
      this.mutex = Mutex();
      this.iohandler = iohandler;

      var options_error = ToxCore.ErrOptionsNew.OK;
      var options = new ToxCore.Options(ref options_error);

      options.log_callback = on_tox_message;

      var savedata = iohandler.load_sessiondata();
      if (savedata != null) {
        options.savedata_type = SaveDataType.TOX_SAVE;
        options.savedata_data = savedata;
      }

      // create handle
      var error = ToxCore.ErrNew.OK;
      handle = new ToxCore.Tox(options, ref error);
      if (error != ToxCore.ErrNew.OK) {
        logger.e("Could not create tox instance: " + error.to_string());
        assert_not_reached();
      }

      handle.callback_self_connection_status(on_self_connection_status_cb);
      handle.callback_friend_connection_status(on_friend_connection_status_cb);
      handle.callback_friend_message(on_friend_message_cb);
      handle.callback_friend_name(on_friend_name_cb);
      handle.callback_friend_status_message(on_friend_status_message_cb);
      handle.callback_friend_read_receipt(on_friend_read_receipt_cb);
      handle.callback_friend_request(on_friend_request_cb);

      init_dht_nodes();
      sessionThread = new ToxSessionThreadImpl(this, logger, dht_nodes);
      sessionThread.start();
      logger.d("ToxSession created.");
    }

    // destructor
    ~ToxSessionImpl() {
      logger.d("ToxSession stopping background thread.");
      sessionThread.stop();
      logger.d("ToxSession saving session data.");
      iohandler.save_sessiondata(handle.get_savedata());
      logger.d("ToxSession destroyed.");
    }

    public void on_tox_message(Tox self, ToxCore.LogLevel level, string file, uint32 line, string func, string message) {
      //var msg = "%s:%u (%s): %s".printf(file, line, func, message);
      var msg = "%s: %s".printf(func, message);
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

    public virtual void set_session_listener(ToxSessionListener listener) {
      this.listener = listener;
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

    private static void on_self_connection_status_cb(Tox self, Connection connection_status, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_self_connection_status_cb");
      var user_status = from_connection_status(connection_status);
      Idle.add(() => { session.listener.on_self_status_changed(user_status); return false; });
    }

    private static void on_friend_connection_status_cb(Tox self, uint32 friend_number, Connection connection_status, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_friend_connection_status_cb");
      var user_status = from_connection_status(connection_status);
      try {
        var id = session.friend_get_public_key(friend_number);
        Idle.add(() => { session.listener.on_friend_status_changed(id, user_status); return false; });
      } catch (Error e) {
        session.logger.f("friend lookup failed: " + e.message);
      }
    }

    private static void on_friend_name_cb(Tox self, uint32 friend_number, uint8[] name, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_friend_name_cb");
      var name_str = copy_data_string(name);
      try {
        var id = session.friend_get_public_key(friend_number);
        Idle.add(() => { session.listener.on_friend_name_changed(id, name_str); return false; });
      } catch (Error e) {
        session.logger.f("friend lookup failed: " + e.message);
      }
    }

    private static void on_friend_request_cb(Tox self, uint8[] key, uint8[] message, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_friend_request_cb");
      var message_str = copy_data_string(message);
      var id = copy_data(key, public_key_size());
      Idle.add(() => { session.listener.on_friend_message(id, message_str); return false; });
    }

    private static void on_friend_message_cb(Tox self, uint32 friend_number, MessageType type, uint8[] message, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_friend_message_cb");
      var message_str = copy_data_string(message);
      try {
        var id = session.friend_get_public_key(friend_number);
        Idle.add(() => { session.listener.on_friend_message(id, message_str); return false; });
      } catch (Error e) {
        session.logger.f("friend lookup failed: " + e.message);
      }
    }

    private static void on_friend_status_message_cb(Tox self, uint32 friend_number, uint8[] message, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_friend_status_message_cb");
      var message_str = copy_data_string(message);
      try {
        var id = session.friend_get_public_key(friend_number);
        Idle.add(() => { session.listener.on_friend_status_message_changed(id, message_str); return false; });
      } catch (Error e) {
        session.logger.f("friend lookup failed: " + e.message);
      }
    }

    private static void on_friend_read_receipt_cb(Tox self, uint32 friend_number, uint32 message_id, void* userdata) {
      var session = (ToxSessionImpl) userdata;
      session.logger.d("on_friend_read_receipt_cb");

      try {
        var id = session.friend_get_public_key(friend_number);
        Idle.add(() => { session.listener.on_friend_read_receipt(id, message_id); return false; });
      } catch (Error e) {
        session.logger.f("friend lookup failed: " + e.message);
      }
    }

    private static UserStatus from_connection_status(Connection connection_status) {
      if (connection_status == Connection.NONE) {
        return UserStatus.OFFLINE;
      }
      return UserStatus.ONLINE;
    }

    public virtual void self_get_friend_list_foreach(GetFriendListCallback callback) throws ToxError {
      var friend_numbers = handle.self_get_friend_list();
      for (var i = 0; i < friend_numbers.length; i++) {
        var friend_key = friend_get_public_key(friend_numbers[i]);
        callback(friend_key);
      }
    }

    public virtual void self_set_user_name(string name) {
      var e = ErrSetInfo.OK;
      if (!handle.self_set_name(name, ref e)) {
        logger.e("set_user_name failed: " + e.to_string());
      }
    }

    public virtual uint8[] self_get_address() {
      return handle.self_get_address();
    }

    public virtual void self_set_status_message(string status) {
      var e = ErrSetInfo.OK;
      if (!handle.self_set_status_message(status, ref e)) {
        logger.e("set_user_status failed: " + e.to_string());
      }
    }

    public virtual uint8[] friend_get_public_key(uint32 friend_number) throws ToxError {
      var e = ErrFriendGetPublicKey.OK;
      var ret = handle.friend_get_public_key(friend_number, ref e);
      if (e != ErrFriendGetPublicKey.OK) {
        logger.e("friend_get_public_key failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual string friend_get_name(uint8[] id) throws ToxError {
      var friend_number = get_friend_number(id);
      var e = ErrFriendQuery.OK;
      var ret = handle.friend_get_name(friend_number, ref e);
      if (e != ErrFriendQuery.OK) {
        logger.e("friend_get_name failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual string friend_get_status_message(uint8[] id) throws ToxError {
      var friend_number = get_friend_number(id);
      var e = ErrFriendQuery.OK;
      var ret = handle.friend_get_status_message(friend_number, ref e);
      if (e != ErrFriendQuery.OK) {
        logger.e("friend_get_status_message failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual uint64 friend_get_last_online(uint8[] id) throws ToxError {
      var friend_number = get_friend_number(id);
      var e = ErrFriendGetLastOnline.OK;
      var ret = handle.friend_get_last_online(friend_number, ref e);
      if (e != ErrFriendGetLastOnline.OK) {
        logger.e("friend_get_last_online failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    public virtual void friend_add(uint8[] address, string message) throws ToxError {
      var e = ErrFriendAdd.OK;
      var ret = handle.friend_add(address, message, ref e);
      if (ret == uint32.MAX) {
        logger.i("friend_add failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      var key = friend_get_public_key(ret);
      listener.on_friend_added(key);
    }

    public virtual void friend_delete(uint8[] address) throws ToxError {
      var friend_number = get_friend_number(address);
      var e = ErrFriendDelete.OK;
      if (!handle.friend_delete(friend_number, ref e)) {
        logger.i("friend_delete failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      listener.on_friend_deleted(address);
    }

    public virtual void friend_send_message(uint8[] address, string message) throws ToxError {
      var friend_number = get_friend_number(address);
      var e = ErrFriendSendMessage.OK;
      var ret = handle.friend_send_message(friend_number, MessageType.NORMAL, message, ref e);
      if (ret == uint32.MAX) {
        logger.i("friend_send_message failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      //TODO: handle ret (message id)
      listener.on_friend_message_sent(address, ret, message);
    }

    public virtual void conference_set_title(uint32 id, string title) throws ToxError {
      var e = ErrConferenceTitle.OK;
      handle.conference_set_title(id, title, ref e);
      if (e != ErrConferenceTitle.OK) {
        logger.i("setting conference title failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
    }

    public virtual void conference_new(string title) throws ToxError {
      var e = ErrConferenceNew.OK;
      var ret = handle.conference_new(ref e);
      if (e != ErrConferenceNew.OK) {
        logger.i("creating conference failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      conference_set_title(ret, title);
      listener.on_conference_new(ret, title);
    }

    private uint32 get_friend_number(uint8[] address) throws ToxError {
      var e = ErrFriendByPublicKey.OK;
      var ret = handle.friend_by_public_key(address, ref e);
      if (ret == uint32.MAX) {
        logger.i("get_friend_number failed: " + e.to_string());
        throw new ToxError.GENERIC(e.to_string());
      }
      return ret;
    }

    private void init_dht_nodes() {
      var nodeFactory = new DhtNodeFactory();
      dht_nodes = dht_node_storage.getDhtNodes(nodeFactory);
      logger.d("Items in dht node list: %u".printf(dht_nodes.length()));
      if (dht_nodes.length() == 0) {
        logger.d("Node database empty, populating from static database.");
        var nodeDatabase = new JsonWebDhtNodeDatabase(logger);
        var nodes = nodeDatabase.getDhtNodes(nodeFactory);
        foreach (var node in nodes) {
          dht_node_storage.insertDhtNode(node.pub_key, node.host, node.port, node.is_blocked, node.maintainer, node.location);
        }
        dht_nodes = dht_node_storage.getDhtNodes(nodeFactory);
        if (dht_nodes.length() == 0) {
          logger.e("Node initialisation from static database failed.");
        }
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
