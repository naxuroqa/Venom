using GLib;
using Gee;
using Tox;

namespace Venom {
  public class ToxSession {
    private Tox.Tox handle;
    private ArrayList<DhtServer> dht_servers = new ArrayList<DhtServer>();
    private bool running = false;
    private unowned Thread<void*> session_thread = null;
    private bool bootstraped = false;
    private bool connected = false;

    public static uint8[] hexstringToBin(string s) {
      uint8[] buf = new uint8[s.length / 2];
      for(int i = 0; i < buf.length; ++i) {
        //s[2*i:2*i+1]
        s.substring(2*i, 2).scanf("%02X", out buf[i]); //FIXME some weirdness (see valgrind)
      }
      return buf;
    }

    public ToxSession() {
      // create handle
      handle = new Tox.Tox();

      // Add one default dht server
      Ip ip = {0x58DFAF42}; //66.175.223.88
      IpPort ip_port = { ip, 0xA582 }; //33445, Big endian
      uint8[] pub_key = hexstringToBin("AC4112C975240CAD260BB2FCD134266521FAAF0A5D159C5FD3201196191E4F5D");
      dht_servers.add(new DhtServer.withArgs(ip_port, pub_key));

      /*
      handle.setFriendrequestCallback(onFriendrequest, null);
      handle.setFriendmessageCallback(onFriendmessage, null);
      handle.setNamechangeCallback(onNamechange, null);
      handle.setStatusmessageCallback(onStatusmessage, null);*/
    }

    ~ToxSession() {
      running = false;
    }

    private void* run() {
      stdout.printf("Starting tox background thread.\n");

      while(running) {
        if(!connected) {
          if(connected = (handle.isConnected() != 0)) {
            stdout.printf("Connection to DHT server established.\n");
          }
        }
        handle.do_loop();
        Thread.usleep(10000);
      }
      stdout.printf("Stopping tox background thread.\n");
      return null;
    }

    public void start() {
      if(running)
        return;
      running = true;
      if(!bootstraped) {
        stdout.printf("Connecting to DHT server:\n%s\n", dht_servers[0].toString());
        handle.bootstrap(dht_servers[0].ip_port, dht_servers[0].pub_key);
        bootstraped = true;
      }
      session_thread = Thread.create<void*>(this.run, true);
    }

    public void stop() {
      running = false;
    }

    public void join() {
      if(session_thread != null)
        session_thread.join();
    }

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

    public void save_to_file(string filename) throws IOError, Error {
      File f = File.new_for_path(filename);
      DataOutputStream os = new DataOutputStream (f.create (FileCreateFlags.REPLACE_DESTINATION));

      uint32 size = handle.getSize();
      uint8[] buf = new uint8 [size];
      handle.save(buf);

      if(os.write(buf) != size)
        throw new IOError.FAILED("Error while writing to stream.");
    }
  }
}
