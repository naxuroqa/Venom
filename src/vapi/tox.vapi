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

using GLib;

// Tested with Tox version e0779ed0a615002684594cd48f1e3f5f9c7639f9

[CCode(cheader_filename="tox/tox.h")]
namespace Tox {
  [CCode (cprefix="TOX_")]
  public const int MAX_NAME_LENGTH;

  [CCode (cprefix="TOX_")]
  public const int MAX_STATUSMESSAGE_LENGTH;

  [CCode (cprefix="TOX_")]
  public const int CLIENT_ID_SIZE;

  [CCode (cprefix="TOX_")]
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
  [CCode (cprefix = "TOX_FRIEND_", cname = "int")]
  public enum FriendStatus {
    ONLINE,
    CONFIRMED,
    REQUESTED,
    ADDED,
    NO
  }

  /* errors for m_addfriend
   *  FAERR - Friend Add Error */
  [CCode (cprefix = "TOX_FAERR_", cname = "int")]
  public enum FriendAddError {
    TOOLONG,
    NOMESSAGE,
    OWNKEY,
    ALREADYSENT,
    UNKNOWN,
    BADCHECKSUM,
    SETNEWNOSPAM,
    NOMEM
  }

  /* USERSTATUS
   * Represents userstatuses someone can have. */
  [CCode (cprefix="TOX_USERSTATUS_", cname="TOX_USERSTATUS")]
  public enum UserStatus {
    NONE,
    AWAY,
    BUSY,
    INVALID
  }

