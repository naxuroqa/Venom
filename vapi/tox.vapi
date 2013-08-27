
using GLib;

[CCode(cheader_filename="tox/tox.h")]
namespace Tox {
  [CCode (cname = "TOX_MAX_NAME_LENGTH")]
  public const int MAX_NAME_LENGTH;

  [CCode (cname = "TOX_MAX_STATUSMESSAGE_LENGTH")]
  public const int MAX_STATUSMESSAGE_LENGTH;

  [CCode (cname = "TOX_CLIENT_ID_SIZE")]
  public const int CLIENT_ID_SIZE;

  [CCode (cname = "TOX_FRIEND_ADDRESS_SIZE")]
  public const int FRIEND_ADDRESS_SIZE;

  [SimpleType]
  [CCode(cname="tox_IP")]
  public struct Ip {
    public uint32 i;
    public uint16 s[2];
    public uint8 c[4];
  }

  [SimpleType]
  [CCode(cname="tox_IP_Port")]
  public struct IpPort {
    public Ip ip;
    public uint16 port;
    /* not used for anything right now */
    public uint16 padding;
  }

  /* status definitions */
  [CCode (cname = "int")]
  public enum FriendStatus {
    [CCode (cname = "TOX_FRIEND_ONLINE")]
    ONLINE,
    [CCode (cname = "TOX_FRIEND_CONFIRMED")]
    CONFIRMED,
    [CCode (cname = "TOX_FRIEND_REQUESTED")]
    REQUESTED,
    [CCode (cname = "TOX_FRIEND_ADDED")]
    ADDED,
    [CCode (cname = "TOX_NOFRIEND")]
    NO
  }

  /* errors for m_addfriend
   *  FAERR - Friend Add Error */
  [CCode (cname = "int")]
  public enum FriendAddError {
    [CCode (cname = "TOX_FAERR_TOOLONG")]
    TOOLONG,
    [CCode (cname = "TOX_FAERR_NOMESSAGE")]
    NOMESSAGE,
    [CCode (cname = "TOX_FAERR_OWNKEY")]
    OWNKEY,
    [CCode (cname = "TOX_FAERR_ALREADYSENT")]
    ALREADYSENT,
    [CCode (cname = "TOX_FAERR_UNKNOWN")]
    UNKOWKN,
    [CCode (cname = "TOX_FAERR_BADCHECKSUM")]
    BADCHECKSUM,
    [CCode (cname = "TOX_FAERR_SETNEWNOSPAM")]
    SETNEWNOSPAM,
    [CCode (cname = "TOX_FAERR_NOMEM")]
    NOMEM
  }

  /* USERSTATUS
   * Represents userstatuses someone can have. */
  [CCode (cname="TOX_USERSTATUS")]
  public enum UserStatus {
    [CCode (cname = "TOX_USERSTATUS_NONE")]
    NONE,
    [CCode (cname = "TOX_USERSTATUS_AWAY")]
    AWAY,
    [CCode (cname = "TOX_USERSTATUS_BUSY")]
    BUSY,
    [CCode (cname = "TOX_USERSTATUS_INVALID")]
    INVALID
  }

