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

using Gee;
using Tox;

namespace Venom {
  // Wrapper class for accessing tox functions threadsafe
  public class ToxSession : Object {
    private Tox.Tox handle;
    private ArrayList<DhtServer> dht_servers = new ArrayList<DhtServer>();
    private Thread<int> session_thread = null;
    private bool bootstrapped = false;
    public bool running {get; private set; default=false; }
    public bool connected { get; private set; default=false; }
    public DhtServer connected_dht_server { get; private set; default=null; }
    
    public signal void on_friendrequest(uint8[] public_key, string message);
    public signal void on_friendmessage(int friend_number, string message);
    public signal void on_action(int friend_number, string action);
    public signal void on_namechange(int friend_number, string new_name);
    public signal void on_statusmessage(int friend_number, string status);
    public signal void on_userstatus(int friend_number, int user_status);
    public signal void on_read_receipt(int friend_number, uint32 receipt);
    public signal void on_connectionstatus(int friend_number, bool status);

    // private signals
    public signal void on_ownconnectionstatus(bool status);

    public ToxSession() {
      // create handle
      handle = new Tox.Tox();

      // Add one default dht server
      Ip ip = {(uint32)0x7651B8C0}; //192.184.81.118
      IpPort ip_port = { ip, ((uint16)33445).to_big_endian() };
      uint8[] pub_key = Tools.hexstring_to_bin("5CD7EB176C19A2FD840406CD56177BB8E75587BB366F7BB3004B19E3EDC04143");
      dht_servers.add(new DhtServer.withArgs(ip_port, pub_key));

      // setup callbacks
      handle.callback_friendrequest(this.on_friendrequest_callback);
      handle.callback_friendmessage(this.on_friendmessage_callback);
      handle.callback_action(this.on_action_callback);
      handle.callback_namechange(this.on_namechange_callback);
      handle.callback_statusmessage(this.on_statusmessage_callback);
      handle.callback_userstatus(this.on_userstatus_callback);
      handle.callback_read_receipt(this.on_read_receipt_callback);
      handle.callback_connectionstatus(this.on_connectionstatus_callback);
    }

    // destructor
    ~ToxSession() {
      running = false;
    }

