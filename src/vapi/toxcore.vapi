[CCode(cheader_filename = "tox/tox.h", cprefix = "Tox_", lower_case_cprefix = "tox_")]
namespace ToxCore {
  namespace Version {
    /**
     * The major version number. Incremented when the API or ABI changes in an
     * incompatible way.
     *
     * The function variants of these constants return the version number of the
     * library. They can be used to display the Tox library version or to check
     * whether the client is compatible with the dynamically linked version of Tox.
     */
    public const uint32 MAJOR;
    /**
     * The major version number. Incremented when the API or ABI changes in an
     * incompatible way.
     *
     * The function variants of these constants return the version number of the
     * library. They can be used to display the Tox library version or to check
     * whether the client is compatible with the dynamically linked version of Tox.
     */
    public static uint32 major();
    /**
     * The minor version number. Incremented when functionality is added without
     * breaking the API or ABI. Set to 0 when the major version number is
     * incremented.
     */
    public const uint32 MINOR;
    /**
     * The minor version number. Incremented when functionality is added without
     * breaking the API or ABI. Set to 0 when the major version number is
     * incremented.
     */
    public static uint32 minor();
    /**
     * The patch or revision number. Incremented when bugfixes are applied without
     * changing any functionality or API or ABI.
     */
    public const uint32 PATCH;
    /**
     * The patch or revision number. Incremented when bugfixes are applied without
     * changing any functionality or API or ABI.
     */
    public static uint32 patch();
    /**
     * Return whether the compiled library version is compatible with the passed
     * version numbers.
     */
    public static bool is_compatible(uint32 major, uint32 minor, uint32 patch);
  }

  /**
   * The size of a Tox Public Key in bytes.
   */
  public const uint32 PUBLIC_KEY_SIZE;
  /**
   * The size of a Tox Public Key in bytes.
   */
  public static uint32 public_key_size();
  /**
   * The size of a Tox Secret Key in bytes.
   */
  public const uint32 SECRET_KEY_SIZE;
  /**
   * The size of a Tox Secret Key in bytes.
   */
  public static uint32 secret_key_size();
  /**
   * The size of the nospam in bytes when written in a Tox address.
   */
  public const uint32 NOSPAM_SIZE;
  /**
   * The size of the nospam in bytes when written in a Tox address.
   * @since 0.2.1
   */
  [Version(since = "0.2.1")]
  public static uint32 nospam_size();
  /**
   * The size of a Tox address in bytes. Tox addresses are in the format
   * [Public Key ({@link PUBLIC_KEY_SIZE} bytes)][nospam (4 bytes)][checksum (2 bytes)].
   *
   * The checksum is computed over the Public Key and the nospam value. The first
   * byte is an XOR of all the even bytes (0, 2, 4, ...), the second byte is an
   * XOR of all the odd bytes (1, 3, 5, ...) of the Public Key and nospam.
   */
  public const uint32 ADDRESS_SIZE;
  /**
   * The size of a Tox address in bytes. Tox addresses are in the format
   * [Public Key ({@link PUBLIC_KEY_SIZE} bytes)][nospam (4 bytes)][checksum (2 bytes)].
   *
   * The checksum is computed over the Public Key and the nospam value. The first
   * byte is an XOR of all the even bytes (0, 2, 4, ...), the second byte is an
   * XOR of all the odd bytes (1, 3, 5, ...) of the Public Key and nospam.
   */
  public static uint32 address_size();
  /**
   * Maximum length of a nickname in bytes.
   */
  [Version(deprecated = true, deprecated_since = "0.2.0", replacement = "max_name_length()")]
  public const uint32 MAX_NAME_LENGTH;
  /**
   * Maximum length of a nickname in bytes.
   */
  public static uint32 max_name_length();
  /**
   * Maximum length of a status message in bytes.
   */
  [Version(deprecated = true, deprecated_since = "0.2.0", replacement = "max_status_message_length()")]
  public const uint32 MAX_STATUS_MESSAGE_LENGTH;
  /**
   * Maximum length of a status message in bytes.
   */
  public static uint32 max_status_message_length();
  /**
   * Maximum length of a friend request message in bytes.
   */
  [Version(deprecated = true, deprecated_since = "0.2.0", replacement = "max_friend_request_length()")]
  public const uint32 MAX_FRIEND_REQUEST_LENGTH;
  /**
   * Maximum length of a friend request message in bytes.
   */
  public static uint32 max_friend_request_length();
  /**
   * Maximum length of a single message after which it should be split.
   */
  [Version(deprecated = true, deprecated_since = "0.2.0", replacement = "max_message_length")]
  public const uint32 MAX_MESSAGE_LENGTH;
  /**
   * Maximum length of a single message after which it should be split.
   */
  public static uint32 max_message_length();
  /**
   * Maximum size of custom packets. TODO(iphydf): should be LENGTH?
   */
  [Version(deprecated = true, deprecated_since = "0.2.0", replacement = "max_custom_packet_size")]
  public const uint32 MAX_CUSTOM_PACKET_SIZE;
  /**
   * Maximum size of custom packets. TODO(iphydf): should be LENGTH?
   */
  public static uint32 max_custom_packet_size();
  /**
   * The number of bytes in a hash generated by {@link Tox.hash}.
   */
  public const uint32 HASH_LENGTH;
  /**
   * The number of bytes in a hash generated by {@link Tox.hash}.
   */
  public static uint32 hash_length();
  /**
   * The number of bytes in a file id.
   */
  public const uint32 FILE_ID_LENGTH;
  /**
   * The number of bytes in a file id.
   */
  public static uint32 file_id_length();
  /**
   * Maximum file name length for file transfers.
   */
  [Version(deprecated = true, deprecated_since = "0.2.0", replacement = "max_filename_length")]
  public const uint32 MAX_FILENAME_LENGTH;
  /**
   * Maximum file name length for file transfers.
   */
  public static uint32 max_filename_length();

  /**
   * Represents the possible statuses a client can have.
   */
  [CCode(cname = "TOX_USER_STATUS", cprefix = "TOX_USER_STATUS_", has_type_id = false)]
  public enum UserStatus {
    /**
     * User is online and available.
     */
    NONE,
    /**
     * User is away. Clients can set this e.g. after a user defined
     * inactivity time.
     */
    AWAY,
    /**
     * User is busy. Signals to other clients that this client does not
     * currently wish to communicate.
     */
    BUSY
  }

  /**
   * Represents message types for tox_friend_send_message and conference
   * messages.
   */
  [CCode(cname = "TOX_MESSAGE_TYPE", cprefix = "TOX_MESSAGE_TYPE_", has_type_id = false)]
  public enum MessageType {
    /**
     * Normal text message. Similar to PRIVMSG on IRC.
     */
    NORMAL,
    /**
     * A message describing an user action. This is similar to /me (CTCP ACTION)
     * on IRC.
     */
    ACTION
  }

  /**
   * Type of proxy used to connect to TCP relays.
   */
  [CCode(cname = "TOX_PROXY_TYPE", cprefix = "TOX_PROXY_TYPE_", has_type_id = false)]
  public enum ProxyType {
    /**
     * Don't use a proxy.
     */
    NONE,
    /**
     * HTTP proxy using CONNECT.
     */
    HTTP,
    /**
     * SOCKS proxy for simple socket pipes.
     */
    SOCKS5
  }

  /**
   * Type of savedata to create the Tox instance from.
   */
  [CCode(cname = "TOX_SAVEDATA_TYPE", cprefix = "TOX_SAVEDATA_TYPE_", has_type_id = false)]
  public enum SaveDataType {
    /**
     * No savedata.
     */
    NONE,
    /**
     * Savedata is one that was obtained from {@link Tox.get_savedata}.
     */
    TOX_SAVE,
    /**
     * Savedata is a secret key of length {@link SECRET_KEY_SIZE}.
     */
    SECRET_KEY
  }

  /**
   * Severity level of log messages.
   */
  [CCode(cname = "TOX_LOG_LEVEL", cprefix = "TOX_LOG_LEVEL_", has_type_id = false)]
  public enum LogLevel {
    /**
     * Very detailed traces including all network activity.
     */
    TRACE,
    /**
     * Debug messages such as which port we bind to.
     */
    DEBUG,
    /**
     * Informational log messages such as video call status changes.
     */
    INFO,
    /**
     * Warnings about internal inconsistency or logic errors.
     */
    WARNING,
    /**
     * Severe unexpected errors caused by external or internal inconsistency.
     */
    ERROR
  }

  /**
   * This event is triggered when the toxcore library logs an internal message.
   * This is mostly useful for debugging. This callback can be called from any
   * function, not just {@link Tox.iterate}. This means the user data lifetime must at
   * least extend between registering and unregistering it or tox_kill.
   *
   * Other toxcore modules such as toxav may concurrently call this callback at
   * any time. Thus, user code must make sure it is equipped to handle concurrent
   * execution, e.g. by employing appropriate mutex locking.
   *
   * @param level The severity of the log message.
   * @param file The source file from which the message originated.
   * @param line The source line from which the message originated.
   * @param func The function from which the message originated.
   * @param message The log message.
   */
  [CCode(cname = "tox_log_cb")]
  public delegate void LogCallback(Tox self, LogLevel level, string file, uint32 line, string func, string message);

