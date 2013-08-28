using GLib;
using Gee;
using Tox;

namespace Venom {
  // Wrapper class for accessing tox functions threadsafe
  public class ToxSession {
    private Tox.Tox handle;
    private ArrayList<DhtServer> dht_servers = new ArrayList<DhtServer>();
    private bool running = false;
    private Thread<int> session_thread = null;
    private bool bootstrapped = false;
    private bool connected = false;

    // convert a hexstring to uint8[]
    public static uint8[] hexstringToBin(string s) {
      uint8[] buf = new uint8[s.length / 2];
      for(int i = 0; i < buf.length; ++i) {
        int b = 0;
        s.substring(2*i, 2).scanf("%02x", ref b);
        buf[i] = (uint8)b;
      }
      return buf;
    }
    public static uint8[] string_to_nullterm_uint (string input){
      if(input == null || input.length == 0)
        return {'\0'};
      uint8[] clone = new uint8[input.data.length + 1];
      Memory.copy(clone, input.data, input.data.length * sizeof(uint8));
      clone[clone.length - 1] = '\0';
      return clone;
    }

    public ToxSession() {
      // create handle
      handle = new Tox.Tox();

      // Add one default dht server
      Ip ip = {0x58DFAF42}; //66.175.223.88
      IpPort ip_port = { ip, 0xA582 }; //33445, Big endian
      uint8[] pub_key = hexstringToBin("AC4112C975240CAD260BB2FCD134266521FAAF0A5D159C5FD3201196191E4F5D");
      dht_servers.add(new DhtServer.withArgs(ip_port, pub_key));

      // setup callbacks, currently disabled
      /*
      handle.setFriendrequestCallback(onFriendrequest, null);
      handle.setFriendmessageCallback(onFriendmessage, null);
      handle.setNamechangeCallback(onNamechange, null);
      handle.setStatusmessageCallback(onStatusmessage, null);*/
    }

    // destructor
    ~ToxSession() {
      running = false;
    }

    // Add a friend
    public Tox.FriendAddError add_friend(uint8[] id, string message) {
      Tox.FriendAddError ret = Tox.FriendAddError.UNKNOWN;

      if(id.length != Tox.FRIEND_ADDRESS_SIZE)
        return ret;

      uint8[] data = string_to_nullterm_uint(message);
      
      lock(handle) {
        ret = handle.addfriend(id, data);
      }
      return ret;
    }

    public bool set_status(Tox.UserStatus user_status) {
      int ret = -1;
      lock(handle) {
        ret = handle.set_userstatus(user_status);
      }
      return ret == 0;
    }

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
              stdout.printf("Connection to DHT server established.\n");
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

    // Start the background thread (if not already running)
    public void start() {
      if(running)
        return;
      running = true;
      session_thread = new GLib.Thread<int>("name", this.run);
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

    // Load messenger data from file (not locked, don't use while bgthread is running)
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

      if(handle.load(buf) != 0)
        throw new IOError.FAILED("Error while loading messenger data.");
    }

    // Save messenger data from file (not locked, don't use while bgthread is running)
    public void save_to_file(string filename) throws IOError, Error {
      File f = File.new_for_path(filename);
      DataOutputStream os = new DataOutputStream (f.create (FileCreateFlags.REPLACE_DESTINATION));

      uint32 size = handle.size();
      uint8[] buf = new uint8 [size];
      handle.save(buf);

      if(os.write(buf) != size)
        throw new IOError.FAILED("Error while writing to stream.");
    }
  }
}