    ////////////////////////////// Callbacks /////////////////////////////////////////
    [CCode (instance_pos = -1)]
    private void on_friendrequest_callback(uint8[] public_key, uint8[] data) {
      if(public_key == null) {
        stderr.printf("Public key was null in friendrequest!\n");
        return;
      }
      string message = ((string)data).dup(); //FIXME string may be copied two times here, check
      uint8[] public_key_clone = Tools.clone(public_key, Tox.CLIENT_ID_SIZE);
      Idle.add(() => { on_friendrequest(public_key_clone, message); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_friendmessage_callback(Tox.Tox tox, int friend_number, uint8[] message) {
      string message_string = ((string)message).dup();
      Idle.add(() => { on_friendmessage(friend_number, message_string); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_action_callback(Tox.Tox tox, int friend_number, uint8[] action) {
      string action_string = ((string)action).dup();
      Idle.add(() => { on_action(friend_number, action_string); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_namechange_callback(Tox.Tox tox, int friend_number, uint8[] new_name) {
      string name_string = ((string)new_name).dup();
      Idle.add(() => { on_namechange(friend_number, name_string); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_statusmessage_callback(Tox.Tox tox, int friend_number, uint8[] status) {
      string status_string = ((string)status).dup();
      Idle.add(() => { on_statusmessage(friend_number, status_string); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_userstatus_callback(Tox.Tox tox, int friend_number, UserStatus user_status) {
      Idle.add(() => { on_userstatus(friend_number, user_status); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_read_receipt_callback(Tox.Tox tox, int friend_number, uint32 receipt) {
      Idle.add(() => { on_read_receipt(friend_number, receipt); return false; });
    }

    [CCode (instance_pos = -1)]
    private void on_connectionstatus_callback(Tox.Tox tox, int friend_number, uint8 status) {
      Idle.add(() => { on_connectionstatus(friend_number, (status != 0)); return false; });
    }

    ////////////////////////////// Wrapper functions ////////////////////////////////

    // Add a friend, returns Tox.FriendAddError on error and friend_number on success
    public Tox.FriendAddError addfriend(uint8[] id, string message) {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      if(id.length != Tox.FRIEND_ADDRESS_SIZE)
        return ret;

      uint8[] data = Tools.string_to_nullterm_uint(message);
      
      lock(handle) {
        ret = handle.addfriend(id, data);
      }
      return ret;
    }

    public Tox.FriendAddError addfriend_norequest(uint8[] id) {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      if(id.length != Tox.FRIEND_ADDRESS_SIZE)
        return ret;
      
      lock(handle) {
        ret = handle.addfriend_norequest(id);
      }
      return ret;
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

    /* FIXME this wont work for now, there is no such thing in the api
    public string get_self_statusmessage() {
      uint8[] buf;
      lock(handle) {
        buf = new uint8[handle.get_statusmessage_size()];
      }
    }*/
    
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

    public string getname(int friend_number) {
      uint8[] buf = new uint8[Tox.MAX_NAME_LENGTH];
      int ret = -1;
      lock(handle) {
        ret = handle.getname(friend_number, buf);
      }
      return ret == 0 ? (string)buf : null;
    } 

    ////////////////////////////// Thread related operations /////////////////////////

    // Background thread main function
    private int run() {
      stdout.printf("Background thread started.\n");
      lock(handle) {
        if(!bootstrapped) {
          stdout.printf("Connecting to DHT server:\n%s\n", dht_servers[0].toString());
          handle.bootstrap(dht_servers[0].ip_port, dht_servers[0].pub_key);
          bootstrapped = true;
        }
      }

      while(running) {
        if(!connected) {
          lock(handle) {
            if(connected = (handle.isconnected() != 0)) {
              Idle.add(() => { on_ownconnectionstatus(true); return false; });
              connected_dht_server = dht_servers[0];
            }
          }
        } else {
          lock(handle) {
            if(!(connected = (handle.isconnected() != 0))) {
              Idle.add(() => { on_ownconnectionstatus(false); return false; });
            }
          }
        }
        lock(handle) {
          handle.do();
        }
        Thread.usleep(10000);
      }
      stdout.printf("Background thread stopped.\n");
      return 0;
    }

    // Start the background thread
    public void start() {
      if(running)
        return;
      running = true;
      session_thread = new GLib.Thread<int>("Tox background thread", this.run);
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
    // Load messenger data from file (not locked, don't use while bgthread is running)
    public void load_from_file(string pathname, string filename) throws IOError, Error {
      File f = File.new_for_path(Path.build_filename(pathname, filename));
      if(!f.query_exists())
        throw new IOError.NOT_FOUND("File \"" + filename + "\" does not exist.");
      FileInfo file_info = f.query_info("*", FileQueryInfoFlags.NONE);
      int64 size = file_info.get_size();
      var data_stream = new DataInputStream(f.read());
      uint8[] buf = new uint8 [size];

      if(data_stream.read(buf) != size)
        throw new IOError.FAILED("Error while reading from stream.");

      if(handle.load(buf) != 0)
        throw new IOError.FAILED("Error while loading messenger data.");
    }

    // Save messenger data from file (not locked, don't use while bgthread is running)
    public void save_to_file(string pathname, string filename) throws IOError, Error {
      File path = File.new_for_path(pathname);
      if(!path.query_exists()) {
        DirUtils.create_with_parents(pathname, 0755);
        stdout.printf("creating Directory %s\n", pathname);
      }
      File f = File.new_for_path(Path.build_filename(pathname, filename));
      DataOutputStream os = new DataOutputStream(f.replace(null, false, FileCreateFlags.NONE));

      uint32 size = handle.size();
      uint8[] buf = new uint8 [size];
      handle.save(buf);

      if(os.write(buf) != size)
        throw new IOError.FAILED("Error while writing to stream.");
    }
  }
}