  /**
   * This struct contains all the startup options for Tox.
   *
   * WARNING: Although this struct happens to be visible in the API, it is
   * effectively private. Do not allocate this yourself or access members
   * directly, as it *will* break binary compatibility frequently.
   */
  [CCode(cname = "struct Tox_Options", destroy_function = "tox_options_free", has_type_id = false)]
  [Compact]
  public class Options {
    /**
     * Allocates a new {@link Options} object and initialises it with the default
     * options. This function can be used to preserve long term ABI compatibility by
     * giving the responsibility of allocation and deallocation to the Tox library.
     *
     * @return A new {@link Options} object with default options or NULL on failure.
     */
    public Options(out ErrOptionsNew error);
    /**
     * The type of socket to create.
     *
     * If this is set to false, an IPv4 socket is created, which subsequently
     * only allows IPv4 communication.
     * If it is set to true, an IPv6 socket is created, allowing both IPv4 and
     * IPv6 communication.
     */
    public bool ipv6_enabled {
      [CCode(cname = "tox_options_get_ipv6_enabled")] get;
      [CCode(cname = "tox_options_set_ipv6_enabled")] set;
    }
    /**
     * Enable the use of UDP communication when available.
     *
     * Setting this to false will force Tox to use TCP only. Communications will
     * need to be relayed through a TCP relay node, potentially slowing them down.
     * Disabling UDP support is necessary when using anonymous proxies or Tor.
     */
    public bool udp_enabled {
      [CCode(cname = "tox_options_get_udp_enabled")] get;
      [CCode(cname = "tox_options_set_udp_enabled")] set;
    }
    /**
     * Enable local network peer discovery.
     *
     * Disabling this will cause Tox to not look for peers on the local network.
     */
    public bool local_discovery_enabled {
      [CCode(cname = "tox_options_get_local_discovery_enabled")] get;
      [CCode(cname = "tox_options_set_local_discovery_enabled")] set;
    }
    /**
     * Pass communications through a proxy.
     */
    public ProxyType proxy_type {
      [CCode(cname = "tox_options_get_proxy_type")] get;
      [CCode(cname = "tox_options_set_proxy_type")] set;
    }
    /**
     * The IP address or DNS name of the proxy to be used.
     *
     * If used, this must be non-NULL and be a valid DNS name. The name must not
     * exceed 255 characters, and be in a NUL-terminated C string format
     * (255 chars + 1 NUL byte).
     *
     * This member is ignored (it can be NULL) if proxy_type is {@link ProxyType.NONE}.
     *
     * The data pointed at by this member is owned by the user, so must
     * outlive the options object.
     */
    public string? proxy_host {
      [CCode(cname = "tox_options_get_proxy_host")] get;
      [CCode(cname = "tox_options_set_proxy_host")] set;
    }
    /**
     * The port to use to connect to the proxy server.
     *
     * Ports must be in the range (1, 65535). The value is ignored if
     * proxy_type is {@link ProxyType.NONE}.
     */
    public uint16 proxy_port {
      [CCode(cname = "tox_options_get_proxy_port")] get;
      [CCode(cname = "tox_options_set_proxy_port")] set;
    }
    /**
     * The start port of the inclusive port range to attempt to use.
     *
     * If both start_port and end_port are 0, the default port range will be
     * used: [33445, 33545].
     *
     * If either start_port or end_port is 0 while the other is non-zero, the
     * non-zero port will be the only port in the range.
     *
     * Having start_port > end_port will yield the same behavior as if start_port
     * and end_port were swapped.
     */
    public uint16 start_port {
      [CCode(cname = "tox_options_get_start_port")] get;
      [CCode(cname = "tox_options_set_start_port")] set;
    }
    /**
     * The end port of the inclusive port range to attempt to use.
     */
    public uint16 end_port {
      [CCode(cname = "tox_options_get_end_port")] get;
      [CCode(cname = "tox_options_set_end_port")] set;
    }
    /**
     * The port to use for the TCP server (relay). If 0, the TCP server is
     * disabled.
     *
     * Enabling it is not required for Tox to function properly.
     *
     * When enabled, your Tox instance can act as a TCP relay for other Tox
     * instance. This leads to increased traffic, thus when writing a client
     * it is recommended to enable TCP server only if the user has an option
     * to disable it.
     */
    public uint16 tcp_port {
      [CCode(cname = "tox_options_get_tcp_port")] get;
      [CCode(cname = "tox_options_set_tcp_port")] set;
    }
    /**
     * Enables or disables UDP hole-punching in toxcore. (Default: enabled).
     */
    public bool hole_punching_enabled {
      [CCode(cname = "tox_options_get_hole_punching_enabled")] get;
      [CCode(cname = "tox_options_set_hole_punching_enabled")] set;
    }
    /**
     * The type of savedata to load from.
     */
    public SaveDataType savedata_type {
      [CCode(cname = "tox_options_get_savedata_type")] get;
      [CCode(cname = "tox_options_set_savedata_type")] set;
    }
    [CCode(cname = "tox_options_get_savedata_length")]
    private size_t _get_savedata_length();
    [CCode(cname = "tox_options_get_savedata_data", array_length = false)]
    private uint8[] _get_savedata_data();
    [CCode(cname = "vala_tox_options_get_savedata_data")]
    /**
     * The savedata.
     *
     * The data pointed at by this member is owned by the user, so must
     * outlive the options object.
     */
    public uint8[] get_savedata_data() {
      var t = new uint8[_get_savedata_length()];
      GLib.Memory.copy(t, _get_savedata_data(), t.length);
      return t;
    }
    public void set_savedata_data(uint8[] data);

    //FIXME either report this upstream or find some awkard means to fix this until 0.3.0
    /**
     * Logging callback for the new tox instance.
     */
    [CCode(delegate_target_cname = "log_user_data")]
    public unowned LogCallback log_callback;

    /**
     * Initialises a {@link Options} object with the default options.
     *
     * The result of this function is independent of the original options. All
     * values will be overwritten, no values will be read (so it is permissible
     * to pass an uninitialised object).
     */
    public void default ();
  }

  [CCode(cname = "TOX_ERR_OPTIONS_NEW", cprefix = "TOX_ERR_OPTIONS_NEW_", has_type_id = false)]
  public enum ErrOptionsNew {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The function failed to allocate enough memory for the options struct.
     */
    MALLOC
  }

  [CCode(cname = "TOX_ERR_NEW", cprefix = "TOX_ERR_NEW_", has_type_id = false)]
  public enum ErrNew {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The function was unable to allocate enough memory to store the internal
     * structures for the Tox object.
     */
    MALLOC,
    /**
     * The function was unable to bind to a port. This may mean that all ports
     * have already been bound, e.g. by other Tox instances, or it may mean
     * a permission error. You may be able to gather more information from errno.
     */
    PORT_ALLOC,
    /**
     * proxy_type was invalid.
     */
    PROXY_BAD_TYPE,
    /**
     * proxy_type was valid but the proxy_host passed had an invalid format
     * or was NULL.
     */
    PROXY_BAD_HOST,
    /**
     * proxy_type was valid, but the proxy_port was invalid.
     */
    PROXY_BAD_PORT,
    /**
     * The proxy address passed could not be resolved.
     */
    PROXY_NOT_FOUND,
    /**
     * The byte array to be loaded contained an encrypted save.
     */
    LOAD_ENCRYPTED,
    /**
     * The data format was invalid. This can happen when loading data that was
     * saved by an older version of Tox, or when the data has been corrupted.
     * When loading from badly formatted data, some data may have been loaded,
     * and the rest is discarded. Passing an invalid length parameter also
     * causes this error.
     */
    LOAD_BAD_FORMAT
  }

  [CCode(cname = "TOX_ERR_BOOTSTRAP", cprefix = "TOX_ERR_BOOTSTRAP_", has_type_id = false)]
  public enum ErrBootstrap {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The address could not be resolved to an IP address, or the IP address
     * passed was invalid.
     */
    BAD_HOST,
    /**
     * The port passed was invalid. The valid port range is (1, 65535).
     */
    BAD_PORT
  }

  /**
   * Protocols that can be used to connect to the network or friends.
   */
  [CCode(cname = "TOX_CONNECTION", cprefix = "TOX_CONNECTION_", has_type_id = false)]
  public enum Connection {
    /**
     * There is no connection. This instance, or the friend the state change is
     * about, is now offline.
     */
    NONE,
    /**
     * A TCP connection has been established. For the own instance, this means it
     * is connected through a TCP relay, only. For a friend, this means that the
     * connection to that particular friend goes through a TCP relay.
     */
    TCP,
    /**
     * A UDP connection has been established. For the own instance, this means it
     * is able to send UDP packets to DHT nodes, but may still be connected to
     * a TCP relay. For a friend, this means that the connection to that
     * particular friend was built using direct UDP packets.
     */
    UDP
  }

  /**
   * Common error codes for all functions that set a piece of user-visible
   * client information.
   */
  [CCode(cname = "TOX_ERR_SET_INFO", cprefix = "TOX_ERR_SET_INFO_", has_type_id = false)]
  public enum ErrSetInfo {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * Information length exceeded maximum permissible size.
     */
    TOO_LONG
  }

  [CCode(cname = "TOX_ERR_FRIEND_ADD", cprefix = "TOX_ERR_FRIEND_ADD_", has_type_id = false)]
  public enum ErrFriendAdd {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The length of the friend request message exceeded
     * {@link MAX_FRIEND_REQUEST_LENGTH}.
     */
    TOO_LONG,
    /**
     * The friend request message was empty. This, and the TOO_LONG code will
     * never be returned from {@link Tox.friend_add_norequest}.
     */
    NO_MESSAGE,
    /**
     * The friend address belongs to the sending client.
     */
    OWN_KEY,
    /**
     * A friend request has already been sent, or the address belongs to a friend
     * that is already on the friend list.
     */
    ALREADY_SENT,
    /**
     * The friend address checksum failed.
     */
    BAD_CHECKSUM,
    /**
     * The friend was already there, but the nospam value was different.
     */
    SET_NEW_NOSPAM,
    /**
     * A memory allocation failed when trying to increase the friend list size.
     */
    MALLOC
  }

