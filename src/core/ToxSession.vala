/*
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
  // Wrapper class for accessing tox functions threadsafe
  public class ToxSession : Object {
    private Tox.Tox handle;
    private Gee.ArrayList<DhtServer> dht_servers = new Gee.ArrayList<DhtServer>();
    private Gee.HashMap<int, Contact> _contacts = new Gee.HashMap<int, Contact>();
    private Gee.HashMap<int, GroupChat> _groups = new Gee.HashMap<int, GroupChat>();
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
    public signal void on_friendrequest(Contact c, string message);
    public signal void on_friendmessage(Contact c, string message);
    public signal void on_action(Contact c, string action);
    public signal void on_namechange(Contact c, string? old_name);
    public signal void on_statusmessage(Contact c, string? old_status);
    public signal void on_userstatus(Contact c, int old_status);
    public signal void on_read_receipt(Contact c, uint32 receipt);
    public signal void on_connectionstatus(Contact c);
    public signal void on_ownconnectionstatus(bool status);

    // Groupchat signals
    public signal void on_group_invite(Contact c, GroupChat g);
    public signal void on_group_message(GroupChat g, int friendgroupnumber, string message);

    // File sending callbacks
    /*
    public signal void on_file_sendrequest();
    public signal void on_file_control();
    public signal void on_file_data();
    */

    public ToxSession( bool ipv6 = false ) {
	  this.ipv6 = ipv6;

      // create handle
      handle = new Tox.Tox( ipv6 ? 1 : 0);

      // Add one default dht server
      string ip = "192.184.81.118";
      uint16 port = ((uint16)33445).to_big_endian();
      uint8[] pub_key = Tools.hexstring_to_bin("5CD7EB176C19A2FD840406CD56177BB8E75587BB366F7BB3004B19E3EDC04143");
      dht_servers.add(new DhtServer.with_args(ip, port, pub_key));

      // setup callbacks
      handle.callback_friendrequest(this.on_friendrequest_callback);
      handle.callback_friendmessage(this.on_friendmessage_callback);
      handle.callback_action(this.on_action_callback);
      handle.callback_namechange(this.on_namechange_callback);
      handle.callback_statusmessage(this.on_statusmessage_callback);
      handle.callback_userstatus(this.on_userstatus_callback);
      handle.callback_read_receipt(this.on_read_receipt_callback);
      handle.callback_connectionstatus(this.on_connectionstatus_callback);

      // Groupchat callbacks
      handle.callback_group_invite(this.on_group_invite_callback);
      handle.callback_group_message(this.on_group_message_callback);

      // File sending callbacks
      handle.callback_file_sendrequest(this.on_file_sendrequest_callback);
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
        ret = handle.copy_friendlist(friend_numbers);
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
    private void on_friendrequest_callback(uint8[] public_key, uint8[] data) {
      if(public_key == null) {
        stderr.printf("Public key was null in friendrequest!\n");
        return;
      }
      string message = ((string)data).dup(); //FIXME string may be copied two times here, check
      uint8[] public_key_clone = Tools.clone(public_key, Tox.CLIENT_ID_SIZE);
      Contact contact = new Contact(public_key_clone, -1);
      Idle.add(() => { on_friendrequest(contact, message); return false; });
    }

    private void on_friendmessage_callback(Tox.Tox tox, int friend_number, uint8[] message) {
      string message_string = ((string)message).dup();
      Idle.add(() => { on_friendmessage(_contacts.get(friend_number), message_string); return false; });
    }

    private void on_action_callback(Tox.Tox tox, int friend_number, uint8[] action) {
      string action_string = ((string)action).dup();
      Idle.add(() => { on_action(_contacts.get(friend_number), action_string); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_namechange_callback(Tox.Tox tox, int friend_number, uint8[] new_name) {
      Contact contact = _contacts.get(friend_number);
      string old_name = contact.name;
      contact.name = ((string)new_name).dup();
      Idle.add(() => { on_namechange(contact, old_name); return false; });
    }

    private void on_statusmessage_callback(Tox.Tox tox, int friend_number, uint8[] status) {
      Contact contact = _contacts.get(friend_number);
      string old_status = contact.status_message;
      contact.status_message = ((string)status).dup();
      Idle.add(() => { on_statusmessage(contact, old_status); return false; });
    }

    private void on_userstatus_callback(Tox.Tox tox, int friend_number, Tox.UserStatus user_status) {
      Contact contact = _contacts.get(friend_number);
      int old_status = contact.user_status;
      contact.user_status = user_status;
      Idle.add(() => { on_userstatus(contact, old_status); return false; });
    }

    
    private void on_read_receipt_callback(Tox.Tox tox, int friend_number, uint32 receipt) {
      Idle.add(() => { on_read_receipt(_contacts.get(friend_number), receipt); return false; });
    }

    private void on_connectionstatus_callback(Tox.Tox tox, int friend_number, uint8 status) {
      Contact contact = _contacts.get(friend_number);
      contact.online = (status != 0);
      Idle.add(() => { on_connectionstatus(contact); return false; });
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
    }

    private void on_file_control_callback(Tox.Tox tox, int friendnumber, uint8 receive_send, uint8 filenumber, uint8 status, uint8[] data) {
    }

    private void on_file_data_callback(Tox.Tox tox, int friendnumber, uint8 filenumber, uint8[] data) {
    }

    ////////////////////////////// Wrapper functions ////////////////////////////////

    // Add a friend, returns Tox.FriendAddError on error and friend_number on success
    public Tox.FriendAddError addfriend(Contact c, string message) {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      if(c.public_key.length != Tox.FRIEND_ADDRESS_SIZE)
        return ret;

      uint8[] data = Tools.string_to_nullterm_uint(message);
      
      lock(handle) {
        ret = handle.addfriend(c.public_key, data);
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
        ret = handle.addfriend_norequest(c.public_key);
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
        ret = handle.delfriend(c.friend_id);
      }
      if(ret == 0) {
        _contacts.unset(c.friend_id);
      }
      return ret == 0;
    }

    // Set user status, returns true on success
    public bool set_status(Tox.UserStatus user_status) {
      int ret = -1;
      lock(handle) {
        ret = handle.set_userstatus(user_status);
      }
      return ret == 0;
    }

    // Set user statusmessage, returns true on success
    public bool set_statusmessage(string message) {
      int ret = -1;
      uint8[] buf = Tools.string_to_nullterm_uint(message);
      lock(handle) {
        ret = handle.set_statusmessage(buf);
      }
      return ret == 0;
    }

    public string get_self_statusmessage() {
      uint8[] buf = new uint8[Tox.MAX_STATUSMESSAGE_LENGTH];
      int ret = 0;
      lock(handle) {
        ret = handle.copy_self_statusmessage(buf);
      }
      return (string)buf;
    }
    
    // get personal id
    public uint8[] get_address() {
      uint8[] buf = new uint8[Tox.FRIEND_ADDRESS_SIZE];
      lock(handle) {
        handle.getaddress(buf);
      }
      return buf;
    }

    // set username
    public bool setname(string name) {
      uint8[] buf = Tools.string_to_nullterm_uint(name);
      int ret = -1;
      lock(handle) {
        ret = handle.setname(buf);
      }
      return ret == 0;      
    }

    public string getselfname() {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH];
      int ret = -1;
      lock(handle) {
        ret = handle.getselfname(buf);
      }
      return (string)buf;
    }

    public uint8[] getclient_id( int friend_id ) {
      uint8[] buf = new uint8[Tox.CLIENT_ID_SIZE];
      int ret = -1;
      lock(handle) {
        ret = handle.getclient_id(friend_id, buf);
      }
      return (ret != 0) ? null : buf;
    }

    public string? getname(int friend_number) {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH];
      int ret = -1;
      lock(handle) {
        ret = handle.getname(friend_number, buf);
      }
      return (ret < 0) ? null: (string)buf;
    }
    
    public string get_statusmessage(int friend_number) {
      int size = 0;
      int ret = 0;
      uint8 [] buf;
      lock(handle) {
        size = handle.get_statusmessage_size(friend_number);
        buf = new uint8[size];
        ret = handle.copy_statusmessage(friend_number, buf);
      }
      return (string)buf;
    }

    public uint32 sendmessage(int friend_number, string message) {
      uint32 ret = 0;
      uint8[] buf = Tools.string_to_nullterm_uint(message);
      lock(handle) {
        ret = handle.sendmessage(friend_number, buf);
      }
      return ret;
    }
    
    public unowned Gee.HashMap<int, Contact> get_contact_list() {
      return _contacts;
    }

    ////////////////////////////// Thread related operations /////////////////////////

    // Background thread main function
    private int run() {
      stdout.printf("Background thread started.\n");
      lock(handle) {
        if(!bootstrapped) {
          stdout.printf("Connecting to DHT server:\n%s\n", dht_servers[0].to_string());
          handle.bootstrap_from_address(dht_servers[0].ip, dht_servers[0].ipv6 ? 1 : 0, dht_servers[0].port, dht_servers[0].pub_key);
          bootstrapped = true;
        }
      }

      bool new_status = false;
      while(running) {
        lock(handle) {
          new_status = (handle.isconnected() != 0);
        }
        if(new_status && !connected) {
          connected_dht_server = dht_servers[0];
		  Idle.add(() => { on_ownconnectionstatus(true); return false; });
        } else if(!new_status && connected) {
          Idle.add(() => { on_ownconnectionstatus(false); return false; });
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
      bootstrapped = false;
      connected = false;
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
