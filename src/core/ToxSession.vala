/*
 *    Copyright (C) 2013 Venom authors and contributors
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
          return "Online";
        case AWAY:
          return "Away";
        case BUSY:
          return "Busy";
        case OFFLINE:
          return "Offline";
        default:
          assert_not_reached();
      }
    }
  }

  // Wrapper class for accessing tox functions threadsafe
  public class ToxSession : Object {
    private Tox.Tox handle;
    private DhtServer[] dht_servers = {};
    private Gee.HashMap<int, Contact> _contacts = new Gee.HashMap<int, Contact>();
    private Gee.HashMap<int, GroupChat> _groups = new Gee.HashMap<int, GroupChat>();
    private Gee.HashMap<uint8, FileTransfer> _file_transfers = new Gee.HashMap<uint8,FileTransfer>();
#if GLIB_2_32
    private Thread<int> session_thread = null;
#else
    private unowned Thread<int> session_thread = null;
#endif
    private bool bootstrapped = false;
    private bool ipv6 = false;
    public bool running {get; private set; default=false; }
    public bool connected { get; private set; default=false; }
    public DhtServer connected_dht_server { get; private set; default=null; }

    // Core functionality signals
    public signal void on_friend_request(Contact c, string message);
    public signal void on_friend_message(Contact c, string message);
    public signal void on_friend_action(Contact c, string action);
    public signal void on_name_change(Contact c, string? old_name);
    public signal void on_status_message(Contact c, string? old_status);
    public signal void on_user_status(Contact c, int old_status);
    public signal void on_read_receipt(Contact c, uint32 receipt);
    public signal void on_connection_status(Contact c);
    public signal void on_own_connection_status(bool status);
    public signal void on_own_user_status(UserStatus status);

    // Groupchat signals
    public signal void on_group_invite(Contact c, GroupChat g);
    public signal void on_group_message(GroupChat g, int friendgroupnumber, string message);

    // File sending callbacks
    
    public signal void on_file_sendrequest(int friendnumber,uint8 filenumber,uint64 filesize,string filename);
    public signal void on_file_control(int friendnumber, uint8 filenumber,uint8 receive_send,uint8 status,uint8[] data);
    public signal void on_file_data(int friendnumber,uint8 filenumber,uint8[] data);
    

    public ToxSession( bool ipv6 = false ) {
      this.ipv6 = ipv6;

      // create handle
      handle = new Tox.Tox( ipv6 ? 1 : 0);

      // Add one default dht server
      dht_servers += new DhtServer.with_args(
        "54.215.145.71",
        "6EDDEE2188EF579303C0766B4796DCBA89C93058B6032FEA51593DCD42FB746C"
      );
      dht_servers += new DhtServer.with_args(
        "66.175.223.88",
        "B24E2FB924AE66D023FE1E42A2EE3B432010206F751A2FFD3E297383ACF1572E"
      );
      dht_servers += new DhtServer.with_args(
        "192.184.81.118",
        "5CD7EB176C19A2FD840406CD56177BB8E75587BB366F7BB3004B19E3EDC04143"
      );
      dht_servers += new DhtServer.with_args(
        "198.46.136.167",
        "F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67"
      );
      dht_servers += new DhtServer.with_args(
        "198.46.136.167",
        "728925473812C7AAC482BE7250BCCAD0B8CB9F737BF3D42ABD34459C1768F854"
      );
      dht_servers += new DhtServer.with_args(
        "95.47.140.214",
        "F4BF7C5A9D0EF4CB684090C38DE937FAE1612021F21FEA4DCBFAC6AAFEF58E68"
      );

      // setup callbacks
      handle.callback_friend_request(this.on_friend_request_callback);
      handle.callback_friend_message(this.on_friend_message_callback);
      handle.callback_friend_action(this.on_friend_action_callback);
      handle.callback_name_change(this.on_name_change_callback);
      handle.callback_status_message(this.on_status_message_callback);
      handle.callback_user_status(this.on_user_status_callback);
      handle.callback_read_receipt(this.on_read_receipt_callback);
      handle.callback_connection_status(this.on_connection_status_callback);

      // Groupchat callbacks
      handle.callback_group_invite(this.on_group_invite_callback);
      handle.callback_group_message(this.on_group_message_callback);

      // File sending callbacks
      handle.callback_file_send_request(this.on_file_sendrequest_callback);
      handle.callback_file_control(this.on_file_control_callback);
      handle.callback_file_data(this.on_file_data_callback);
    }

    // destructor
    ~ToxSession() {
      running = false;
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
      _contacts.clear();
      _groups.clear();
      for(int i = 0; i < friend_numbers.length; ++i) {
        int friend_id = friend_numbers[i];
        uint8[] friend_key = getclient_id(friend_id);
        Contact c = new Contact(friend_key, friend_id);
        c.name = getname(friend_id);
        c.status_message = get_statusmessage(friend_id);
        _contacts.set(friend_id, c);
      };
    }

    ////////////////////////////// Callbacks /////////////////////////////////////////
    private void on_friend_request_callback(uint8[] public_key, uint8[] data) {
      if(public_key == null) {
        stderr.printf("Public key was null in friendrequest!\n");
        return;
      }
      string message = ((string)data).dup(); //FIXME string may be copied two times here, check
      uint8[] public_key_clone = Tools.clone(public_key, Tox.CLIENT_ID_SIZE);
      Contact contact = new Contact(public_key_clone, -1);
      Idle.add(() => { on_friend_request(contact, message); return false; });
    }

    private void on_friend_message_callback(Tox.Tox tox, int friend_number, uint8[] message) {
      string message_string = ((string)message).dup();
      Idle.add(() => { on_friend_message(_contacts.get(friend_number), message_string); return false; });
    }

    private void on_friend_action_callback(Tox.Tox tox, int friend_number, uint8[] action) {
      string action_string = ((string)action).dup();
      Idle.add(() => { on_friend_action(_contacts.get(friend_number), action_string); return false; });
    }

    private void on_name_change_callback(Tox.Tox tox, int friend_number, uint8[] new_name) {
      Contact contact = _contacts.get(friend_number);
      string old_name = contact.name;
      contact.name = ((string)new_name).dup();
      Idle.add(() => { on_name_change(contact, old_name); return false; });
    }

    private void on_status_message_callback(Tox.Tox tox, int friend_number, uint8[] status) {
      Contact contact = _contacts.get(friend_number);
      string old_status = contact.status_message;
      contact.status_message = ((string)status).dup();
      Idle.add(() => { on_status_message(contact, old_status); return false; });
    }

    private void on_user_status_callback(Tox.Tox tox, int friend_number, Tox.UserStatus user_status) {
      Contact contact = _contacts.get(friend_number);
      int old_status = contact.user_status;
      contact.user_status = user_status;
      Idle.add(() => { on_user_status(contact, old_status); return false; });
    }

    private void on_read_receipt_callback(Tox.Tox tox, int friend_number, uint32 receipt) {
      Idle.add(() => { on_read_receipt(_contacts.get(friend_number), receipt); return false; });
    }

    private void on_connection_status_callback(Tox.Tox tox, int friend_number, uint8 status) {
      Contact contact = _contacts.get(friend_number);
      contact.online = (status != 0);
      Idle.add(() => { on_connection_status(contact); return false; });
    }

    // Group chat callbacks
    private void on_group_invite_callback(Tox.Tox tox, int friendnumber, uint8[] group_public_key) {
      uint8[] public_key_clone = Tools.clone(group_public_key, Tox.CLIENT_ID_SIZE);
      GroupChat group_contact = new GroupChat(public_key_clone);
      Idle.add(() => { on_group_invite(_contacts.get(friendnumber), group_contact); return false; });
    }

    private void on_group_message_callback(Tox.Tox tox, int groupnumber, int friendgroupnumber, uint8[] message) {
      string message_string = ((string)message).dup();
      Idle.add(() => { on_group_message(_groups.get(groupnumber), friendgroupnumber, message_string); return false; });
    }

    //File sending callbacks
    private void on_file_sendrequest_callback(Tox.Tox tox, int friendnumber, uint8 filenumber, uint64 filesize, uint8[] filename) {
      Idle.add(() => { on_file_sendrequest(friendnumber,filenumber,filesize, ((string)filename).dup()); return false; });
    }

    private void on_file_control_callback(Tox.Tox tox, int friendnumber, uint8 receive_send, uint8 filenumber, uint8 status, uint8[] data) {
      uint8[] data_clone = Tools.clone(data, data.length);
      Idle.add(() => { on_file_control(friendnumber,filenumber,receive_send,status,data_clone); return false; }); 
    }

    private void on_file_data_callback(Tox.Tox tox, int friendnumber, uint8 filenumber, uint8[] data) {
      uint8[] data_clone = Tools.clone(data, data.length);
      Idle.add(() => { on_file_data(friendnumber,filenumber,data_clone); return false; });
    }

    ////////////////////////////// Wrapper functions ////////////////////////////////

    // Add a friend, returns Tox.FriendAddError on error and friend_number on success
    public Tox.FriendAddError addfriend(Contact c, string message) {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      if(c.public_key.length != Tox.FRIEND_ADDRESS_SIZE)
        return ret;

      uint8[] data = Tools.string_to_nullterm_uint(message);

      lock(handle) {
        ret = handle.add_friend(c.public_key, data);
      }

      if(ret < 0)
        return ret;
      c.public_key = Tools.clone(c.public_key, Tox.CLIENT_ID_SIZE);
      c.friend_id = (int)ret;
      _contacts.set((int)ret, c);
      return ret;
    }

    public Tox.FriendAddError addfriend_norequest(Contact c) {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      if(c.public_key.length != Tox.CLIENT_ID_SIZE)
        return ret;

      lock(handle) {
        ret = handle.add_friend_norequest(c.public_key);
      }
      if(ret < 0)
        return ret;
      c.friend_id = (int)ret;
      _contacts.set((int)ret, c);
      return ret;
    }

    public bool join_groupchat(Contact c, GroupChat g) {
      int ret = -1;
      lock(handle) {
        ret = handle.join_groupchat(c.friend_id, g.public_key);
      }
      if(ret < 0)
        return false;
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

    public bool delfriend(Contact c) {
      int ret = -1;
      lock(handle) {
        ret = handle.del_friend(c.friend_id);
      }
      if(ret == 0) {
        _contacts.unset(c.friend_id);
      }
      return ret == 0;
    }

    // Set user status, returns true on success
    public bool set_userstatus(UserStatus user_status) {
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
    public bool set_statusmessage(string message) {
      int ret = -1;
      uint8[] buf = Tools.string_to_nullterm_uint(message);
      lock(handle) {
        ret = handle.set_status_message(buf);
      }
      return ret == 0;
    }

    public string get_self_statusmessage() {
      uint8[] buf = new uint8[Tox.MAX_STATUSMESSAGE_LENGTH];
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
    public bool setname(string name) {
      uint8[] buf = Tools.string_to_nullterm_uint(name);
      int ret = -1;
      lock(handle) {
        ret = handle.set_name(buf);
      }
      return ret == 0;
    }

    public string getselfname() {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH];
      int ret = -1;
      lock(handle) {
        ret = handle.get_self_name(buf);
      }
      return (string)buf;
    }

    public uint8[] getclient_id( int friend_id ) {
      uint8[] buf = new uint8[Tox.CLIENT_ID_SIZE];
      int ret = -1;
      lock(handle) {
        ret = handle.get_client_id(friend_id, buf);
      }
      return (ret != 0) ? null : buf;
    }

    public string? getname(int friend_number) {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH];
      int ret = -1;
      lock(handle) {
        ret = handle.get_name(friend_number, buf);
      }
      return (ret < 0) ? null: (string)buf;
    }

    public string get_statusmessage(int friend_number) {
      int size = 0;
      int ret = 0;
      uint8 [] buf;
      lock(handle) {
        size = handle.get_status_message_size(friend_number);
        buf = new uint8[size];
        ret = handle.get_status_message(friend_number, buf);
      }
      return (string)buf;
    }

    public uint32 sendmessage(int friend_number, string message) {
      uint32 ret = 0;
      uint8[] buf = Tools.string_to_nullterm_uint(message);
      lock(handle) {
        ret = handle.send_message(friend_number, buf);
      }
      return ret;
    }

    public unowned Gee.HashMap<int, Contact> get_contact_list() {
      return _contacts;
    }

    public unowned Gee.HashMap<uint8, FileTransfer> get_filetransfers() {
        return _file_transfers; 
    }

    public uint8 send_file_request(int friend_number, uint64 file_size, string filename) {
      uint8[] buf = Tools.string_to_nullterm_uint(filename);
      return (uint8) handle.new_file_sender(friend_number,file_size,buf);
    }

    public void accept_file (int friendnumber, uint8 filenumber) {
        handle.file_send_control(friendnumber,1,filenumber,Tox.FileControlStatus.ACCEPT,null);      
    }

    public void reject_file (int friendnumber, uint8 filenumber) {
        handle.file_send_control(friendnumber,1,filenumber,Tox.FileControlStatus.KILL,null);
    }
    
    public void send_filetransfer_end (int friendnumber, uint8 filenumber) {
        handle.file_send_control(friendnumber,0,filenumber,Tox.FileControlStatus.FINISHED,null);
    }

    public int send_file_data(int friendnumber,uint8 filenumber,uint8[] filedata) {
        return handle.file_send_data(friendnumber,filenumber,filedata);
    }

    public int get_recommended_data_size(int friendnumber) {
        return handle.file_data_size(friendnumber);
    }

    public uint64 get_remaining_file_data(int friendnumber,uint8 filenumber,uint8 send_receive) {
        return handle.file_data_remaining(friendnumber,filenumber,send_receive);
    }
    
    ////////////////////////////// Thread related operations /////////////////////////

    // Background thread main function
    private int run() {
      stdout.printf("Background thread started.\n");
      lock(handle) {
        if(!bootstrapped) {
          stdout.printf("Connecting to DHT servers:\n");
          for(int i = 0; i < dht_servers.length; ++i) {
            // skip ipv6 servers if we don't support them
            if(dht_servers[i].ipv6 && !ipv6)
              continue;
            stdout.printf("  %s\n", dht_servers[i].to_string());
            handle.bootstrap_from_address(
              dht_servers[i].host,
              dht_servers[i].ipv6 ? 1 : 0,
              dht_servers[i].port.to_big_endian(),
              dht_servers[i].pub_key
            );
          }
          bootstrapped = true;
        }
      }

      bool new_status = false;
      while(running) {
        lock(handle) {
          new_status = (handle.isconnected() != 0);
        }
        if(new_status && !connected) {
          connected = true;
          connected_dht_server = dht_servers[0];
          Idle.add(() => { on_own_connection_status(true); return false; });
        } else if(!new_status && connected) {
          connected = false;
          Idle.add(() => { on_own_connection_status(false); return false; });
        }
        lock(handle) {
          handle.do();
        }
        //FIXME measure time to assure 20x calling tox.do per second
        Thread.usleep(25000);
      }
      stdout.printf("Background thread stopped.\n");
      return 0;
    }

    // Start the background thread
    public void start() {
      if(running)
        return;
      running = true;
#if GLIB_2_32
      session_thread = new GLib.Thread<int>("toxbgthread", this.run);
#else
      try {
        session_thread = GLib.Thread.create<int>(this.run, true);
      } catch (Error e) {
        stderr.printf("Could not create thread: %s\n", e.message);
      }
#endif
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
    public void load_from_file(string filename) throws IOError, Error {
      File f = File.new_for_path(filename);
      if(!f.query_exists())
        throw new IOError.NOT_FOUND("File \"" + filename + "\" does not exist.");
      FileInfo file_info = f.query_info("*", FileQueryInfoFlags.NONE);
      int64 size = file_info.get_size();
      var data_stream = new DataInputStream(f.read());
      uint8[] buf = new uint8 [size];

      if(data_stream.read(buf) != size)
        throw new IOError.FAILED("Error while reading from stream.");
      int ret = -1;
      lock(handle) {
        ret = handle.load(buf);
      }
      if(ret != 0)
        throw new IOError.FAILED("Error while loading messenger data.");
      init_contact_list();
    }

    // Save messenger data from file
    public void save_to_file(string filename) throws IOError, Error {
      File file = File.new_for_path(filename);
      if(!file.query_exists()) {
        Tools.create_path_for_file(filename, 0755);
      }
      DataOutputStream os = new DataOutputStream(file.replace(null, false, FileCreateFlags.NONE));

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
  }
}