  [CCode(cname = "TOX_ERR_FRIEND_DELETE", cprefix = "TOX_ERR_FRIEND_DELETE_", has_type_id = false)]
  public enum ErrFriendDelete {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * There was no friend with the given friend number. No friends were deleted.
     */
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_BY_PUBLIC_KEY", cprefix = "TOX_ERR_FRIEND_BY_PUBLIC_KEY_", has_type_id = false)]
  public enum ErrFriendByPublicKey {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * No friend with the given Public Key exists on the friend list.
     */
    NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_GET_PUBLIC_KEY", cprefix = "TOX_ERR_FRIEND_GET_PUBLIC_KEY_", has_type_id = false)]
  public enum ErrFriendGetPublicKey {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * No friend with the given number exists on the friend list.
     */
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_GET_LAST_ONLINE", cprefix = "TOX_ERR_FRIEND_GET_LAST_ONLINE_", has_type_id = false)]
  public enum ErrFriendGetLastOnline {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * No friend with the given number exists on the friend list.
     */
    FRIEND_NOT_FOUND
  }

  /**
   * Common error codes for friend state query functions.
   */
  [CCode(cname = "TOX_ERR_FRIEND_QUERY", cprefix = "TOX_ERR_FRIEND_QUERY_", has_type_id = false)]
  public enum ErrFriendQuery {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The pointer parameter for storing the query result (name, message) was
     * NULL. Unlike the `_self_` variants of these functions, which have no effect
     * when a parameter is NULL, these functions return an error in that case.
     */
    NULL,
    /**
     * The friend_number did not designate a valid friend.
     */
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_SET_TYPING", cprefix = "TOX_ERR_SET_TYPING_", has_type_id = false)]
  public enum ErrSetTyping {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The friend number did not designate a valid friend.
     */
    FRIEND_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_SEND_MESSAGE", cprefix = "TOX_ERR_FRIEND_SEND_MESSAGE_", has_type_id = false)]
  public enum ErrFriendSendMessage {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The friend number did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * This client is currently not connected to the friend.
     */
    FRIEND_NOT_CONNECTED,
    /**
     * An allocation error occurred while increasing the send queue size.
     */
    SENDQ,
    /**
     * Message length exceeded {@link MAX_MESSAGE_LENGTH}.
     */
    TOO_LONG,
    /**
     * Attempted to send a zero-length message.
     */
    EMPTY
  }

  [CCode(cname = "int", cprefix = "TOX_FILE_KIND_", has_type_id = false)]
  public enum FileKind {
    /**
     * Arbitrary file data. Clients can choose to handle it based on the file name
     * or magic or any other way they choose.
     */
    DATA,
    /**
     * Avatar file_id. This consists of {@link Tox.hash}(image).
     * Avatar data. This consists of the image data.
     *
     * Avatars can be sent at any time the client wishes. Generally, a client will
     * send the avatar to a friend when that friend comes online, and to all
     * friends when the avatar changed. A client can save some traffic by
     * remembering which friend received the updated avatar already and only send
     * it if the friend has an out of date avatar.
     *
     * Clients who receive avatar send requests can reject it (by sending
     * {@link FileControl.CANCEL} before any other controls), or accept it (by
     * sending {@link FileControl.RESUME}). The file_id of length {@link HASH_LENGTH} bytes
     * (same length as {@link FILE_ID_LENGTH}) will contain the hash. A client can compare
     * this hash with a saved hash and send {@link FileControl.CANCEL} to terminate the avatar
     * transfer if it matches.
     *
     * When file_size is set to 0 in the transfer request it means that the client
     * has no avatar.
     */
    AVATAR
  }

  [CCode(cname = "TOX_FILE_CONTROL", cprefix = "TOX_FILE_CONTROL_", has_type_id = false)]
  public enum FileControl {
    /**
     * Sent by the receiving side to accept a file send request. Also sent after a
     * {@link FileControl.PAUSE} command to continue sending or receiving.
     */
    RESUME,
    /**
     * Sent by clients to pause the file transfer. The initial state of a file
     * transfer is always paused on the receiving side and running on the sending
     * side. If both the sending and receiving side pause the transfer, then both
     * need to send {@link FileControl.RESUME} for the transfer to resume.
     */
    PAUSE,
    /**
     * Sent by the receiving side to reject a file send request before any other
     * commands are sent. Also sent by either side to terminate a file transfer.
     */
    CANCEL
  }

  [CCode(cname = "TOX_ERR_FILE_CONTROL", cprefix = "TOX_ERR_FILE_CONTROL_", has_type_id = false)]
  public enum ErrFileControl {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * This client is currently not connected to the friend.
     */
    FRIEND_NOT_CONNECTED,
    /**
     * No file transfer with the given file number was found for the given friend.
     */
    NOT_FOUND,
    /**
     * A RESUME control was sent, but the file transfer is running normally.
     */
    NOT_PAUSED,
    /**
     * A RESUME control was sent, but the file transfer was paused by the other
     * party. Only the party that paused the transfer can resume it.
     */
    DENIED,
    /**
     * A PAUSE control was sent, but the file transfer was already paused.
     */
    ALREADY_PAUSED,
    /**
     * Packet queue is full.
     */
    SENDQ
  }

  [CCode(cname = "TOX_ERR_FILE_SEEK", cprefix = "TOX_ERR_FILE_SEEK_", has_type_id = false)]
  public enum ErrFileSeek {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * This client is currently not connected to the friend.
     */
    FRIEND_NOT_CONNECTED,
    /**
     * No file transfer with the given file number was found for the given friend.
     */
    NOT_FOUND,
    /**
     * File was not in a state where it could be seeked.
     */
    DENIED,
    /**
     * Seek position was invalid
     */
    INVALID_POSITION,
    /**
     * Packet queue is full.
     */
    SENDQ
  }

  [CCode(cname = "TOX_ERR_FILE_GET", cprefix = "TOX_ERR_FILE_GET_", has_type_id = false)]
  public enum ErrFileGet {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * No file transfer with the given file number was found for the given friend.
     */
    NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FILE_SEND", cprefix = "TOX_ERR_FILE_SEND_", has_type_id = false)]
  public enum ErrFileSend {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * This client is currently not connected to the friend.
     */
    FRIEND_NOT_CONNECTED,
    /**
     * Filename length exceeded {@link MAX_FILENAME_LENGTH} bytes.
     */
    NAME_TOO_LONG,
    /**
     * Too many ongoing transfers. The maximum number of concurrent file transfers
     * is 256 per friend per direction (sending and receiving).
     */
    TOO_MANY
  }

  [CCode(cname = "TOX_ERR_FILE_SEND_CHUNK", cprefix = "TOX_ERR_FILE_SEND_CHUNK_", has_type_id = false)]
  public enum ErrFileSendChunk {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The length parameter was non-zero, but data was NULL.
     */
    NULL,
    /**
     * The friend_number passed did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * This client is currently not connected to the friend.
     */
    FRIEND_NOT_CONNECTED,
    /**
     * No file transfer with the given file number was found for the given friend.
     */
    NOT_FOUND,
    /**
     * File transfer was found but isn't in a transferring state: (paused, done,
     * broken, etc...) (happens only when not called from the request chunk callback).
     */
    NOT_TRANSFERRING,
    /**
     * Attempted to send more or less data than requested. The requested data size is
     * adjusted according to maximum transmission unit and the expected end of
     * the file. Trying to send less or more than requested will return this error.
     */
    INVALID_LENGTH,
    /**
     * Packet queue is full.
     */
    SENDQ,
    /**
     * Position parameter was wrong.
     */
    WRONG_POSITION
  }

  /**
   * Conference types for the conference_invite event.
   */
  [CCode(cname = "TOX_CONFERENCE_TYPE", cprefix = "TOX_CONFERENCE_TYPE_", has_type_id = false)]
  public enum ConferenceType {
    /**
     * Text-only conferences that must be accepted with the {@link Tox.conference_join} function.
     */
    TEXT,
    /**
     * Video conference. The function to accept these is in toxav.
     */
    AV
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_NEW", cprefix = "TOX_ERR_CONFERENCE_NEW_", has_type_id = false)]
  public enum ErrConferenceNew {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference instance failed to initialize.
     */
    INIT
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_DELETE", cprefix = "TOX_ERR_CONFERENCE_DELETE_", has_type_id = false)]
  public enum ErrConferenceDelete {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference number passed did not designate a valid conference.
     */
    CONFERENCE_NOT_FOUND
  }

  /**
   * Error codes for peer info queries.
   */
  [CCode(cname = "TOX_ERR_CONFERENCE_PEER_QUERY", cprefix = "TOX_ERR_CONFERENCE_PEER_QUERY_", has_type_id = false)]
  public enum ErrConferencePeerQuery {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference number passed did not designate a valid conference.
     */
    CONFERENCE_NOT_FOUND,
    /**
     * The peer number passed did not designate a valid peer.
     */
    PEER_NOT_FOUND,
    /**
     * The client is not connected to the conference.
     */
    NO_CONNECTION
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_INVITE", cprefix = "TOX_ERR_CONFERENCE_INVITE_", has_type_id = false)]
  public enum ErrConferenceInvite {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference number passed did not designate a valid conference.
     */
    CONFERENCE_NOT_FOUND,
    /**
     * The invite packet failed to send.
     */
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_JOIN", cprefix = "TOX_ERR_CONFERENCE_JOIN_", has_type_id = false)]
  public enum ErrConferenceJoin {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The cookie passed has an invalid length.
     */
    INVALID_LENGTH,
    /**
     * The conference is not the expected type. This indicates an invalid cookie.
     */
    WRONG_TYPE,
    /**
     * The friend number passed does not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * Client is already in this conference.
     */
    DUPLICATE,
    /**
     * Conference instance failed to initialize.
     */
    INIT_FAIL,
    /**
     * The join packet failed to send.
     */
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_SEND_MESSAGE", cprefix = "TOX_ERR_CONFERENCE_SEND_MESSAGE_", has_type_id = false)]
  public enum ErrConferenceSendMessage {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference number passed did not designate a valid conference.
     */
    CONFERENCE_NOT_FOUND,
    /**
     * The message is too long.
     */
    TOO_LONG,
    /**
     * The client is not connected to the conference.
     */
    NO_CONNECTION,
    /**
     * The message packet failed to send.
     */
    FAIL_SEND
  }

