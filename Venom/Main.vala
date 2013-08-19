using Gtk;
using GLib;
using Tox;
namespace Venom {
public struct BootstrapData {
  public Network.IpPort ip_port;
  public uint8 public_key[Crypto.Box.PUBLIC_KEY_BYTES];
}
public class Main {
    public BootstrapData[] read_bootstrap_data(string filename) {
      var file = File.new_for_path("filename");
      if(!file.query_exists()) {
        stderr.printf("File %s does not exist.\n", file.get_path());
        return null;
      }
      try {
        var dis = new DataInputStream(file.read());
        string line;
        while((line = dis.read_line(null)) != null) {
          stdout.printf("%s\n", line);
          string [] 
        }
      }
      catch (Error e) {
        error("%s", e.message);
      }
    }
    public static int vapi_messenger_test() {
      stdout.printf("Testing messenger functions\n");
      //assert(Messenger.MAX_NAME_LENGTH == 128);
      //assert((int)Messenger.PacketId.STATUSMESSAGE == 49);
      //assert((int)Messenger.FriendAddError.OWNKEY == -3);

      Messenger.Messenger m = new Messenger.Messenger();
      assert(m != null);

      Network.IpPort ip_port = Network.IpPort();
      ip_port.ip.i = 0x36D79147;
      ip_port.port = 33445;
      stdout.printf("Connecting to DHT Bootstrap server %i.%i.%i.%i:%i\n",
        ip_port.ip.c[3],
        ip_port.ip.c[2],
        ip_port.ip.c[1],
        ip_port.ip.c[0],
        ip_port.port);
      uint8 [] public_key = {0x6C,
                             0x74,
                             0xFB,
                             0x42,
                             0xCD,
                             0x3D,
                             0x59,
                             0x51,
                             0xEA,
                             0x2F,
                             0x03,
                             0xB6,
                             0x58,
                             0x30,
                             0xC9,
                             0x89,
                             0xBA,
                             0xDC,
                             0x96,
                             0x47,
                             0x6B,
                             0x76,
                             0xC0,
                             0x03,
                             0x93,
                             0x57,
                             0xEF,
                             0x88,
                             0x21,
                             0xEE,
                             0xDD,
                             0x6E};
      Dht.bootstrap(ip_port, public_key);

      while(Dht.is_connected() == 0) {
        m.do_messenger();
        Thread.usleep(500);
      }
      stdout.printf("Connected to DHT!");

      //stdout.printf("public key:  ");
      //for(int i = 0; i < Crypto.Box.PUBLIC_KEY_BYTES; ++i)
      //  stdout.printf("%02X", m.public_key[i]);
      //stdout.printf("\n");
      stdout.printf("name: %s\n", (string)m.name);
      stdout.printf("status: %s\n", (string)m.statusmessage);
      stdout.printf("number of friends: %u\n", m.numfriends);
      stdout.printf("done.\n");
      return 0;
    }
    public static void vapi_keygen_test() {
      stdout.printf("Testing Keygen functions\n");
      NetCrypto.new_keys();
      uint8 [] keys = new uint8[Crypto.Box.PUBLIC_KEY_BYTES + Crypto.Box.SECRET_KEY_BYTES];
      unowned uint8 [] public_key = keys [0:Crypto.Box.PUBLIC_KEY_BYTES];
      unowned uint8 [] private_key = keys[Crypto.Box.PUBLIC_KEY_BYTES:keys.length];
      NetCrypto.save_keys(keys);
      stdout.printf("public key:  ");
      foreach(uint8 i in public_key)
        stdout.printf("%02X", i);
      stdout.printf("\nprivate key: ");
      foreach(uint8 i in private_key)
        stdout.printf("%02X", i);
      stdout.printf("\n");
      stdout.printf("done.\n");
    }
    public static void vapi_test() {
      vapi_keygen_test();
      vapi_messenger_test();
    }
    public static int main (string[] args) {
/*
      Gtk.init (ref args);

      ContactList contact_list;

      try {
        contact_list = ContactList.create_contact_list("sample.ui", "window");
        contact_list.contact_list_window.destroy.connect (Gtk.main_quit);
        contact_list.contact_list_window.show_all ();
      } catch ( Error e ) {
        stderr.printf("Could not load UI: %s\n", e.message);
        return 1;
      }

      Gtk.main();
*/
      vapi_test();

      return 0;
    }
  }
}
