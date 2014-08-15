/*
 *    ToxSession.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
  public enum UserStatus {
    ONLINE,
    AWAY,
    BUSY,
    OFFLINE;
    public string to_string() {
      switch (this) {
        case ONLINE:
          return _("Online");
        case AWAY:
          return _("Away");
        case BUSY:
          return _("Busy");
        case OFFLINE:
          return _("Offline");
        default:
          assert_not_reached();
      }
    }
  }


  // Wrapper class for accessing tox functions threadsafe
  public class ToxSession : Object {

    public const int MAX_NUMBER_OF_CALLS = 1;

    private Tox.Tox handle;
    private ToxAV.ToxAV _toxav_handle;
    public ToxAV.ToxAV toxav_handle {
      get {
        return _toxav_handle;
      }
    }
    private IMessageLog message_log;
    private IContactStorage contact_storage;
    private IDhtNodeStorage dht_node_storage;
    private Sqlite.Database db;

    private DhtNode[] dht_nodes = {};
    private GLib.HashTable<int, Contact> _contacts = new GLib.HashTable<int, Contact>(null, null);
    private GLib.HashTable<int, GroupChat> _groups = new GLib.HashTable<int, GroupChat>(null, null);
    private Thread<int> session_thread = null;
    private bool bootstrapped = false;
    private bool ipv6 = false;
    public bool running {get; private set; default=false; }
    public bool connected { get; private set; default=false; }
    public DhtNode connected_dht_node { get; private set; default=null; }

    // Core functionality signals
    public signal void on_friend_request(Contact c, string message);
    public signal void on_friend_message(Contact c, string message);
    public signal void on_own_message(Contact c, string message);
    public signal void on_own_action(Contact c, string action);
    public signal void on_friend_action(Contact c, string action);
    public signal void on_name_change(Contact c, string? old_name);
    public signal void on_status_message(Contact c, string? old_status);
    public signal void on_user_status(Contact c, uint8 old_status);
    public signal void on_read_receipt(Contact c, uint32 receipt);
    public signal void on_connection_status(Contact c);
    public signal void on_own_connection_status(bool status);
    public signal void on_own_user_status(UserStatus status);
    public signal void on_typing_change(Contact c, bool is_typing);

    // Groupchat signals
    public signal void on_group_invite(Contact c, GroupChat g);
    public signal void on_group_message(GroupChat g, int peernumber, string message);
    public signal void on_group_action(GroupChat g, int peernumber, string action);
    public signal void on_group_peer_changed(GroupChat g, int peernumber, Tox.ChatChange change);

    // File sending callbacks
    public signal void on_file_sendrequest(int friendnumber,uint8 filenumber,uint64 filesize,string filename);
    public signal void on_file_control(int friendnumber, uint8 filenumber,uint8 receive_send,uint8 status,uint8[] data);
    public signal void on_file_data(int friendnumber,uint8 filenumber,uint8[] data);

    // ToxAV callbacks
    public signal void on_av_invite(Contact c);
    public signal void on_av_start(Contact c);
    public signal void on_av_cancel(Contact c);
    public signal void on_av_reject(Contact c);
    public signal void on_av_end(Contact c);
    public signal void on_av_ringing(Contact c);
    public signal void on_av_starting(Contact c);
    public signal void on_av_ending(Contact c);
    public signal void on_av_error(Contact c);
    public signal void on_av_request_timeout(Contact c);
    public signal void on_av_peer_timeout(Contact c);

    public ToxSession( bool ipv6 = false ) {
      this.ipv6 = ipv6;

      Tox.Options options = Tox.Options();

      string[] proxy_strings = {};
      ProxyResolver proxy_resolver = ProxyResolver.get_default();
      try {
        proxy_strings = proxy_resolver.lookup("socks://tox.im");
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error when looking up proxy settings");
      }

      Regex proxy_regex = null;
      try {
         proxy_regex = new GLib.Regex("^(?P<protocol>socks5)://((?P<user>[^:]*)(:(?P<password>.*))?@)?(?P<host>.*):(?P<port>.*)");
      } catch (GLib.Error e) {
        Logger.log(LogLevel.FATAL, "Error creating tox uri regex: " + e.message);
      }

      foreach(unowned string proxy in proxy_strings) {
        if(proxy.has_prefix("socks5:")) {
          Logger.log(LogLevel.INFO, "socks5 proxy found: " + proxy);
          GLib.MatchInfo info = null;
          if(proxy_regex != null && proxy_regex.match(proxy, 0, out info)) {
            string proxy_host = info.fetch_named("host");
            string proxy_port = info.fetch_named("port");
            Logger.log(LogLevel.DEBUG, "parsed host: " + proxy_host + " port: " + proxy_port);
            //FIXME currently commented out since it crashes the core
            //options.proxy_enabled = 1;
            //Memory.copy(options.proxy_address, proxy_host.data, int.min(proxy_host.length, options.proxy_address.length));
            //options.proxy_port = (uint16)int.parse(proxy_port);
          } else {
            Logger.log(LogLevel.INFO, "socks5 proxy does not match regex");
          }
        }
      }

      options.ipv6enabled = ipv6 ? 1 : 0;

      // create handle
      handle = new Tox.Tox(options);

      _toxav_handle = new ToxAV.ToxAV(handle, MAX_NUMBER_OF_CALLS);

      //start local storage
      try {
        SqliteTools.open_db(ResourceFactory.instance.db_filename, out db);

        if(Settings.instance.enable_logging) {
          message_log = new SqliteMessageLog(db);
          message_log.connect_to(this);
        } else {
          message_log = new DummyMessageLog();
        }
        contact_storage = new SqliteContactStorage(db);
        dht_node_storage = new DummyDhtNodeStorage();
        //unfinished, so replaced with dummy storage
        //dht_node_storage = new SqliteDhtNodeStorage(db);
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error opening database: " + e.message);
        message_log = new DummyMessageLog();
        dht_node_storage = new DummyDhtNodeStorage();
      }

      init_dht_nodes();
      init_callbacks();
    }

    // destructor
    ~ToxSession() {
      running = false;
    }

    private void init_dht_nodes() {
      dht_nodes = dht_node_storage.get_dht_nodes();
      if(dht_nodes.length == 0) {
        DummyDhtNodeStorage dummy_storage = new DummyDhtNodeStorage();
        dht_nodes = dummy_storage.get_dht_nodes();
      }
    }

    private void init_callbacks() {
      // setup callbacks
      handle.callback_friend_request(on_friend_request_callback);
      handle.callback_friend_message(on_friend_message_callback);
      handle.callback_friend_action(on_friend_action_callback);
      handle.callback_name_change(on_name_change_callback);
      handle.callback_status_message(on_status_message_callback);
      handle.callback_user_status(on_user_status_callback);
      handle.callback_read_receipt(on_read_receipt_callback);
      handle.callback_connection_status(on_connection_status_callback);
      handle.callback_typing_change(on_typing_change_callback);

      // Groupchat callbacks
      handle.callback_group_invite(on_group_invite_callback);
      handle.callback_group_message(on_group_message_callback);
      handle.callback_group_action(on_group_action_callback);
      handle.callback_group_namelist_change(on_group_namelist_change_callback);

      // File sending callbacks
      handle.callback_file_send_request(on_file_sendrequest_callback);
      handle.callback_file_control(on_file_control_callback);
      handle.callback_file_data(on_file_data_callback);

      // ToxAV callbacks
      _toxav_handle.register_callstate_callback(on_av_invite_callback         , ToxAV.CallbackID.INVITE);
      _toxav_handle.register_callstate_callback(on_av_start_callback          , ToxAV.CallbackID.START);
      _toxav_handle.register_callstate_callback(on_av_cancel_callback         , ToxAV.CallbackID.CANCEL);
      _toxav_handle.register_callstate_callback(on_av_reject_callback         , ToxAV.CallbackID.REJECT);
      _toxav_handle.register_callstate_callback(on_av_end_callback            , ToxAV.CallbackID.END);
      _toxav_handle.register_callstate_callback(on_av_ringing_callback        , ToxAV.CallbackID.RINGING);
      _toxav_handle.register_callstate_callback(on_av_starting_callback       , ToxAV.CallbackID.STARTING);
      _toxav_handle.register_callstate_callback(on_av_ending_callback         , ToxAV.CallbackID.ENDING);
      _toxav_handle.register_callstate_callback(on_av_request_timeout_callback, ToxAV.CallbackID.REQUEST_TIMEOUT);
      _toxav_handle.register_callstate_callback(on_av_peer_timeout_callback   , ToxAV.CallbackID.PEER_TIMEOUT);
      _toxav_handle.register_callstate_callback(on_av_media_change            , ToxAV.CallbackID.MEDIA_CHANGE);
    }

    private void init_contact_list() {
      int[] friend_numbers;
      uint ret = 0;
      uint count_friendlist = 0;
      lock(handle) {
        count_friendlist = handle.count_friendlist();
        friend_numbers = new int[count_friendlist];
        ret = handle.get_friendlist(friend_numbers);
      }
      if(ret != count_friendlist)
        return;
      _contacts.remove_all();
      _groups.remove_all();
      for(int i = 0; i < friend_numbers.length; ++i) {
        int friend_id = friend_numbers[i];
        uint8[] friend_key = get_client_id(friend_id);
        Contact c = new Contact(friend_key, friend_id);
        c.name = get_name(friend_id);
        c.status_message = get_status_message(friend_id);
        uint64 last_seen = get_last_online(friend_id);
        if(last_seen > 0) {
          c.last_seen = new DateTime.from_unix_local((int64)last_seen);
        }
        contact_storage.load_contact_data(c);
        _contacts.set(friend_id, c);
      };
    }

    ////////////////////////////// Callbacks /////////////////////////////////////////
    private void on_friend_request_callback(Tox.Tox tox, uint8[] public_key, uint8[] data) 
      requires (public_key != null)
      requires (data != null)
    {
      string message = Tools.uint8_to_nullterm_string(data);
      uint8[] public_key_clone = new uint8[Tox.CLIENT_ID_SIZE];
      Memory.copy(public_key_clone, public_key, Tox.CLIENT_ID_SIZE);
      Idle.add(() => {
        Contact contact = new Contact(public_key_clone, -1);
        on_friend_request(contact, message);
        return false;
      });
    }

    private void on_friend_message_callback(Tox.Tox tox, int friend_number, uint8[] message)
      requires(message != null)
    {
      string message_string = Tools.uint8_to_nullterm_string(message);
      Idle.add(() => {
        on_friend_message(_contacts.get(friend_number), message_string);
        return false;
      });
    }

    private void on_friend_action_callback(Tox.Tox tox, int32 friend_number, uint8[] action)
      requires(action != null)
    {
      string action_string = Tools.uint8_to_nullterm_string(action);
      Idle.add(() => {
        on_friend_action(_contacts.get(friend_number), action_string);
        return false;
      });
    }

    private void on_name_change_callback(Tox.Tox tox, int32 friend_number, uint8[] new_name)
      requires(new_name != null)
    {
      string new_name_dup = Tools.uint8_to_nullterm_string(new_name);
      Idle.add(() => {
        Contact contact = _contacts.get(friend_number);
        string old_name = contact.name;
        contact.name = new_name_dup;
        on_name_change(contact, old_name);
        return false;
      });
    }

    private void on_status_message_callback(Tox.Tox tox, int32 friend_number, uint8[] status)
      requires(status != null)
    {
      string status_dup = Tools.uint8_to_nullterm_string(status);
      Idle.add(() => {
        Contact contact = _contacts.get(friend_number);
        string old_status = contact.status_message;
        contact.status_message = status_dup;
        on_status_message(contact, old_status);
        return false;
      });
    }

    private void on_user_status_callback(Tox.Tox tox, int32 friend_number, uint8 user_status) {
      Idle.add(() => {
        Contact contact = _contacts.get(friend_number);
        uint8 old_status = contact.user_status;
        contact.user_status = user_status;
        on_user_status(contact, old_status);
        return false;
      });
    }

    private void on_read_receipt_callback(Tox.Tox tox, int32 friend_number, uint32 receipt) {
      Idle.add(() => {
        on_read_receipt(_contacts.get(friend_number), receipt);
        return false;
      });
    }

    private void on_connection_status_callback(Tox.Tox tox, int32 friend_number, uint8 status) {
      Idle.add(() => { 
        Contact contact = _contacts.get(friend_number);
        contact.online = (status != 0);
        contact.last_seen = new DateTime.now_local();

        if(status == 0) {
          contact.get_filetransfers().for_each((id, ft) => {
              if(ft.status == FileTransferStatus.PENDING || ft.status == FileTransferStatus.IN_PROGRESS || ft.status == FileTransferStatus.PAUSED) {
                ft.status = (ft.direction == FileTransferDirection.INCOMING) ? FileTransferStatus.RECEIVING_BROKEN : FileTransferStatus.SENDING_BROKEN;
              }
            });
        } else {
          contact.get_filetransfers().for_each((id, ft) => {
              if(ft.status == FileTransferStatus.RECEIVING_BROKEN) {
                lock(handle) {
                  uint64[] data = {ft.bytes_processed};
                  handle.file_send_control(friend_number, 1, id, Tox.FileControlStatus.RESUME_BROKEN, (uint8[])data);
                }
              }
            });
        }

        on_connection_status(contact);
        return false;
      });
    }

    private void on_typing_change_callback(Tox.Tox tox, int32 friend_number, uint8 is_typing) {
      Contact contact = _contacts.get(friend_number);
      contact.is_typing = is_typing != 0;
      Idle.add(() => {
        on_typing_change(contact, is_typing != 0);
        return false;
      });
    }

    // Group chat callbacks
    private void on_group_invite_callback(Tox.Tox tox, int32 friendnumber, uint8[] group_public_key)
      requires(group_public_key != null)
    {
      uint8[] group_public_key_clone = new uint8[Tox.CLIENT_ID_SIZE];
      Memory.copy(group_public_key_clone, group_public_key, Tox.CLIENT_ID_SIZE);
      Idle.add(() => {
        on_group_invite(_contacts.get(friendnumber), new GroupChat(group_public_key_clone));
        return false;
      });
    }

    private void on_group_message_callback(Tox.Tox tox, int groupnumber, int friendgroupnumber, uint8[] message)
      requires(message != null)
    {
      string message_string = Tools.uint8_to_nullterm_string(message);
      Idle.add(() => {
        on_group_message(_groups.get(groupnumber), friendgroupnumber, message_string);
        return false;
      });
    }

    private void on_group_action_callback(Tox.Tox tox, int groupnumber, int friendgroupnumber, uint8[] action)
      requires(action != null)
    {
      string action_string = Tools.uint8_to_nullterm_string(action);
      Idle.add(() => {
        on_group_action(_groups.get(groupnumber), friendgroupnumber, action_string);
        return false;
      });
    }

    private void on_group_namelist_change_callback(Tox.Tox tox, int groupnumber, int peernumber, Tox.ChatChange change) {
/*
      string chat_change_string = "";
      if(change == Tox.ChatChange.PEER_ADD) {
        chat_change_string = "ADD";
      } else if (change == Tox.ChatChange.PEER_DEL) {
        chat_change_string = "DEL";
      } else {
        chat_change_string = "NAME";
      }
      stdout.printf(_("[gnc] <%s> [%i] #%i\n"), chat_change_string, peernumber, groupnumber);
*/
      Idle.add(() => {
        GroupChat g = _groups.get(groupnumber);
        if(change == Tox.ChatChange.PEER_ADD) {
          GroupChatContact c = new GroupChatContact(peernumber);
          g.peers.set(peernumber, c);
          g.peer_count++;
        } else if (change == Tox.ChatChange.PEER_DEL) {
          if(!g.peers.remove(peernumber)) {
            Logger.log(LogLevel.ERROR, "Could not remove peer [%i] from groupchat #%i (no such peer)".printf(peernumber, groupnumber));
          }
          g.peer_count--;
        } else { // change == PEER_NAME
          g.peers.get(peernumber).name = group_peername(g, peernumber);
        }
        on_group_peer_changed(g, peernumber, change);
        return false;
      });
    }

    //File sending callbacks
    private void on_file_sendrequest_callback(Tox.Tox tox, int32 friendnumber, uint8 filenumber, uint64 filesize, uint8[] filename)
      requires(filename != null)
    {
      string filename_dup = Tools.uint8_to_nullterm_string(filename);
      Idle.add(() => {
        string filename_str = File.new_for_path(filename_dup).get_basename();
        on_file_sendrequest(friendnumber, filenumber, filesize, filename_str);
        return false;
      });
    }

    private void on_file_control_callback(Tox.Tox tox, int32 friendnumber, uint8 receive_send, uint8 filenumber, uint8 status, uint8[] data) {
      uint8[] data_clone = new uint8[data.length];
      Memory.copy(data_clone, data, data.length);
      Idle.add(() => {
        on_file_control(friendnumber, filenumber, receive_send, status, data_clone);
        return false;
      });
    }

    private void on_file_data_callback(Tox.Tox tox, int32 friendnumber, uint8 filenumber, uint8[] data)
      requires(data != null)
    {
      uint8[] data_clone = new uint8[data.length];
      Memory.copy(data_clone, data, data.length);
      Idle.add(() => {
        on_file_data(friendnumber, filenumber, data_clone);
        return false;
      });
    }

    ////////////////////////// Misc functions //////////////////////////////////

    public void save_extended_contact_data(Contact c) {
      contact_storage.save_contact_data(c);
    }

    public void load_extended_contact_data(Contact c) {
      contact_storage.load_contact_data(c);
    }

    ///////////////////////// Wrapper functions ////////////////////////////////

    // Add a friend, returns Tox.FriendAddError on error and friend_number on success
    public Tox.FriendAddError add_friend(Contact c, string message)
      requires(c != null)
      requires(c.public_key.length == Tox.FRIEND_ADDRESS_SIZE)
      requires(message != null)
    {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      lock(handle) {
        ret = handle.add_friend(c.public_key, message.data);
      }

      if(ret < 0)
        return ret;
      uint8[] client_key = new uint8[Tox.CLIENT_ID_SIZE];
      Memory.copy(client_key, c.public_key, Tox.CLIENT_ID_SIZE);
      c.public_key = client_key;
      c.friend_id = (int)ret;
      _contacts.set((int)ret, c);
      return ret;
    }

    public int add_friend_norequest(Contact c)
      requires(c != null)
    {
      int ret = -1;

      if(c.public_key.length != Tox.CLIENT_ID_SIZE)
        return ret;

      lock(handle) {
        ret = handle.add_friend_norequest(c.public_key);
      }
      if(ret >= 0) {
        c.friend_id = ret;
        _contacts.set(ret, c);
      }
      return ret;
    }

    public bool join_groupchat(Contact c, GroupChat g)
      requires(c != null)
      requires(g != null)
    {
      int ret = -1;
      lock(handle) {
        ret = handle.join_groupchat(c.friend_id, g.public_key);
      }
      if(ret < 0) {
        return false;
      }
      g.group_id = ret;
      _groups.set(ret, g);
      return true;
    }

    public GroupChat? add_groupchat() {
      int ret = -1;
      lock(handle) {
        ret = handle.add_groupchat();
      }
      if(ret < 0)
        return null;
      GroupChat g = new GroupChat.from_id(ret);
      _groups.set(ret, g);
      return g;
    }

    public bool del_friend(Contact c)
      requires(c != null)
    {
      int ret = -1;
      lock(handle) {
        ret = handle.del_friend(c.friend_id);
      }
      if(ret == 0) {
        _contacts.remove(c.friend_id);
      }
      return ret == 0;
    }

    public bool del_groupchat(GroupChat g)
      requires(g != null)
    {
      int ret = -1;
      lock(handle) {
        ret = handle.del_groupchat(g.group_id);
      }
      if(ret == 0) {
        _groups.remove(g.group_id);
      }
      return ret == 0;
    }

    public int invite_friend(Contact c, GroupChat g) {
      lock(handle){
        return handle.invite_friend(c.friend_id, g.group_id);
      }
    }

    public string group_peername(GroupChat g, int peernumber)
      requires(g != null)
    {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH + 1];
      lock(handle) {
        handle.group_peername(g.group_id, peernumber, buf);
      }
      return (string)buf;
    }

    public int group_number_peers(GroupChat g)
      requires(g != null)
    {
      lock(handle) {
        return handle.group_number_peers(g.group_id);
      }
    }

    // Set user status, returns true on success
    public bool set_user_status(UserStatus user_status) {
      int ret = -1;
      lock(handle) {
        ret = handle.set_user_status((Tox.UserStatus)user_status);
      }
      if(ret != 0)
        return false;
      on_own_user_status(user_status);
      return true;
    }

    // Set user statusmessage, returns true on success
    public bool set_status_message(string message)
      requires(message != null)
    {
      int ret = -1;
      lock(handle) {
        ret = handle.set_status_message(message.data);
      }
      return ret == 0;
    }

    public string get_self_status_message() {
      uint8[] buf = new uint8[Tox.MAX_STATUSMESSAGE_LENGTH + 1];
      int ret = 0;
      lock(handle) {
        ret = handle.get_self_status_message(buf);
      }
      return (string)buf;
    }

    // get personal id
    public uint8[] get_address() {
      uint8[] buf = new uint8[Tox.FRIEND_ADDRESS_SIZE];
      lock(handle) {
        handle.get_address(buf);
      }
      return buf;
    }

    // set username
    public bool set_name(string name)
      requires(name != null)
    {
      int ret = -1;
      lock(handle) {
        ret = handle.set_name(name.data);
      }
      return ret == 0;
    }

    public string get_self_name() {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH + 1];
      int ret = -1;
      lock(handle) {
        ret = handle.get_self_name(buf);
      }
      return (string)buf;
    }

    public uint8[] get_client_id(int friend_id) {
      uint8[] buf = new uint8[Tox.CLIENT_ID_SIZE];
      int ret = -1;
      lock(handle) {
        ret = handle.get_client_id(friend_id, buf);
      }
      return (ret != 0) ? null : buf;
    }

    public string? get_name(int friend_number) {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH + 1];
      int ret = -1;
      lock(handle) {
        ret = handle.get_name(friend_number, buf);
      }
      return (ret < 0) ? null: (string)buf;
    }

    public string get_status_message(int friend_number) {
      int size = 0;
      int ret = 0;
      uint8 [] buf;
      lock(handle) {
        size = handle.get_status_message_size(friend_number);
        buf = new uint8[size + 1];
        ret = handle.get_status_message(friend_number, buf);
      }
      return (string)buf;
    }

    public uint64 get_last_online(int friendnumber) {
      lock(handle) {
        return handle.get_last_online(friendnumber);
      }
    }

    public uint32 send_message(int friend_number, string message)
      requires(message != null)
    {
      unowned string message_ptr = message;
      lock(handle) {
        while(message_ptr.length > Tox.MAX_MESSAGE_LENGTH) {
          int offset = Tox.MAX_MESSAGE_LENGTH - 1;
          unichar c;
          message_ptr.get_prev_char(ref offset, out c);
          handle.send_message(friend_number, message_ptr.data, offset);
          message_ptr = message_ptr.offset(offset);
        }
        return handle.send_message(friend_number, message_ptr.data, message_ptr.length);
      }
    }

    public uint32 send_action(int friend_number, string action)
      requires(action != null)
    {
      lock(handle) {
        return handle.send_action(friend_number, action.data);
      }
    }

    public uint32 group_message_send(int groupnumber, string message)
      requires(message != null)
    {
      lock(handle) {
        return handle.group_message_send(groupnumber, message.data);
      }
    }

    public uint32 group_action_send(int groupnumber, string action)
      requires(action != null)
    {
      lock(handle) {
        return handle.group_action_send(groupnumber, action.data);
      }
    }

    public bool set_user_is_typing(int friend_number, bool is_typing) {
      lock(handle) {
        return handle.set_user_is_typing(friend_number, is_typing ? 1 : 0) == 0;
      }
    }

    public unowned GLib.HashTable<int, Contact> get_contact_list() {
      return _contacts;
    }

    public unowned GLib.HashTable<int, GroupChat> get_groupchats() {
      return _groups;
    }

    public uint8 send_file_request(int friend_number, uint64 file_size, string filename)
      requires(filename != null)
    {
      lock(handle) {
        return (uint8) handle.new_file_sender(friend_number, file_size, filename.data);
      }
    }

    public void accept_file (int friendnumber, uint8 filenumber) {
      lock(handle) {
        handle.file_send_control(friendnumber, 1, filenumber, Tox.FileControlStatus.ACCEPT, null);
      }
    }

    public void accept_file_resume (int friendnumber, uint8 filenumber) {
      lock(handle) {
        handle.file_send_control(friendnumber, 0, filenumber, Tox.FileControlStatus.ACCEPT, null);
      }
    }

    public void reject_file (int friendnumber, uint8 filenumber) {
      lock(handle) {
        handle.file_send_control(friendnumber, 1, filenumber, Tox.FileControlStatus.KILL, null);
      }
    }

    public void send_filetransfer_end (int friendnumber, uint8 filenumber) {
      lock(handle) {    
        handle.file_send_control(friendnumber, 0, filenumber, Tox.FileControlStatus.FINISHED, null);
      }
    }

    public int send_file_data(int friendnumber, uint8 filenumber, uint8[] filedata) {
      lock(handle) {
        return handle.file_send_data(friendnumber, filenumber, filedata);
      }
    }

    public int get_recommended_data_size(int friendnumber) {
      lock(handle) {
        return handle.file_data_size(friendnumber);
      }
    }

    public uint64 get_remaining_file_data(int friendnumber,uint8 filenumber,uint8 send_receive) {
      lock(handle) {
        return handle.file_data_remaining(friendnumber, filenumber, send_receive);
      }
    }

    ////////////////////////////// Thread related operations /////////////////////////

    // Background thread main function
    private int run() {
      Logger.log(LogLevel.INFO, "Background thread started.");

      if(!bootstrapped) {
        Logger.log(LogLevel.INFO, "Connecting to DHT Nodes:");
        for(int i = 0; i < dht_nodes.length; ++i) {
          // skip ipv6 nodes if we don't support them
          if(dht_nodes[i].is_ipv6 && !ipv6)
            continue;
          Logger.log(LogLevel.INFO, "  " + dht_nodes[i].to_string());
          lock(handle) {
            handle.bootstrap_from_address(
              dht_nodes[i].host,
              dht_nodes[i].port,
              dht_nodes[i].pub_key
            );
          }
        }
        bootstrapped = true;
      }

      bool new_status = false;
      while(running) {
        lock(handle) {
          new_status = (handle.isconnected() != 0);
        }
        if(new_status && !connected) {
          connected = true;
          connected_dht_node = dht_nodes[0];
          Idle.add(() => { on_own_connection_status(true); return false; });
        } else if(!new_status && connected) {
          connected = false;
          Idle.add(() => { on_own_connection_status(false); return false; });
        }
        lock(handle) {
          handle.do();
        }
        Thread.usleep(handle.do_interval() * 1000);
      }
      Logger.log(LogLevel.INFO, "Background thread stopped.");
      return 0;
    }

    // Start the background thread
    public void start() {
      if(running)
        return;
      running = true;
      session_thread = new GLib.Thread<int>("toxbgthread", this.run);
    }

    // Stop background thread
    public void stop() {
      running = false;
      connected = false;
      on_own_connection_status(false);
    }

    // Wait for background thread to finish
    public int join() {
      if(session_thread != null)
        return session_thread.join();
      return -1;
    }

    ////////////////////////////// Load/Save of messenger data /////////////////////////
    public void load_from_file(string filename) throws IOError, Error 
      requires(filename != null)
    {
      File f = File.new_for_path(filename);
      if(!f.query_exists())
        throw new IOError.NOT_FOUND(_("File \"%d\" does not exist.").printf(filename));
      FileInfo file_info = f.query_info("*", FileQueryInfoFlags.NONE);
      int64 size = file_info.get_size();
      var data_stream = new DataInputStream(f.read());
      uint8[] buf = new uint8 [size];

      if(data_stream.read(buf) != size)
        throw new IOError.FAILED(_("Error while reading from stream."));
      int ret = -1;
      lock(handle) {
        ret = handle.load(buf);
      }
      if(ret != 0)
        throw new IOError.FAILED(_("Error while loading messenger data."));
      init_contact_list();
      message_log.myId = Tools.bin_to_hexstring(get_address());
    }

    // Save messenger data from file
    public void save_to_file(string filename) throws IOError, Error
      requires(filename != null)
    {
      File file = File.new_for_path(filename);
      if(!file.query_exists()) {
        Tools.create_path_for_file(filename, 0755);
      }
      DataOutputStream os = new DataOutputStream(file.replace(null, false, FileCreateFlags.PRIVATE | FileCreateFlags.REPLACE_DESTINATION ));

      uint32 size = 0;
      uint8[] buf;

      lock(handle) {
        size = handle.size();
        buf = new uint8 [size];
        handle.save(buf);
      }

      assert(size != 0);

      if(os.write(buf) != size)
        throw new IOError.FAILED("Error while writing to stream.");
    }

    public GLib.List<Message> load_history_for_contact(Contact c)
      requires(c != null)
    {
      return message_log.retrieve_history(c);
    }

    // TOXAV functions
    public void start_audio_call(Contact c) {
      Logger.log(LogLevel.DEBUG, "starting audio call with " + c.name);
      int call_index = 0;
      c.video = false;
      ToxAV.CodecSettings settings = ToxAV.DefaultCodecSettings;
      settings.call_type = ToxAV.CallType.AUDIO;
      
      ToxAV.AV_Error ret = _toxav_handle.call(ref call_index, c.friend_id, ref settings, 10);

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.ERROR, "toxav_call returned an error: %s".printf(ret.to_string()));
      } else {
        c.call_index = call_index;
      }
    }

    public void start_video_call(Contact c) {
      Logger.log(LogLevel.DEBUG, "starting video call with " + c.name);
      int call_index = 0;
      c.video = true;
      ToxAV.CodecSettings settings = ToxAV.DefaultCodecSettings;
      settings.call_type = ToxAV.CallType.VIDEO;

      ToxAV.AV_Error ret = _toxav_handle.call(ref call_index, c.friend_id, ref settings, 10);

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.ERROR, "toxav_call returned an error: %s".printf(ret.to_string()));
      } else {
        c.call_index = call_index;
      }
    }

    public void answer_call(Contact c) {
      Logger.log(LogLevel.DEBUG, "answering call %i".printf(c.call_index));
      ToxAV.CodecSettings settings = ToxAV.DefaultCodecSettings;
      settings.call_type = c.video ? ToxAV.CallType.VIDEO : ToxAV.CallType.AUDIO;
      ToxAV.AV_Error ret = _toxav_handle.answer(c.call_index, ref settings);

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.ERROR, "toxav_answer returned an error: %s".printf(ret.to_string()));
      }
    }

    public void reject_call(Contact c) {
      ToxAV.AV_Error ret = _toxav_handle.reject(c.call_index, "no");

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.ERROR, "toxav_reject returned an error: %s".printf(ret.to_string()));
      }
    }

    public void hangup_call(Contact c) {
      ToxAV.AV_Error ret = _toxav_handle.hangup(c.call_index);

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.ERROR, "toxav_hangup returned an error: %s".printf(ret.to_string()));
      }
    }

    public void cancel_call(Contact c) {
      ToxAV.AV_Error ret = _toxav_handle.cancel(c.call_index, ToxAV.CallType.AUDIO, "do not want");
      c.call_state = CallState.ENDED;

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.ERROR, "toxav_cancel returned an error: %s".printf(ret.to_string()));
      }
    }

    // TOXAV callbacks
    private void on_av_invite_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_invite_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      ToxAV.CodecSettings settings = ToxAV.CodecSettings();
      _toxav_handle.get_peer_csettings(call_index, 0, ref settings);
      bool video = (settings.call_type == ToxAV.CallType.VIDEO);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.video = video;
        c.call_index = call_index;
        c.call_state = CallState.CALLING;
        on_av_invite(c);
        return false;
      });
    }
    private void on_av_start_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_start_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.STARTED;
        on_av_start(c);
        return false;
      });
    }
    private void on_av_cancel_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_cancel_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.ENDED;
        on_av_cancel(c);
        return false;
      });
    }
    private void on_av_reject_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_reject_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.ENDED;
        on_av_reject(c);
        return false;
      });
    }
    private void on_av_end_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_end_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.ENDED;
        on_av_end(c);
        return false;
      });
    }
    private void on_av_ringing_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_ringing_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_index = call_index;
        c.call_state = CallState.RINGING;
        on_av_ringing(c);
        return false;
      });
    }
    private void on_av_starting_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_starting_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.STARTED;
        on_av_starting(c);
        return false;
      });
    }
    private void on_av_ending_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_ending_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.ENDED;
        on_av_ending(c);
        return false;
      });
    }
    private void on_av_request_timeout_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_request_timeout_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.ENDED;
        on_av_request_timeout(c);
        return false;
      });
    }
    private void on_av_peer_timeout_callback(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_peer_timeout_callback %i".printf(call_index));
      int friend_id = _toxav_handle.get_peer_id(call_index, 0);
      Idle.add(() => {
        Contact c = _contacts.get(friend_id);
        c.call_state = CallState.ENDED;
        on_av_peer_timeout(c);
        return false;
      });
    }
    private void on_av_media_change(ToxAV.ToxAV av, int32 call_index) {
      Logger.log(LogLevel.DEBUG, "on_av_media_change_callback %i".printf(call_index));
    }
  }
}