  [CCode(cname = "TOX_ERR_CONFERENCE_TITLE", cprefix = "TOX_ERR_CONFERENCE_TITLE_", has_type_id = false)]
  public enum ErrConferenceTitle {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference number passed did not designate a valid conference.
     */
    CONFERENCE_NOT_FOUND,
    /**
     * The title is too long or empty.
     */
    INVALID_LENGTH,
    /**
     * The title packet failed to send.
     */
    FAIL_SEND
  }

  /**
   * Returns the type of conference ({@link ConferenceType}) that conference_number is. Return value is
   * unspecified on failure.
   */
  [CCode(cname = "TOX_ERR_CONFERENCE_GET_TYPE", cprefix = "TOX_ERR_CONFERENCE_GET_TYPE_", has_type_id = false)]
  public enum ErrConferenceGetType {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The conference number passed did not designate a valid conference.
     */
    CONFERENCE_NOT_FOUND
  }

  [CCode(cname = "TOX_ERR_FRIEND_CUSTOM_PACKET", cprefix = "TOX_ERR_FRIEND_CUSTOM_PACKET_", has_type_id = false)]
  public enum ErrFriendCustomPacket {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The friend number did not designate a valid friend.
     */
    FRIEND_NOT_FOUND,
    /**
     * This client is currently not connected to the friend.
     */
    FRIEND_NOT_CONNECTED,
    /**
     * The first byte of data was not in the specified range for the packet type.
     * This range is 200-254 for lossy, and 160-191 for lossless packets.
     */
    INVALID,
    /**
     * Attempted to send an empty packet.
     */
    EMPTY,
    /**
     * Packet data length exceeded {@link MAX_CUSTOM_PACKET_SIZE}.
     */
    TOO_LONG,
    /**
     * Packet queue is full.
     */
    SENDQ
  }

  [CCode(cname = "TOX_ERR_GET_PORT", cprefix = "TOX_ERR_GET_PORT_", has_type_id = false)]
  public enum ErrGetPort {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * The instance was not bound to any port.
     */
    NOT_BOUND
  }

  /**
   * The Tox instance type. All the state associated with a connection is held
   * within the instance. Multiple instances can exist and operate concurrently.
   * The maximum number of Tox instances that can exist on a single network
   * device is limited. Note that this is not just a per-process limit, since the
   * limiting factor is the number of usable ports on a device.
   */
  [CCode(cname = "Tox", free_function = "tox_kill", cprefix = "tox_", has_type_id = false)]
  [Compact]
  public class Tox {
    /**
     * Creates and initialises a new Tox instance with the options passed.
     *
     * This function will bring the instance into a valid state. Running the event
     * loop with a new instance will operate correctly.
     *
     * If loading failed or succeeded only partially, the new or partially loaded
     * instance is returned and an error code is set.
     *
     * @param options An options object as described above. If this parameter is
     *   NULL, the default options are used.
     *
     * @return A new Tox instance pointer on success or NULL on failure.
     */
    public Tox(Options? options = null, out ErrNew error);

    [CCode(cname = "tox_get_savedata_size")]
    private size_t _get_savedata_size();
    [CCode(cname = "tox_get_savedata")]
    private void _get_savedata([CCode(array_length = false)] uint8[] data);

    /**
     * Store all information associated with the tox instance to a byte array.
     */
    [CCode(cname = "vala_tox_get_savedata")]
    public uint8[] get_savedata() {
      var t = new uint8[_get_savedata_size()];
      _get_savedata(t);
      return t;
    }

    /**
     * Sends a "get nodes" request to the given bootstrap node with IP, port, and
     * public key to setup connections.
     *
     * This function will attempt to connect to the node using UDP. You must use
     * this function even if {@link Options.udp_enabled} was set to false.
     *
     * @param address The hostname or IP address (IPv4 or IPv6) of the node.
     * @param port The port on the host on which the bootstrap Tox instance is
     *   listening.
     * @param public_key The long term public key of the bootstrap node
     *   ({@link PUBLIC_KEY_SIZE} bytes).
     * @return true on success.
     */
    public bool bootstrap(string address,
                          uint16 port,
                          [CCode(array_length = false)] uint8[] public_key,
                          out ErrBootstrap error);

    /**
     * Adds additional host:port pair as TCP relay.
     *
     * This function can be used to initiate TCP connections to different ports on
     * the same bootstrap node, or to add TCP relays without using them as
     * bootstrap nodes.
     *
     * @param address The hostname or IP address (IPv4 or IPv6) of the TCP relay.
     * @param port The port on the host on which the TCP relay is listening.
     * @param public_key The long term public key of the TCP relay
     *   ({@link PUBLIC_KEY_SIZE} bytes).
     * @return true on success.
     */
    public bool add_tcp_relay(string address,
                              uint16 port,
                              [CCode(array_length = false)] uint8[] public_key,
                              out ErrBootstrap error);

    /**
     * Return whether we are connected to the DHT. The return value is equal to the
     * last value received through the `self_connection_status` callback.
     */
    [Version(deprecated = true, deprecated_since = "0.2.0")]
    public Connection self_get_connection_status();

    /**
     * @param connection_status Whether we are connected to the DHT.
     */
    [CCode(cname = "tox_self_connection_status_cb", has_target = false, has_type_id = false)]
    public delegate void SelfConnectionStatusCallback (Tox self, Connection connection_status, void *user_data);

    /**
     * Set the callback for the `self_connection_status` event. Pass NULL to unset.
     *
     * This event is triggered whenever there is a change in the DHT connection
     * state. When disconnected, a client may choose to call {@link Tox.bootstrap} again, to
     * reconnect to the DHT. Note that this state may frequently change for short
     * amounts of time. Clients should therefore not immediately bootstrap on
     * receiving a disconnect.
     *
     * TODO(iphydf): how long should a client wait before bootstrapping again?
     */
    public void callback_self_connection_status(SelfConnectionStatusCallback callback);

    /**
     * Return the time in milliseconds before {@link iterate} should be called again
     * for optimal performance.
     */
    public uint32 iteration_interval();

    /**
     * The main loop that needs to be run in intervals of {@link iteration_interval}
     * milliseconds.
     */
    public void iterate(void* user_data);

    [CCode(cname = "tox_self_get_address")]
    private void _self_get_address([CCode(array_length = false)] uint8[] data);

    /**
     * Writes the Tox friend address of the client to a byte array. The address is
     * not in human-readable format. If a client wants to display the address,
     * formatting is required.
     */
    [CCode(cname = "vala_tox_self_get_address")]
    public uint8[] self_get_address() {
      var t = new uint8[address_size()];
      _self_get_address(t);
      return t;
    }

    /**
     * The 4-byte nospam part of the address. This value is expected in host
     * byte order. I.e. 0x12345678 will form the bytes [12, 34, 56, 78] in the
     * nospam part of the Tox friend address.
     */
    public uint32 self_nospam {
      [CCode(cname = "tox_self_get_nospam")] get;
      [CCode(cname = "tox_self_set_nospam")] set;
    }

    [CCode(cname = "tox_self_get_public_key")]
    private void _self_get_public_key([CCode(array_length = false)] uint8[] public_key);

    /**
     * Copy the Tox Public Key (long term) from the Tox object.
     */
    [CCode(cname = "vala_tox_self_get_public_key")]
    public uint8[] self_get_public_key() {
      var t = new uint8[public_key_size()];
      _self_get_public_key(t);
      return t;
    }

    [CCode(cname = "tox_self_get_secret_key")]
    private void _self_get_secret_key([CCode(array_length = false)] uint8[] secret_key);

    /**
     * Copy the Tox Secret Key from the Tox object.
     */
    [CCode(cname = "vala_tox_self_get_secret_key")]
    public uint8[] self_get_secret_key() {
      var t = new uint8[secret_key_size()];
      _self_get_secret_key(t);
      return t;
    }

    [CCode(cname = "tox_self_set_name")]
    private bool _self_set_name(uint8[] name, out ErrSetInfo error);

    /**
     * Set the nickname for the Tox client.
     *
     * Nickname length cannot exceed {@link MAX_NAME_LENGTH}. If length is 0, the name
     * parameter is ignored (it can be NULL), and the nickname is set back to empty.
     *
     * @param name A string containing the new nickname.
     *
     * @return true on success.
     */
    [CCode(cname = "vala_tox_self_set_name")]
    public bool self_set_name(string name, out ErrSetInfo error) {
      return _self_set_name(name.data, out error);
    }

    [CCode(cname = "tox_self_get_name_size")]
    private size_t _self_get_name_size();
    [CCode(cname = "tox_self_get_name")]
    private void _self_get_name([CCode(array_length = false)] uint8[] name);

    /**
     * Write the nickname set by {@link Tox.self_set_name} to a byte array.
     *
     * If no nickname was set before calling this function, the name is empty,
     * and this function has no effect.
     */
    [CCode(cname = "vala_tox_self_get_name")]
    public string self_get_name() {
      var t = new uint8[_self_get_name_size() + 1];
      _self_get_name(t);
      return (string) t;
    }

    [CCode(cname = "tox_self_set_status_message")]
    private bool _self_set_status_message(uint8[] message, out ErrSetInfo error);

    /**
     * Set the client's status message.
     *
     * Status message length cannot exceed {@link MAX_STATUS_MESSAGE_LENGTH}. If
     * length is 0, the status parameter is ignored (it can be NULL), and the
     * user status is set back to empty.
     */
    [CCode(cname = "vala_tox_self_set_status_message")]
    public bool self_set_status_message(string message, out ErrSetInfo error) {
      return _self_set_status_message(message.data, out error);
    }

