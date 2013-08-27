using Tox;
using GLib;
namespace Testing {
  public static Tox.Tox t;

  public static void onFriendrequest(uint8[] public_key, uint8[] data) {
    stdout.printf("Incoming friend request from ");
    for(int i = 0; i < FRIEND_ADDRESS_SIZE; ++i) {
      stdout.printf("%02X", public_key[i]);
    }
    stdout.printf("\n");
    stdout.printf("Data: %s\n", (string)data);
    int friend_number = t.addFriendNoRequest(data);
    if(friend_number != -1) {
      stdout.printf("Successfully added friend #%i.\n", friend_number);
    } else {
      stdout.printf("Adding friend failed.\n");
      return;
    }
    string message = "Hello there!";
    uint32 ret = t.sendMessage(friend_number, message.data);
    if(ret == message.length) {
      stdout.printf("Hello message sent.\n");
    } else {
      stdout.printf("Sending welcome message failed (%u).\n", ret);
    }
  }

  public static void onFriendmessage(Tox.Tox tox, int friend_number, uint8[] message) {
    stdout.printf("[m] %i:%s", friend_number, (string)message);
  }

  public static void onNamechange(Tox.Tox tox, int friend_number, uint8[] new_name) {
    stdout.printf("[n] %i:%s", friend_number, (string)new_name);
  }

  public static void onStatusmessage(Tox.Tox tox, int friend_number, uint8[] status) {
    stdout.printf("[s] %i:%s", friend_number, (string)status);
  }

  public static uint8[] hexstringToBin(string s) {
    uint8[] buf = new uint8[s.length / 2];
    for(int i = 0; i < buf.length; ++i) {
      s.substring(2*i, 2).scanf("%02X", out buf[i]); //FIXME some weirdness (see valgrind)
    }
    return buf;
  }

  public static void load_messenger(ref Tox.Tox t, string filename) throws IOError {
    File f = File.new_for_path(filename);
    if(!f.query_exists())
      throw new IOError.NOT_FOUND("File \"" + filename + "\" does not exist.");
    FileInfo file_info = f.query_info("*", FileQueryInfoFlags.NONE);

    int64 size = file_info.get_size();
    var data_stream = new DataInputStream(f.read());
    uint8[] buf = new uint8 [size];

    if(data_stream.read(buf) != size)
      throw new IOError.FAILED("Error while reading from file \"" + filename + "\"");

    if(t.load(buf) != 0)
      throw new IOError.FAILED("Error while loading messenger data from file \"" + filename + "\"");
  }

  public static void main(string[] args) {/*
    TestBed b = new TestBed();
    ToxVapiTest t = new ToxVapiTest();
    t.registerTestcases(b);
    b.run();*/
    stdout.printf("Creating new tox instance...\n");
    string data_filename = "data";
    t = new Tox.Tox();
    stdout.printf("done.\n");
    
    Ip ip = {0x58DFAF42}; //66.175.223.88
    IpPort ip_port = { ip, 0xA582 }; //33445

    string pub_key_str = "AC4112C975240CAD260BB2FCD134266521FAAF0A5D159C5FD3201196191E4F5D";

    uint8[] pub_key = hexstringToBin(pub_key_str);

    uint8[] id = new uint8[FRIEND_ADDRESS_SIZE];

    try {
      stdout.printf("Reading datafile %s.\n", data_filename);
      load_messenger(ref t, data_filename);
      stdout.printf("done.\n");
    } catch (Error e) {
      stdout.printf("%s\n", e.message);
      return;
    }

    t.setFriendrequestCallback(onFriendrequest, null);
    t.setFriendmessageCallback(onFriendmessage, null);
    t.setNamechangeCallback(onNamechange, null);
    t.setStatusmessageCallback(onStatusmessage, null);

    stdout.printf("Connecting to %i.%i.%i.%i:%i\n", ip_port.ip.c[0], ip_port.ip.c[1], ip_port.ip.c[2], ip_port.ip.c[3], ip_port.port);
    stdout.printf("Public server key: ");
    for(int i = 0; i < pub_key.length; ++i) {
      stdout.printf("%02X", pub_key[i]);
    }
    stdout.printf("\n");

    t.getAddress(id);
    stdout.printf("ID: ");
    foreach(uint8 b in id) {
      stdout.printf("%02X", b);
    }
    stdout.printf("\n");

    t.bootstrap(ip_port, pub_key);
    bool connected = false;

    while(true)
    {
      if(!connected) {
        if((connected = t.isConnected() != 0)) {
          stdout.printf("Connection established.\n");
        }
      }
      t.do_loop();
      Thread.usleep(10000);
    }
  }
}