  [CCode (has_target = false)]
  public delegate void FriendrequestCallback([CCode(array_length=false)] uint8[] public_key, [CCode(array_length_type="guint16")] uint8[] data, void* whatevs);
  [CCode (has_target = false)]
  public delegate void FriendmessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] message, void* whatevs);
  [CCode (has_target = false)]
  public delegate void ActionCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] action, void* whatevs);
  [CCode (has_target = false)]
  public delegate void NamechangeCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] new_name, void* whatevs);
  [CCode (has_target = false)]
  public delegate void StatusmessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] new_status, void* whatevs);

  [Compact]
  [CCode (cname="Tox", free_function="tox_kill")]
  public class Tox {
    [CCode (cname = "tox_new")]
    public Tox();
    /*
     * returns a FRIEND_ADDRESS_SIZE byte address to give to others.
     * format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
     *
     */
    [CCode (cname="tox_getaddress")]
    public void getAddress([CCode(array_length=false)] uint8[] address);
    /*
     * add a friend
     * set the data that will be sent along with friend request
     * address is the address of the friend (returned by getaddress of the friend you wish to add) it must be FRIEND_ADDRESS_SIZE bytes. TODO: add checksum.
     * data is the data and length is the length
     * returns the friend number if success
     * return TOX_FA_TOOLONG if message length is too long
     * return TOX_FAERR_NOMESSAGE if no message (message length must be >= 1 byte)
     * return TOX_FAERR_OWNKEY if user's own key
     * return TOX_FAERR_ALREADYSENT if friend request already sent or already a friend
     * return TOX_FAERR_UNKNOWN for unknown error
     * return TOX_FAERR_BADCHECKSUM if bad checksum in address
     * return TOX_FAERR_SETNEWNOSPAM if the friend was already there but the nospam was different
     * (the nospam for that friend was set to the new one)
     * return TOX_FAERR_NOMEM if increasing the friend list size fails
     */
    [CCode (cname="tox_addfriend")]
    public int addFriend([CCode(array_length=false)] uint8[] address, uint8[] data);

    /* add a friend without sending a friendrequest.
        returns the friend number if success
        return -1 if failure. */
    [CCode (cname="tox_addfriend_norequest")]
    public int addFriendNoRequest([CCode(array_length=false)] uint8[] client_id);

    /* return the friend id associated to that client id.
        return -1 if no such friend */
    [CCode (cname="tox_getfriend_id")]
    public int getFriendId([CCode(array_length=false)] uint8[] client_id);

    /* copies the public key associated to that friend id into client_id buffer.
        make sure that client_id is of size CLIENT_ID_SIZE.
        return 0 if success
        return -1 if failure */
    [CCode (cname="tox_getclient_id")]
    public int getClientId(int friend_id, [CCode(array_length=false)] uint8[] client_id);

    /* remove a friend */
    [CCode (cname="tox_delfriend")]
    public int delFriend(int friend_number);

    /*  return TOX_FRIEND_ONLINE if friend is online
        return TOX_FRIEND_CONFIRMED if friend is confirmed
        return TOX_FRIEND_REQUESTED if the friend request was sent
        return TOX_FRIEND_ADDED if the friend was added
        return TOX_NOFRIEND if there is no friend with that number */
    [CCode (cname="tox_friendstatus")]
    public int friendStatus(int friend_number);

    /* send a text chat message to an online friend
        returns the message id if packet was successfully put into the send queue
        return 0 if it was not
        you will want to retain the return value, it will be passed to your read receipt callback
        if one is received.
        m_sendmessage_withid will send a message with the id of your choosing,
        however we can generate an id for you by calling plain m_sendmessage. */
    [CCode (cname="tox_sendmessage")]
    public uint32 sendMessage(int friend_number, uint8[] message);

    [CCode (cname="tox_sendmessage_withid")]
    public uint32 sendMessageWithId(int friend_number, uint32 id, uint8[] message);

    /* send an action to an online friend
        returns 1 if packet was successfully put into the send queue
        return 0 if it was not */
    [CCode (cname="tox_sendaction")]
    public int sendAction(int friendNumber, uint8[] action);

    /* Set our nickname
       name must be a string of maximum MAX_NAME_LENGTH length.
       length must be at least 1 byte
       length is the length of name with the NULL terminator
       return 0 if success
       return -1 if failure */
    [CCode (cname="tox_setname")]
    public int setName(uint8[] name);

    /*
       Get your nickname.
       m        The messanger context to use.
       name    Pointer to a string for the name.
       nlen     The length of the string buffer.
       returns Return the length of the name, 0 on error.
    */
    [CCode (cname="tox_getselfname")]
    public uint16 getSelfName(uint8 name);

    /* get name of friendnumber
        put it in name
        name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
        return 0 if success
        return -1 if failure */
    [CCode (cname="tox_getname")]
    public int getName(int friendNumber, [CCode(array_length=false)] uint8 name);

    /* set our user status
        you are responsible for freeing status after
        returns 0 on success, -1 on failure */
    [CCode (cname="tox_set_statusmessage")]
    public int setStatusMessage(uint8[] status);

    [CCode (cname="tox_set_userstatus")]
    public int setUserStatus(UserStatus status);

    /* return the length of friendnumber's status message,
        including null
        pass it into malloc */
    [CCode (cname="tox_get_statusmessage_size")]
    public int getStatusMessageSize(int friendNumber);

    /* copy friendnumber's status message into buf, truncating if size is over maxlen
        get the size you need to allocate from m_get_statusmessage_size
        The self variant will copy our own status message. */
    [CCode (cname="tox_copy_statusmessage")]
    public int copyStatusMessage(int friendNumber, uint8[] buf);

    [CCode (cname="tox_copy_self_statusmessage")]
    public int copySelfStatusMessage(uint8[] buf);

    /* Return one of USERSTATUS values.
     * Values unknown to your application should be represented as USERSTATUS_NONE.
     * As above, the self variant will return our own USERSTATUS.
     * If friendnumber is invalid, this shall return USERSTATUS_INVALID. */
    [CCode (cname="tox_get_userstatus")]
    public UserStatus getUserStatus(int friendNumber);

    [CCode (cname="tox_get_selfuserstatus")]
    public UserStatus getSelfUserStatus();

    /* Sets whether we send read receipts for friendnumber.
     * This function is not lazy, and it will fail if yesno is not (0 or 1).*/
    [CCode (cname="tox_set_sends_receipts")]
    public void setSendReceipts(int friendNumber, int yesno);

    /* set the function that will be executed when a friend request is received.
        function format is function(uint8_t * public_key, uint8_t * data, uint16_t length) */
    [CCode (cname="tox_callback_friendrequest")]
    public void setFriendrequestCallback(FriendrequestCallback callback, void* userdata);

    /* set the function that will be executed when a message from a friend is received.
        function format is: function(int friendnumber, uint8_t * message, uint32_t length) */
    [CCode (cname="tox_callback_friendmessage")]
    public void setFriendmessageCallback(FriendmessageCallback callback, void* userdata);

    /* set the function that will be executed when an action from a friend is received.
        function format is: function(int friendnumber, uint8_t * action, uint32_t length) */
    [CCode (cname="tox_callback_action")]
    public void setActionCallback(ActionCallback callback, void* userdata);

    /* set the callback for name changes
        function(int friendnumber, uint8_t *newname, uint16_t length)
        you are not responsible for freeing newname */
    [CCode (cname="tox_callback_namechange")]
    public void setNamechangeCallback(NamechangeCallback callback, void* userdata);

    /* set the callback for status message changes
        function(int friendnumber, uint8_t *newstatus, uint16_t length)
        you are not responsible for freeing newstatus */
    [CCode (cname="tox_callback_statusmessage")]
    public void setStatusmessageCallback(StatusmessageCallback callback, void* userdata);

/* set the callback for status type changes
    function(int friendnumber, USERSTATUS kind) */
//void tox_callback_userstatus(Tox *tox, void (*function)(Tox *tox, int, TOX_USERSTATUS, void *), void *userdata);

/* set the callback for read receipts
    function(int friendnumber, uint32_t receipt)
    if you are keeping a record of returns from m_sendmessage,
    receipt might be one of those values, and that means the message
    has been received on the other side. since core doesn't
    track ids for you, receipt may not correspond to any message
    in that case, you should discard it. */
//void tox_callback_read_receipt(Tox *tox, void (*function)(Tox *tox, int, uint32_t, void *), void *userdata);

/* set the callback for connection status changes
    function(int friendnumber, uint8_t status)
    status:
      0 -- friend went offline after being previously online
      1 -- friend went online
    note that this callback is not called when adding friends, thus the "after
    being previously online" part. it's assumed that when adding friends,
    their connection status is offline. */
//void tox_callback_connectionstatus(Tox *tox, void (*function)(Tox *tox, int, uint8_t, void *), void *userdata);

    /* Use this function to bootstrap the client
        Sends a get nodes request to the given node with ip port and public_key */
    [CCode(cname="tox_bootstrap")]
    public void bootstrap( IpPort ip_port, [CCode(array_length=false)]uint8[] public_key );

    /* returns 0 if we are not connected to the DHT
        returns 1 if we are */
    [CCode(cname="tox_isconnected")]
    public int isConnected();

    /* the main loop that needs to be run at least 20 times per second */
    [CCode(cname="tox_do")]
    public void do_loop();

    /* SAVING AND LOADING FUNCTIONS: */

    /* returns the size of the messenger data (for saving) */
    [CCode(cname="tox_size")]
    public uint32 getSize();

    /* save the messenger in data (must be allocated memory of size Messenger_size()) */
    [CCode(cname="tox_save")]
    public void save([CCode(array_length=false)] uint8[] data);

    [CCode(cname="tox_load")]
    /* load the messenger from data of size length */
    public int load([CCode(array_length_type = "guint32")] uint8[] data);
  }
}