    [CCode(cname = "tox_self_get_status_message_size")]
    private size_t _self_get_status_message_size();
    [CCode(cname = "tox_self_get_status_message")]
    private void _self_get_status_message([CCode(array_length = false)] uint8[] status_message);

    /**
     * Write the status message set by {@link Tox.self_set_status_message} to a byte array.
     *
     * If no status message was set before calling this function, the status is
     * empty, and this function has no effect.
     */
    [CCode(cname = "vala_tox_self_get_status_message")]
    public string self_get_status_message() {
      var t = new uint8[_self_get_status_message_size() + 1];
      _self_get_status_message(t);
      return (string) t;
    }

    /**
     * The client's user status.
     */
    public UserStatus self_status {
      [CCode(cname = "tox_self_get_status")] get;
      [CCode(cname = "tox_self_set_status")] set;
    }

    [CCode(cname = "tox_friend_add")]
    private uint32 _friend_add([CCode(array_length = false)] uint8[] address, uint8[] message, out ErrFriendAdd error);
    /**
     * Add a friend to the friend list and send a friend request.
     *
     * A friend request message must be at least 1 byte long and at most
     * {@link MAX_FRIEND_REQUEST_LENGTH}.
     *
     * Friend numbers are unique identifiers used in all functions that operate on
     * friends. Once added, a friend number is stable for the lifetime of the Tox
     * object. After saving the state and reloading it, the friend numbers may not
     * be the same as before. Deleting a friend creates a gap in the friend number
     * set, which is filled by the next adding of a friend. Any pattern in friend
     * numbers should not be relied on.
     *
     * If more than INT32_MAX friends are added, this function causes undefined
     * behaviour.
     *
     * @param address The address of the friend (returned by {@link Tox.self_get_address} of
     *   the friend you wish to add) it must be {@link ADDRESS_SIZE} bytes.
     * @param message The message that will be sent along with the friend request.
     *
     * @return the friend number on success, {@link uint32.MAX} on failure.
     */
    [CCode(cname = "vala_tox_friend_add")]
    public uint32 friend_add(uint8[] address, string message, out ErrFriendAdd error) {
      return _friend_add(address, message.data, out error);
    }

    /**
     * Add a friend without sending a friend request.
     *
     * This function is used to add a friend in response to a friend request. If the
     * client receives a friend request, it can be reasonably sure that the other
     * client added this client as a friend, eliminating the need for a friend
     * request.
     *
     * This function is also useful in a situation where both instances are
     * controlled by the same entity, so that this entity can perform the mutual
     * friend adding. In this case, there is no need for a friend request, either.
     *
     * @param public_key A byte array of length {@link PUBLIC_KEY_SIZE} containing the
     *   Public Key (not the Address) of the friend to add.
     *
     * @return the friend number on success, UINT32_MAX on failure.
     * see {@link Tox.friend_add} for a more detailed description of friend numbers.
     */
    public uint32 friend_add_norequest([CCode(array_length = false)] uint8[] public_key, out ErrFriendAdd error);

    /**
     * Remove a friend from the friend list.
     *
     * This does not notify the friend of their deletion. After calling this
     * function, this client will appear offline to the friend and no communication
     * can occur between the two.
     *
     * @param friend_number Friend number for the friend to be deleted.
     *
     * @return true on success.
     */
    public bool friend_delete(uint32 friend_number, out ErrFriendDelete error);

    /**
     * Return the friend number associated with that Public Key.
     *
     * @return the friend number on success, UINT32_MAX on failure.
     * @param public_key A byte array containing the Public Key.
     */
    public uint32 friend_by_public_key([CCode(array_length = false)] uint8[] public_key, out ErrFriendByPublicKey error);

    /**
     * Checks if a friend with the given friend number exists and returns true if
     * it does.
     */
    public bool friend_exists(uint32 friend_number);

    [CCode(cname = "tox_self_get_friend_list_size")]
    private size_t _self_get_friend_list_size();
    [CCode(cname = "tox_self_get_friend_list")]
    private void _self_get_friend_list([CCode(array_length = false)] uint32[] friend_list);
    /**
     * Copy a list of valid friend numbers into an array.
     */
    [CCode(cname = "vala_tox_self_get_friend_list")]
    public uint32[] self_get_friend_list() {
      var t = new uint32[_self_get_friend_list_size()];
      _self_get_friend_list(t);
      return t;
    }

    [CCode(cname = "tox_friend_get_public_key")]
    private bool _friend_get_public_key(uint32 friend_number, [CCode(array_length = false)] uint8[] public_key, out ErrFriendGetPublicKey error);

    /**
     * Returns the Public Key associated with a given friend number.
     *
     * @param friend_number The friend number you want the Public Key of.
     *
     * @return public_key on success.
     */
    [CCode(cname = "vala_tox_friend_get_public_key")]
    public uint8[] friend_get_public_key(uint32 friend_number, out ErrFriendGetPublicKey error) {
      var t = new uint8[public_key_size()];
      return (_friend_get_public_key(friend_number, t, out error) ? t : null);
    }

    /**
     * Return a unix-time timestamp of the last time the friend associated with a given
     * friend number was seen online. This function will return UINT64_MAX on error.
     *
     * @param friend_number The friend number you want to query.
     */
    public uint64 friend_get_last_online(uint32 friend_number, out ErrFriendGetLastOnline error);

    [CCode(cname = "tox_friend_get_name_size")]
    private size_t _friend_get_name_size(uint32 friend_number, out ErrFriendQuery error);
    [CCode(cname = "tox_friend_get_name")]
    private bool _friend_get_name(uint32 friend_number, [CCode(array_length = false)] uint8[] name, out ErrFriendQuery error);

