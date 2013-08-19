

using GLib;

namespace Tox {
  [CCode (lower_case_cprefix = "", cheader_filename = "tox/Messenger.h")]
  namespace Messenger {

    [CCode (cname = "MAX_NAME_LENGTH")]
    public const int MAX_NAME_LENGTH;

    [CCode (cname = "MAX_STATUSMESSAGE_LENGTH")]
    public const int MAX_STATUSMESSAGE_LENGTH;

    [CCode (cname = "FRIEND_ADDRESS_SIZE")]
    public const int FRIEND_ADDRESS_SIZE;

    [CCode (cname = "int")]
    public enum PacketId {
      [CCode (cname = "PACKET_ID_NICKNAME")]
      NICKNAME,
      [CCode (cname = "PACKET_ID_STATUSMESSAGE")]
      STATUSMESSAGE,
      [CCode (cname = "PACKET_ID_USERSTATUS")]
      USERSTATUS,
      [CCode (cname = "PACKET_ID_RECEIPT")]
      RECEIPT,
      [CCode (cname = "PACKET_ID_MESSAGE")]
      MESSAGE,
      [CCode (cname = "PACKET_ID_ACTION")]
      ACTION
    }

    [CCode (cname = "int")]
    public enum FriendStatus {
      [CCode (cname = "FRIEND_ONLINE")]
      ONLINE,
      [CCode (cname = "FRIEND_CONFIRMED")]
      CONFIRMED,
      [CCode (cname = "FRIEND_REQUESTED")]
      REQUESTED,
      [CCode (cname = "FRIEND_ADDED")]
      ADDED,
      [CCode (cname = "NOFIREND")]
      NO
    }

    [CCode (cname = "int")]
    public enum FriendAddError {
      [CCode (cname = "FAERR_TOOLONG")]
      TOOLONG,
      [CCode (cname = "FAERR_NOMESSAGE")]
      NOMESSAGE,
      [CCode (cname = "FAERR_OWNKEY")]
      OWNKEY,
      [CCode (cname = "FAERR_ALREADYSENT")]
      ALREADYSENT,
      [CCode (cname = "FAERR_UNKNOWN")]
      UNKOWKN,
      [CCode (cname = "FAERR_BADCHECKSUM")]
      BADCHECKSUM,
      [CCode (cname = "FAERR_SETNEWNOSPAM")]
      SETNEWNOSPAM,
      [CCode (cname = "FAERR_NOMEM")]
      NOMEM
    }

    [CCode (cname="USERSTATUS", cprefix="")]
    public enum UserStatus {
      NONE,
      AWAY,
      BUSY,
      INVALID
    }

    [CCode (cname = "Friend")]
    public struct Friend {
      [CCode (array_length_cname = "CLIENT_ID_SIZE")]
      public uint8 client_id[];
      public int crypt_connection_id;
      public uint64 friend_request_id;
      public uint8 status;
      [CCode (array_length_cname = "MAX_DATA_SIZE")]
      public uint8 info[];
      [CCode (array_length_cname = "MAX_NAME_LENGTH")]
      public uint8 name[];
      public uint8 name_sent;
      [CCode (array_length_cname = "STATUSMESSAGE_LENGTH")]
      public unowned uint8 [] statusmessage;
      public uint16 statusmessage_length;
      public uint8 statusmessage_send;
      public UserStatus userstatus;
      public uint8 userstatus_send;
      public uint16 info_size;
      public uint32 message_id;
      public uint8 receives_read_receipts;
      public uint32 friendrequest_nospam;
    }

    [Compact]
    [CCode (cname = "struct Messenger", free_function = "cleanupMessenger")]
    public class Messenger {
      //[CCode (cname = "initMessenger", instance_pos = "-1")]
      //public Messenger();
      [CCode (array_length_cname = "crypto_box_PUBLICKEYBYTES")]
      public uint8 public_key[];
      [CCode (array_length_cname = "MAX_NAME_LENGTH")]
      public uint8 name[];
      public uint16 name_length;
      [CCode (array_length_cname = "MAX_STATUSMESSAGE_LENGTH")]
      public uint8 statusmessage[];
      public uint16 statusmessage_length;
      public UserStatus userstatus;
      [CCode (array_length_cname = "numfriends")]
      public unowned Friend friendlist[];
      public uint32 numfriends;

      [CCode (cname = "initMessenger")]
      public Messenger();
      public uint8 [] getaddress([CCode (array_length = "")] uint8 address []);
      [CCode (cname = "doMessenger")]
      public void do_messenger();
    }

  }
  [CCode (lower_case_cprefix = "", cheader_filename = "tox/net_crypto.h")]
  namespace NetCrypto {
    [CCode (array_length_cname = "crypto_box_PUBLICKEYBYTES")]
    public uint8 self_public_key[];
    [CCode (array_length_cname = "crypto_box_SECRETKEYBYTES")]
    public uint8 self_secret_key[];
    [CCode (cname = "new_keys")]
    public void new_keys();
    [CCode (cname = "save_keys")]
    public void save_keys( [CCode (array_length="")] uint8 keys [] );
    [CCode (cname = "load_keys")]
    public void load_keys( [CCode (array_length="")] uint8 keys [] );
  }
  [CCode (lower_case_cprefix = "", cheader_filename = "tox/network.h")]
  namespace Network {
    [SimpleType]
    [CCode (cname="IP")]
    public struct Ip {
      [CCode (array_length="4")]
      public uint8 c[];
      [CCode (array_length="2")]
      public uint16 s[];
      public uint32 i;
    }
    [SimpleType]
    [CCode (cname="IP_Port", destroy_function="//")]
    public struct IpPort {
      [CCode(cname ="(const IP_Port) {0};//")]
      public IpPort();
      public Ip ip;
      public uint16 port;
      public uint16 padding;
    }
    [CCode (cname="ADDR")]
    public struct Addr {
      public int16 family;
      public uint16 port;
      public Ip ip;
      [CCode (array_length="8")]
      public uint8 zeroes [];
      [CCode (array_length="12")]
      public uint8 zeroes2 [];
    }
  }
  [CCode (lower_case_cprefix = "", cheader_filename = "tox/DHT.h")]
  namespace Dht {
    [CCode (cname="DHT_bootstrap")]
    public static void bootstrap(Network.IpPort ip_port, [CCode (array_length=false)]uint8 public_key []);
    [CCode (cname="DHT_isconnected")]
    public static int is_connected();
  }
}

namespace Crypto {
  namespace Box {
    [CCode (cname = "crypto_box_SECRETKEYBYTES")]
    public int SECRET_KEY_BYTES;
    [CCode (cname = "crypto_box_PUBLICKEYBYTES")]
    public int PUBLIC_KEY_BYTES;
  }
}
