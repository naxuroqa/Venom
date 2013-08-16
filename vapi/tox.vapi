

using GLib;

[CCode (lower_case_cprefix = "", cheader_filename = "tox/Messenger.h")]
namespace Tox {
  namespace Messenger {
    [CCode (cname="USERSTATUS", cprefix="")]
    public enum UserStatus {
      NONE,
      AWAY,
      BUSY,
      INVALID
    }
    [CCode (cname = "MAX_NAME_LENGTH")]
    public const int MAX_NAME_LENGTH;
  /*
    [CCode (cname = "Friend", destroy_function = "")]
    public struct Friend {
      [CCode (array_length_cname = "", array_length_type = "ulong")]
      public uint8 client_id[];
      public int crypt_connection_id;
      public uint64 friend_request_id;
      public uint8 status;
      public uint8 info[];
      public uint8 name[];
      public uint8 name_sent;
      [CCode (array_length_cname = "statusmessage_length", array_length_type = "uint16")]
      public unowned uint8 [128] statusmessage;
      public uint16 statusmessage_length;
      public uint8 statusmessage_send;
      public UserStatus userstatus;
      public uint8 userstatus_send;
      public uint16 info_size;
      public uint32 message_id;
      public uint8 receives_read_receipts;
      public uint32 friendrequest_nospam;
    }*/
  }
}