    /**
     * Return the name of the friend designated by the given friend number.
     *
     * The data written to `name` is equal to the data received by the last
     * `friend_name` callback.
     *
     * @return friend_name on success.
     */
    [CCode(cname = "vala_tox_friend_get_name")]
    public string? friend_get_name(uint32 friend_number, out ErrFriendQuery error) {
      var len = _friend_get_name_size(friend_number, out error);
      if (error != ErrFriendQuery.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _friend_get_name(friend_number, t, out error) ? (string) t : null;
    }

    /**
     * @param friend_number The friend number of the friend whose name changed.
     * @param name A byte array containing the same data as
     *   {@link Tox.friend_get_name} would write to its `name` parameter.
     */
    [CCode(cname = "tox_friend_name_cb", has_target = false, has_type_id = false)]
    public delegate void FriendNameCallback (Tox self, uint32 friend_number, [CCode(array_length_type = "size_t")] uint8[] name, void *user_data);

    /**
     * Set the callback for the `friend_name` event. Pass NULL to unset.
     *
     * This event is triggered when a friend changes their name.
     */
    public void callback_friend_name(FriendNameCallback callback);

    [CCode(cname = "tox_friend_get_status_message_size")]
    private size_t _friend_get_status_message_size(uint32 friend_number, out ErrFriendQuery error);
    [CCode(cname = "tox_friend_get_status_message")]
    private bool _friend_get_status_message(uint32 friend_number, [CCode(array_length = false)] uint8[] status_message, out ErrFriendQuery error);

    /**
     * Return the status message of the friend designated by the given friend number.
     *
     * The string returned is equal to the string received by the last
     * `friend_status_message` callback.
     *
     * @return status_message on success.
     */
    [CCode(cname = "vala_tox_friend_get_status_message")]
    public string? friend_get_status_message(uint32 friend_number, out ErrFriendQuery error) {
      var len = _friend_get_status_message_size(friend_number, out error);
      if (error != ErrFriendQuery.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _friend_get_status_message(friend_number, t, out error) ? (string) t : null;
    }

    /**
     * @param friend_number The friend number of the friend whose status message
     *   changed.
     * @param message A string containing the same data as
     *   {@link Tox.friend_get_status_message} would write to its `status_message` parameter.
     */
    [CCode(cname = "tox_friend_status_message_cb", has_target = false, has_type_id = false)]
    public delegate void FriendStatusMessageCallback (Tox self, uint32 friend_number, [CCode(array_length_type = "size_t")] uint8[] message, void *user_data);
    /**
     * Set the callback for the `friend_status_message` event. Pass NULL to unset.
     *
     * This event is triggered when a friend changes their status message.
     */
    public void callback_friend_status_message(FriendStatusMessageCallback callback);

    /**
     * Return the friend's user status (away/busy/...). If the friend number is
     * invalid, the return value is unspecified.
     *
     * The status returned is equal to the last status received through the
     * `friend_status` callback.
     */
    [Version(deprecated = true, deprecated_since = "0.2.0")]
    public UserStatus friend_get_status(uint32 friend_number, out ErrFriendQuery error);

    /**
     * @param friend_number The friend number of the friend whose user status
     *   changed.
     * @param status The new user status.
     */
    [CCode(cname = "tox_friend_status_cb", has_target = false, has_type_id = false)]
    public delegate void FriendStatusCallback (Tox self, uint32 friend_number, UserStatus status, void *user_data);

    /**
     * Set the callback for the `friend_status` event. Pass NULL to unset.
     *
     * This event is triggered when a friend changes their user status.
     */
    public void callback_friend_status(FriendStatusCallback callback);

    /**
     * Check whether a friend is currently connected to this client.
     *
     * The result of this function is equal to the last value received by the
     * `friend_connection_status` callback.
     *
     * @param friend_number The friend number for which to query the connection
     *   status.
     *
     * @return the friend's connection status as it was received through the
     *   `friend_connection_status` event.
     */
    [Version(deprecated = true, deprecated_since = "0.2.0")]
    public Connection friend_get_connection_status(uint32 friend_number, out ErrFriendQuery error);

    /**
     * @param friend_number The friend number of the friend whose connection status
     *   changed.
     * @param connection_status The result of calling
     *   {@link Tox.friend_get_connection_status} on the passed friend_number.
     */
    [CCode(cname = "tox_friend_connection_status_cb", has_target = false, has_type_id = false)]
    public delegate void FriendConnectionStatusCallback (Tox self, uint32 friend_number, Connection connection_status, void* userdata);

    /**
     * Set the callback for the `friend_connection_status` event. Pass NULL to unset.
     *
     * This event is triggered when a friend goes offline after having been online,
     * or when a friend goes online.
     *
     * This callback is not called when adding friends. It is assumed that when
     * adding friends, their connection status is initially offline.
     */
    public void callback_friend_connection_status(FriendConnectionStatusCallback callback);

    /**
     * Check whether a friend is currently typing a message.
     *
     * @param friend_number The friend number for which to query the typing status.
     *
     * @return true if the friend is typing.
     * @return false if the friend is not typing, or the friend number was
     *   invalid. Inspect the error code to determine which case it is.
     */
    [Version(deprecated = true, deprecated_since = "0.2.0")]
    public bool friend_get_typing(uint32 friend_number, out ErrFriendQuery error);

    /**
     * @param friend_number The friend number of the friend who started or stopped
     *   typing.
     * @param is_typing The result of calling {@link Tox.friend_get_typing} on the passed
     *   friend_number.
     */
    [CCode(cname = "tox_friend_typing_cb", has_target = false, has_type_id = false)]
    public delegate void FriendTypingCallback (Tox self, uint32 friend_number, bool is_typing, void* userdata);

    /**
     * Set the callback for the `friend_typing` event. Pass NULL to unset.
     *
     * This event is triggered when a friend starts or stops typing.
     */
    public void callback_friend_typing(FriendTypingCallback callback);

    /**
     * Set the client's typing status for a friend.
     *
     * The client is responsible for turning it on or off.
     *
     * @param friend_number The friend to which the client is typing a message.
     * @param typing The typing status. True means the client is typing.
     *
     * @return true on success.
     */
    public bool self_set_typing(uint32 friend_number, bool typing, out ErrSetTyping error);

    [CCode(cname = "tox_friend_send_message")]
    private uint32 _friend_send_message(uint32 friend_number, MessageType type, [CCode(array_length_type = "size_t")] uint8[] message, out ErrFriendSendMessage error);

    /**
     * Send a text chat message to an online friend.
     *
     * This function creates a chat message packet and pushes it into the send
     * queue.
     *
     * The message length may not exceed {@link MAX_MESSAGE_LENGTH}. Larger messages
     * must be split by the client and sent as separate messages. Other clients can
     * then reassemble the fragments. Messages may not be empty.
     *
     * The return value of this function is the message ID. If a read receipt is
     * received, the triggered `friend_read_receipt` event will be passed this message ID.
     *
     * Message IDs are unique per friend. The first message ID is 0. Message IDs are
     * incremented by 1 each time a message is sent. If UINT32_MAX messages were
     * sent, the next message ID is 0.
     *
     * @param type Message type (normal, action, ...).
     * @param friend_number The friend number of the friend to send the message to.
     * @param message A non-NULL pointer to the first element of a byte array
     *   containing the message text.
     */
    [CCode(cname = "vala_tox_friend_send_message")]
    public uint32 friend_send_message(uint32 friend_number, MessageType type, string message, out ErrFriendSendMessage error) {
      return _friend_send_message(friend_number, type, message.data, out error);
    }

    /**
     * @param friend_number The friend number of the friend who received the message.
     * @param message_id The message ID as returned from {@link Tox.friend_send_message}
     *   corresponding to the message sent.
     */
    [CCode(cname = "tox_friend_read_receipt_cb", has_target = false, has_type_id = false)]
    public delegate void FriendReadReceiptCallback(Tox self, uint32 friend_number, uint32 message_id, void *user_data);

    /**
     * Set the callback for the `friend_read_receipt` event. Pass NULL to unset.
     *
     * This event is triggered when the friend receives the message sent with
     * {@link Tox.friend_send_message} with the corresponding message ID.
     */
    public void callback_friend_read_receipt(FriendReadReceiptCallback callback);

    /**
     * @param public_key The Public Key of the user who sent the friend request.
     * @param message The message they sent along with the request.
     */
    [CCode(cname = "tox_friend_request_cb", has_target = false, has_type_id = false)]
    public delegate void FriendRequestCallback(Tox self, [CCode(array_length = false)] uint8[] public_key, [CCode(array_length_type = "size_t")] uint8[] message, void *user_data);

    /**
     * Set the callback for the `friend_request` event. Pass NULL to unset.
     *
     * This event is triggered when a friend request is received.
     */
    public void callback_friend_request(FriendRequestCallback callback);

    /**
     * @param friend_number The friend number of the friend who sent the message.
     * @param message The message data they sent.
     */
    [CCode(cname = "tox_friend_message_cb", has_target = false, has_type_id = false)]
    public delegate void FriendMessageCallback(Tox self, uint32 friend_number, MessageType type, [CCode(array_length_type = "size_t")] uint8[] message, void *user_data);

    /**
     * Set the callback for the `friend_message` event. Pass NULL to unset.
     *
     * This event is triggered when a message from a friend is received.
     */
    public void callback_friend_message(FriendMessageCallback callback);

    [CCode(cname = "tox_hash")]
    private static bool _hash([CCode(array_length = false)] uint8[] hash, uint8[] data);

    /**
     * Generates a cryptographic hash of the given data.
     *
     * This function may be used by clients for any purpose, but is provided
     * primarily for validating cached avatars. This use is highly recommended to
     * avoid unnecessary avatar updates.
     *
     * This function is a wrapper to internal message-digest functions.
     *
     * @param data Data to be hashed or NULL.
     *
     * @return hash on success.
     */
    [CCode(cname = "vala_tox_hash")]
    public static uint8[] ? hash(uint8[] data) {
      var buf = new uint8[hash_length()];
      return _hash(buf, data) ? buf : null;
    }

    /**
     * Sends a file control command to a friend for a given file transfer.
     *
     * @param friend_number The friend number of the friend the file is being
     *   transferred to or received from.
     * @param file_number The friend-specific identifier for the file transfer.
     * @param control The control command to send.
     *
     * @return true on success.
     */
    public bool file_control(uint32 friend_number, uint32 file_number, FileControl control, out ErrFileControl error);

    /**
     * When receiving {@link FileControl.CANCEL}, the client should release the
     * resources associated with the file number and consider the transfer failed.
     *
     * @param friend_number The friend number of the friend who is sending the file.
     * @param file_number The friend-specific file number the data received is
     *   associated with.
     * @param control The file control command received.
     */
    [CCode(cname = "tox_file_recv_control_cb", has_target = false, has_type_id = false)]
    public delegate void FileRecvControlCallback(Tox self, uint32 friend_number, uint32 file_number, FileControl control, void *user_data);

    /**
     * Set the callback for the `file_recv_control` event. Pass NULL to unset.
     *
     * This event is triggered when a file control command is received from a
     * friend.
     */
    public void callback_file_recv_control(FileRecvControlCallback callback);

    /**
     * Sends a file seek control command to a friend for a given file transfer.
     *
     * This function can only be called to resume a file transfer right before
     * {@link FileControl.RESUME} is sent.
     *
     * @param friend_number The friend number of the friend the file is being
     *   received from.
     * @param file_number The friend-specific identifier for the file transfer.
     * @param position The position that the file should be seeked to.
     */
    public bool file_seek(uint32 friend_number, uint32 file_number, uint64 position, out ErrFileSeek error);

    [CCode(cname = "tox_file_get_file_id")]
    private bool _file_get_file_id(uint32 friend_number, uint32 file_number, [CCode(array_length = false)] uint8[] file_id, out ErrFileGet error);

    /**
     * Copy the file id associated to the file transfer to a byte array.
     *
     * @param friend_number The friend number of the friend the file is being
     *   transferred to or received from.
     * @param file_number The friend-specific identifier for the file transfer.
     *
     * @return file_id on success.
     */
    [CCode(cname = "vala_tox_file_get_file_id")]
    public uint8[] ? file_get_file_id(uint32 friend_number, uint32 file_number, out ErrFileGet error) {
      var buf = new uint8[file_id_length()];
      return _file_get_file_id(friend_number, file_number, buf, out error) ? buf : null;
    }

    [CCode(cname = "tox_file_send")]
    private uint32 _file_send(uint32 friend_number, uint32 kind, uint64 file_size, [CCode(array_length = false)] uint8[] ? file_id, uint8[] filename, out ErrFileSend error);

    /**
     * Send a file transmission request.
     *
     * Maximum filename length is {@link MAX_FILENAME_LENGTH} bytes. The filename
     * should generally just be a file name, not a path with directory names.
     *
     * If a non-UINT64_MAX file size is provided, it can be used by both sides to
     * determine the sending progress. File size can be set to UINT64_MAX for streaming
     * data of unknown size.
     *
     * File transmission occurs in chunks, which are requested through the
     * `file_chunk_request` event.
     *
     * When a friend goes offline, all file transfers associated with the friend are
     * purged from core.
     *
     * If the file contents change during a transfer, the behaviour is unspecified
     * in general. What will actually happen depends on the mode in which the file
     * was modified and how the client determines the file size.
     *
     *  * If the file size was increased
     *    * and sending mode was streaming (file_size = UINT64_MAX), the behaviour
     *      will be as expected.
     *    * and sending mode was file (file_size != UINT64_MAX), the
     *      file_chunk_request callback will receive length = 0 when Core thinks
     *      the file transfer has finished. If the client remembers the file size as
     *      it was when sending the request, it will terminate the transfer normally.
     *      If the client re-reads the size, it will think the friend cancelled the
     *      transfer.
     *  * If the file size was decreased
     *    * and sending mode was streaming, the behaviour is as expected.
     *    * and sending mode was file, the callback will return 0 at the new
     *      (earlier) end-of-file, signalling to the friend that the transfer was
     *      cancelled.
     *  * If the file contents were modified
     *    * at a position before the current read, the two files (local and remote)
     *      will differ after the transfer terminates.
     *    * at a position after the current read, the file transfer will succeed as
     *      expected.
     *    * In either case, both sides will regard the transfer as complete and
     *      successful.
     *
     * @param friend_number The friend number of the friend the file send request
     *   should be sent to.
     * @param kind The meaning of the file to be sent.
     * @param file_size Size in bytes of the file the client wants to send, UINT64_MAX if
     *   unknown or streaming.
     * @param file_id A file identifier of length {@link FILE_ID_LENGTH} that can be used to
     *   uniquely identify file transfers across core restarts. If NULL, a random one will
     *   be generated by core. It can then be obtained by using {@link Tox.file_get_file_id}().
     * @param filename Name of the file. Does not need to be the actual name. This
     *   name will be sent along with the file send request.
     *
     * @return A file number used as an identifier in subsequent callbacks. This
     *   number is per friend. File numbers are reused after a transfer terminates.
     *   On failure, this function returns UINT32_MAX. Any pattern in file numbers
     *   should not be relied on.
     */
    [CCode(cname = "vala_tox_file_send")]
    public uint32 file_send(uint32 friend_number, FileKind kind, uint64 file_size, uint8[] ? file_id, string filename, out ErrFileSend error) {
      GLib.assert(file_id == null || file_id.length == file_id_length());
      return _file_send(friend_number, kind, file_size, file_id, filename.data, out error);
    }
    /**
     * Send a chunk of file data to a friend.
     *
     * This function is called in response to the `file_chunk_request` callback. The
     * length parameter should be equal to the one received though the callback.
     * If it is zero, the transfer is assumed complete. For files with known size,
     * Core will know that the transfer is complete after the last byte has been
     * received, so it is not necessary (though not harmful) to send a zero-length
     * chunk to terminate. For streams, core will know that the transfer is finished
     * if a chunk with length less than the length requested in the callback is sent.
     *
     * @param friend_number The friend number of the receiving friend for this file.
     * @param file_number The file transfer identifier returned by {@link Tox.file_send}.
     * @param position The file or stream position from which to continue reading.
     * @return true on success.
     */
    public bool file_send_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data, out ErrFileSendChunk error);

    /**
     * If the length parameter is 0, the file transfer is finished, and the client's
     * resources associated with the file number should be released. After a call
     * with zero length, the file number can be reused for future file transfers.
     *
     * If the requested position is not equal to the client's idea of the current
     * file or stream position, it will need to seek. In case of read-once streams,
     * the client should keep the last read chunk so that a seek back can be
     * supported. A seek-back only ever needs to read from the last requested chunk.
     * This happens when a chunk was requested, but the send failed. A seek-back
     * request can occur an arbitrary number of times for any given chunk.
     *
     * In response to receiving this callback, the client should call the function
     * `{@link Tox.file_send_chunk}` with the requested chunk. If the number of bytes sent
     * through that function is zero, the file transfer is assumed complete. A
     * client must send the full length of data requested with this callback.
     *
     * @param friend_number The friend number of the receiving friend for this file.
     * @param file_number The file transfer identifier returned by {@link Tox.file_send}.
     * @param position The file or stream position from which to continue reading.
     * @param length The number of bytes requested for the current chunk.
     */
    [CCode(cname = "tox_file_chunk_request_cb", has_target = false, has_type_id = false)]
    public delegate void FileChunkRequestCallback(Tox self, uint32 friend_number, uint32 file_number, uint64 position, size_t length, void *user_data);

    /**
     * Set the callback for the `file_chunk_request` event. Pass NULL to unset.
     *
     * This event is triggered when Core is ready to send more file data.
     */
    public void callback_file_chunk_request(FileChunkRequestCallback callback);

    /**
     * The client should acquire resources to be associated with the file transfer.
     * Incoming file transfers start in the PAUSED state. After this callback
     * returns, a transfer can be rejected by sending a {@link FileControl.CANCEL}
     * control command before any other control commands. It can be accepted by
     * sending {@link FileControl.RESUME}.
     *
     * @param friend_number The friend number of the friend who is sending the file
     *   transfer request.
     * @param file_number The friend-specific file number the data received is
     *   associated with.
     * @param kind The meaning of the file to be sent.
     * @param file_size Size in bytes of the file the client wants to send,
     *   UINT64_MAX if unknown or streaming.
     * @param filename Name of the file. Does not need to be the actual name. This
     *   name will be sent along with the file send request.
     */
    [CCode(cname = "tox_file_recv_cb", has_target = false, has_type_id = false)]
    public delegate void FileRecvCallback(Tox self, uint32 friend_number, uint32 file_number, uint32 kind, uint64 file_size, [CCode(array_length_type = "size_t")] uint8[] filename, void *user_data);

    /**
     * Set the callback for the `file_recv` event. Pass NULL to unset.
     *
     * This event is triggered when a file transfer request is received.
     */
    public void callback_file_recv(FileRecvCallback callback);

    /**
     * When length is 0, the transfer is finished and the client should release the
     * resources it acquired for the transfer. After a call with length = 0, the
     * file number can be reused for new file transfers.
     *
     * If position is equal to file_size (received in the file_receive callback)
     * when the transfer finishes, the file was received completely. Otherwise, if
     * file_size was UINT64_MAX, streaming ended successfully when length is 0.
     *
     * @param friend_number The friend number of the friend who is sending the file.
     * @param file_number The friend-specific file number the data received is
     *   associated with.
     * @param position The file position of the first byte in data.
     * @param data A byte array containing the received chunk.
     */
    [CCode(cname = "tox_file_recv_chunk_cb", has_target = false, has_type_id = false)]
    public delegate void FileRecvChunkCallback(Tox self, uint32 friend_number, uint32 file_number, uint64 position, [CCode(array_length_type = "size_t")] uint8[] data, void* user_data);

    /**
     * Set the callback for the `file_recv_chunk` event. Pass NULL to unset.
     *
     * This event is first triggered when a file transfer request is received, and
     * subsequently when a chunk of file data for an accepted request was received.
     */
    public void callback_file_recv_chunk(FileRecvChunkCallback callback);

    /**
     * The invitation will remain valid until the inviting friend goes offline
     * or exits the conference.
     *
     * @param friend_number The friend who invited us.
     * @param type The conference type (text only or audio/video).
     * @param cookie A piece of data of variable length required to join the
     *   conference.
     */
    [CCode(cname = "tox_conference_invite_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceInviteCallback (Tox self, uint32 friend_number, ConferenceType type, [CCode(array_length_type = "size_t")] uint8[] cookie, void *user_data);

    /**
     * Set the callback for the `conference_invite` event. Pass NULL to unset.
     *
     * This event is triggered when the client is invited to join a conference.
     */
    public void callback_conference_invite(ConferenceInviteCallback callback);

    /**
     * @param conference_number The conference number of the conference the message is intended for.
     * @param peer_number The ID of the peer who sent the message.
     * @param type The type of message (normal, action, ...).
     * @param message The message data.
     */
    [CCode(cname = "tox_conference_message_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceMessageCallback (Tox self, uint32 conference_number, uint32 peer_number, MessageType type, [CCode(array_length_type = "size_t")] uint8[] message, void *user_data);

    /**
     * Set the callback for the `conference_message` event. Pass NULL to unset.
     *
     * This event is triggered when the client receives a conference message.
     */
    public void callback_conference_message(ConferenceMessageCallback callback);

    /**
     * @param conference_number The conference number of the conference the title change is intended for.
     * @param peer_number The ID of the peer who changed the title.
     * @param title The title data.
     */
    [CCode(cname = "tox_conference_title_cb", has_target = false, has_type_id = false)]
    public delegate void ConferenceTitleCallback (Tox self, uint32 conference_number, uint32 peer_number, [CCode(array_length_type = "size_t")] uint8[] title, void *user_data);

    /**
     * Set the callback for the `conference_title` event. Pass NULL to unset.
     *
     * This event is triggered when a peer changes the conference title.
     *
     * If peer_number == UINT32_MAX, then author is unknown (e.g. initial joining the conference).
     */
    public void callback_conference_title(ConferenceTitleCallback callback);

    /**
     * @since 0.2.0
     * @param conference_number The conference number of the conference the
     *   peer is in.
     * @param peer_number The ID of the peer who changed their nickname.
     * @param name A byte array containing the new nickname.
     */
    [Version(since = "0.2.0")]
    [CCode(cname = "tox_conference_peer_name_cb", has_target = false, has_type_id = false)]
    public delegate void ConferencePeerNameCallback(Tox self, uint32 conference_number, uint32 peer_number, [CCode(array_length_type = "size_t")] uint8[] name, void* user_data);

    /**
     * Set the callback for the `conference_peer_name` event. Pass NULL to unset.
     *
     * This event is triggered when a peer changes their name.
     *
     * @since 0.2.0
     */
    [Version(since = "0.2.0")]
    public void callback_conference_peer_name(ConferencePeerNameCallback callback);

    /**
     * @since 0.2.0
     * @param conference_number The conference number of the conference the
     *   peer is in.
     */
    [Version(since = "0.2.0")]
    [CCode(cname = "tox_conference_peer_list_changed_cb", has_target = false, has_type_id = false)]
    public delegate void ConferencePeerListChangedCallback(Tox self, uint32 conference_number, void* user_data);

    /**
     * Set the callback for the `conference_peer_list_changed` event. Pass NULL to unset.
     *
     * This event is triggered when a peer joins or leaves the conference.
     *
     * @since 0.2.0
     */
    [Version(since = "0.2.0")]
    public void callback_conference_peer_list_changed(ConferencePeerListChangedCallback callback);

    /**
     * Creates a new conference.
     *
     * This function creates a new text conference.
     *
     * @return conference number on success, or UINT32_MAX on failure.
     */
    public uint32 conference_new(out ErrConferenceNew error);

    /**
     * This function deletes a conference.
     *
     * @param conference_number The conference number of the conference to be deleted.
     *
     * @return true on success.
     */
    public bool conference_delete(uint32 conference_number, out ErrConferenceDelete error);

    /**
     * Return the number of peers in the conference. Return value is unspecified on failure.
     */
    public uint32 conference_peer_count(uint32 conference_number, out ErrConferencePeerQuery error);

    [CCode(cname = "tox_conference_peer_get_name_size")]
    private size_t _conference_peer_get_name_size(uint32 conference_number, uint32 peer_number, out ErrConferencePeerQuery error);
    [CCode(cname = "tox_conference_peer_get_name")]
    private bool _conference_peer_get_name(uint32 conference_number, uint32 peer_number, [CCode(array_length = false)] uint8[] name, out ErrConferencePeerQuery error);

    /**
     * Return the name of peer_number who is in conference_number.
     *
     * @return name on success.
     */
    [CCode(cname = "vala_tox_conference_peer_get_name")]
    public string? conference_peer_get_name(uint32 conference_number, uint32 peer_number, out ErrConferencePeerQuery error) {
      var len = _conference_peer_get_name_size(conference_number, peer_number, out error);
      if (error != ErrConferencePeerQuery.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _conference_peer_get_name(conference_number, peer_number, t, out error) ? (string) t : null;
    }

    [CCode(cname = "tox_conference_peer_get_public_key")]
    private bool _conference_peer_get_public_key(uint32 conference_number, uint32 peer_number, [CCode(array_length = false)] uint8[] public_key, out ErrConferencePeerQuery error);

    /**
     * Return the public key of peer_number who is in conference_number.
     *
     * @return public_key on success.
     */
    [CCode(cname = "vala_tox_conference_peer_get_public_key")]
    public uint8[] ? conference_peer_get_public_key(uint32 conference_number, uint32 peer_number, out ErrConferencePeerQuery error) {
      var t = new uint8[public_key_size()];
      return _conference_peer_get_public_key(conference_number, peer_number, t, out error) ? t : null;
    }

    /**
     * Return true if passed peer_number corresponds to our own.
     */
    public bool conference_peer_number_is_ours(uint32 conference_number, uint32 peer_number, out ErrConferencePeerQuery error);

    /**
     * Invites a friend to a conference.
     *
     * @param friend_number The friend number of the friend we want to invite.
     * @param conference_number The conference number of the conference we want to invite the friend to.
     *
     * @return true on success.
     */
    public bool conference_invite(uint32 friend_number, uint32 conference_number, out ErrConferenceInvite error);

    /**
     * Joins a conference that the client has been invited to.
     *
     * @param friend_number The friend number of the friend who sent the invite.
     * @param cookie Received via the `conference_invite` event.
     *
     * @return conference number on success, UINT32_MAX on failure.
     */
    public uint32 conference_join(uint32 friend_number, uint8[] cookie, out ErrConferenceJoin error);

    [CCode(cname = "tox_conference_send_message")]
    private bool _conference_send_message(uint32 conference_number, MessageType type, uint8[] message, out ErrConferenceSendMessage error);

    /**
     * Send a text chat message to the conference.
     *
     * This function creates a conference message packet and pushes it into the send
     * queue.
     *
     * The message length may not exceed {@link MAX_MESSAGE_LENGTH}. Larger messages
     * must be split by the client and sent as separate messages. Other clients can
     * then reassemble the fragments.
     *
     * @param conference_number The conference number of the conference the message is intended for.
     * @param type Message type (normal, action, ...).
     * @param message A non-NULL pointer to the first element of a byte array
     *   containing the message text.
     *
     * @return true on success.
     */
    [CCode(cname = "vala_tox_conference_send_message")]
    public bool conference_send_message(uint32 conference_number, MessageType type, string message, out ErrConferenceSendMessage error) {
      return _conference_send_message(conference_number, type, message.data, out error);
    }

    [CCode(cname = "tox_conference_get_title_size")]
    private size_t _conference_get_title_size(uint32 conference_number, out ErrConferenceTitle error);
    [CCode(cname = "tox_conference_get_title")]
    private bool _conference_get_title(uint32 conference_number, [CCode(array_length = false)] uint8[] title, out ErrConferenceTitle error);

    /**
     * Return the title designated by the given conference number.
     *
     * The data returned is equal to the data received by the last
     * `conference_title` callback.
     *
     * @return title on success.
     */
    [CCode(cname = "vala_tox_conference_get_title")]
    public string? conference_get_title(uint32 conference_number, out ErrConferenceTitle error) {
      var len = _conference_get_title_size(conference_number, out error);
      if (error != ErrConferenceTitle.OK) {
        return null;
      }
      var t = new uint8[len + 1];
      return _conference_get_title(conference_number, t, out error) ? (string) t : null;
    }

    [CCode(cname = "tox_conference_set_title")]
    private bool _conference_set_title(uint32 conference_number, uint8[] title, out ErrConferenceTitle error);

    /**
     * Set the conference title and broadcast it to the rest of the conference.
     *
     * Title length cannot be longer than {@link MAX_NAME_LENGTH}.
     *
     * @return true on success.
     */
    [CCode(cname = "vala_tox_conference_set_title")]
    public bool conference_set_title(uint32 conference_number, string title, out ErrConferenceTitle error) {
      return _conference_set_title(conference_number, title.data, out error);
    }

    [CCode(cname = "tox_conference_get_chatlist_size")]
    private size_t _conference_get_chatlist_size();
    [CCode(cname = "tox_conference_get_chatlist")]
    private void _conference_get_chatlist([CCode(array_length = false)] uint32[] chatlist);

    /**
     * Return a list of valid conference IDs.
     */
    [CCode(cname = "vala_tox_conference_get_chatlist")]
    public uint32[] conference_get_chatlist() {
      var t = new uint32[_conference_get_chatlist_size()];
      _conference_get_chatlist(t);
      return t;
    }

    public ConferenceType conference_get_type(uint32 conference_number, out ErrConferenceGetType error);

    /**
     * Send a custom lossy packet to a friend.
     *
     * The first byte of data must be in the range 200-254. Maximum length of a
     * custom packet is {@link MAX_CUSTOM_PACKET_SIZE}.
     *
     * Lossy packets behave like UDP packets, meaning they might never reach the
     * other side or might arrive more than once (if someone is messing with the
     * connection) or might arrive in the wrong order.
     *
     * Unless latency is an issue, it is recommended that you use lossless custom
     * packets instead.
     *
     * @param friend_number The friend number of the friend this lossy packet
     *   should be sent to.
     * @param data A byte array containing the packet data.
     *
     * @return true on success.
     */
    public bool friend_send_lossy_packet(uint32 friend_number, uint8[] data, out ErrFriendCustomPacket error);

    /**
     * Send a custom lossless packet to a friend.
     *
     * The first byte of data must be in the range 160-191. Maximum length of a
     * custom packet is {@link MAX_CUSTOM_PACKET_SIZE}.
     *
     * Lossless packet behaviour is comparable to TCP (reliability, arrive in order)
     * but with packets instead of a stream.
     *
     * @param friend_number The friend number of the friend this lossless packet
     *   should be sent to.
     * @param data A byte array containing the packet data.
     *
     * @return true on success.
     */
    public bool friend_send_lossless_packet(uint32 friend_number, uint8[] data, out ErrFriendCustomPacket error);

    /**
     * @param friend_number The friend number of the friend who sent a lossy packet.
     * @param data A byte array containing the received packet data.
     */
    [CCode(cname = "tox_friend_lossy_packet_cb", has_target = false, has_type_id = false)]
    public delegate void FriendLossyPacketCallback (Tox self, uint32 friend_number, [CCode(array_length_type = "size_t")] uint8[] data, void* user_data);

    /**
     * Set the callback for the `friend_lossy_packet` event. Pass NULL to unset.
     */
    public void callback_friend_lossy_packet(FriendLossyPacketCallback callback);

    /**
     * @param friend_number The friend number of the friend who sent the packet.
     * @param data A byte array containing the received packet data.
     */
    [CCode(cname = "tox_friend_lossless_packet_cb", has_target = false, has_type_id = false)]
    public delegate void FriendLosslessPacketCallback (Tox self, uint32 friend_number, [CCode(array_length_type = "size_t")] uint8[] data, void* user_data);

    /**
     * Set the callback for the `friend_lossless_packet` event. Pass NULL to unset.
     */
    public void callback_friend_lossless_packet(FriendLosslessPacketCallback callback);

    [CCode(cname = "tox_self_get_dht_id")]
    private void _self_get_dht_id([CCode(array_length = false)] uint8[] dht_id);

    /**
     * Returns the temporary DHT public key of this instance.
     *
     * This can be used in combination with an externally accessible IP address and
     * the bound port (from {@link Tox.self_get_udp_port}) to run a temporary bootstrap node.
     *
     * Be aware that every time a new instance is created, the DHT public key
     * changes, meaning this cannot be used to run a permanent bootstrap node.
     */
    [CCode(cname = "vala_tox_self_get_dht_id")]
    public uint8[] self_get_dht_id() {
      var t = new uint8[public_key_size()];
      _self_get_dht_id(t);
      return t;
    }

    /**
     * Return the UDP port this Tox instance is bound to.
     */
    public uint16 self_get_udp_port(out ErrGetPort error);

    /**
     * Return the TCP port this Tox instance is bound to. This is only relevant if
     * the instance is acting as a TCP relay.
     */
    public uint16 self_get_tcp_port(out ErrGetPort error);
  }
}