  public delegate void FriendrequestCallback([CCode(array_length=false)] uint8[] public_key, [CCode(array_length_type="guint16")] uint8[] data);
  public delegate void FriendmessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] message);
  public delegate void ActionCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] action);
  public delegate void NamechangeCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] new_name);
  public delegate void StatusmessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] new_status);
  public delegate void UserstatusCallback(Tox tox, int friend_number, UserStatus user_status);
  public delegate void ReadReceiptCallback(Tox tox, int friend_number, uint32 receipt);
  public delegate void ConnectionstatusCallback(Tox tox, int friend_number, uint8 status);

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
    public void getaddress([CCode(array_length=false)] uint8[] address);
    /*
     * add a friend
     * set the data that will be sent along with friend request
     * address is the address of the friend (returned by getaddress of the friend you wish to add) it must be FRIEND_ADDRESS_SIZE bytes. TODO: add checksum.
     * data is the data and length is the length
     * returns the friend number if success
     * return TOX_FAERR_TOOLONG if message length is too long
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
    public FriendAddError addfriend([CCode(array_length=false)] uint8[] address, owned uint8[] data);

    /* add a friend without sending a friendrequest.
        returns the friend number if success
        return -1 if failure. */
    [CCode (cname="tox_addfriend_norequest")]
    public FriendAddError addfriend_norequest([CCode(array_length=false)] uint8[] client_id);

    /* return the friend id associated to that client id.
        return -1 if no such friend */
    [CCode (cname="tox_getfriend_id")]
    public int getfriend_id([CCode(array_length=false)] uint8[] client_id);

    /* copies the public key associated to that friend id into client_id buffer.
        make sure that client_id is of size CLIENT_ID_SIZE.
        return 0 if success
        return -1 if failure */
    [CCode (cname="tox_getclient_id")]
    public int getclient_id(int friend_id, [CCode(array_length=false)] uint8[] client_id);

    /* remove a friend */
    [CCode (cname="tox_delfriend")]
    public int delfriend(int friend_number);

    /*  return TOX_FRIEND_ONLINE if friend is online
        return TOX_FRIEND_CONFIRMED if friend is confirmed
        return TOX_FRIEND_REQUESTED if the friend request was sent
        return TOX_FRIEND_ADDED if the friend was added
        return TOX_NOFRIEND if there is no friend with that number */
    [CCode (cname="tox_friendstatus")]
    public int friendstatus(int friend_number);

    /* send a text chat message to an online friend
        returns the message id if packet was successfully put into the send queue
        return 0 if it was not
        you will want to retain the return value, it will be passed to your read receipt callback
        if one is received.
        m_sendmessage_withid will send a message with the id of your choosing,
        however we can generate an id for you by calling plain m_sendmessage. */
    [CCode (cname="tox_sendmessage")]
    public uint32 sendmessage(int friend_number, uint8[] message);

    [CCode (cname="tox_sendmessage_withid")]
    public uint32 sendmessage_withid(int friend_number, uint32 id, uint8[] message);

    /* send an action to an online friend
        returns 1 if packet was successfully put into the send queue
        return 0 if it was not */
    [CCode (cname="tox_sendaction")]
    public int sendaction(int friendNumber, uint8[] action);

    /* Set our nickname
       name must be a string of maximum MAX_NAME_LENGTH length.
       length must be at least 1 byte
       length is the length of name with the NULL terminator
       return 0 if success
       return -1 if failure */
    [CCode (cname="tox_setname")]
    public int setname(uint8[] name);

    /*
       Get your nickname.
       m        The messanger context to use.
       name    Pointer to a string for the name.
       nlen     The length of the string buffer.
       returns Return the length of the name, 0 on error. */
    [CCode (cname="tox_getselfname")]
    public uint16 getselfname(uint8[] name);

    /* get name of friendnumber
        put it in name
        name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
        return 0 if success
        return -1 if failure */
    [CCode (cname="tox_getname")]
    public int getname(int friendNumber, [CCode(array_length=false)] uint8[] name);

    /* set our user status
        you are responsible for freeing status after
        returns 0 on success, -1 on failure */
    [CCode (cname="tox_set_statusmessage")]
    public int set_statusmessage(uint8[] status);

    [CCode (cname="tox_set_userstatus")]
    public int set_userstatus(UserStatus status);

    /* return the length of friendnumber's status message,
        including null
        pass it into malloc */
    [CCode (cname="tox_get_statusmessage_size")]
    public int get_statusmessage_size(int friendNumber);

    /* copy friendnumber's status message into buf, truncating if size is over maxlen
        get the size you need to allocate from m_get_statusmessage_size
        The self variant will copy our own status message. */
    [CCode (cname="tox_copy_statusmessage")]
    public int copy_statusmessage(int friendNumber, uint8[] buf);

    [CCode (cname="tox_copy_self_statusmessage")]
    public int copy_self_statusmessage(uint8[] buf);

    /* Return one of USERSTATUS values.
     * Values unknown to your application should be represented as USERSTATUS_NONE.
     * As above, the self variant will return our own USERSTATUS.
     * If friendnumber is invalid, this shall return USERSTATUS_INVALID. */
    [CCode (cname="tox_get_userstatus")]
    public UserStatus get_userstatus(int friendNumber);

    [CCode (cname="tox_get_selfuserstatus")]
    public UserStatus get_selfuserstatus();

    /* Sets whether we send read receipts for friendnumber.
     * This function is not lazy, and it will fail if yesno is not (0 or 1).*/
    [CCode (cname="tox_set_sends_receipts")]
    public void set_send_receipts(int friendNumber, int yesno);

    /* set the function that will be executed when a friend request is received.
        function format is function(uint8_t * public_key, uint8_t * data, uint16_t length) */
    [CCode (cname="tox_callback_friendrequest")]
    public void callback_friendrequest(FriendrequestCallback callback);

    /* set the function that will be executed when a message from a friend is received.
        function format is: function(int friendnumber, uint8_t * message, uint32_t length) */
    [CCode (cname="tox_callback_friendmessage")]
    public void callback_friendmessage(FriendmessageCallback callback);

    /* set the function that will be executed when an action from a friend is received.
        function format is: function(int friendnumber, uint8_t * action, uint32_t length) */
    [CCode (cname="tox_callback_action")]
    public void callback_action(ActionCallback callback);

    /* set the callback for name changes
        function(int friendnumber, uint8_t *newname, uint16_t length)
        you are not responsible for freeing newname */
    [CCode (cname="tox_callback_namechange")]
    public void callback_namechange(NamechangeCallback callback);

    /* set the callback for status message changes
        function(int friendnumber, uint8_t *newstatus, uint16_t length)
        you are not responsible for freeing newstatus */
    [CCode (cname="tox_callback_statusmessage")]
    public void callback_statusmessage(StatusmessageCallback callback);

    /* set the callback for status type changes
        function(int friendnumber, USERSTATUS kind) */
    [CCode (cname="tox_callback_userstatus")]
    public void callback_userstatus(UserstatusCallback callback);

    /* set the callback for read receipts
        function(int friendnumber, uint32_t receipt)
        if you are keeping a record of returns from m_sendmessage,
        receipt might be one of those values, and that means the message
        has been received on the other side. since core doesn't
        track ids for you, receipt may not correspond to any message
        in that case, you should discard it. */
    [CCode (cname="tox_callback_read_receipt")]
    public void callback_read_receipt(ReadReceiptCallback callback);

    /* set the callback for connection status changes
        function(int friendnumber, uint8_t status)
        status:
          0 -- friend went offline after being previously online
          1 -- friend went online
        note that this callback is not called when adding friends, thus the "after
        being previously online" part. it's assumed that when adding friends,
        their connection status is offline. */
    [CCode (cname="tox_callback_connectionstatus")]
    public void callback_connectionstatus(ConnectionstatusCallback callback);

    /* Use this function to bootstrap the client
        Sends a get nodes request to the given node with ip port and public_key */
    [CCode(cname="tox_bootstrap")]
    public void bootstrap( IpPort ip_port, [CCode(array_length=false)]uint8[] public_key );

    /* returns 0 if we are not connected to the DHT
        returns 1 if we are */
    [CCode(cname="tox_isconnected")]
    public int isconnected();

    /* the main loop that needs to be run at least 20 times per second */
    [CCode(cname="tox_do")]
    public void do();

    /* SAVING AND LOADING FUNCTIONS: */

    /* returns the size of the messenger data (for saving) */
    [CCode(cname="tox_size")]
    public uint32 size();

    /* save the messenger in data (must be allocated memory of size Messenger_size()) */
    [CCode(cname="tox_save")]
    public void save([CCode(array_length=false)] uint8[] data);

    [CCode(cname="tox_load")]
    /* load the messenger from data of size length */
    public int load([CCode(array_length_type = "guint32")] uint8[] data);
  }
}
