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
[CCode(cheader_filename="tox/tox.h", cprefix = "tox_")]
namespace Tox {
  [CCode(cprefix = "TOX_")]
  public const int MAX_NAME_LENGTH;
  [CCode(cprefix = "TOX_")]
  public const int MAX_STATUSMESSAGE_LENGTH;
  [CCode(cprefix = "TOX_")]
  public const int CLIENT_ID_SIZE;
  [CCode(cprefix = "TOX_")]
  public const int FRIEND_ADDRESS_SIZE;
  [CCode(cprefix = "TOX_")]
  public const int PORTRANGE_FROM;
  [CCode(cprefix = "TOX_")]
  public const int PORTRANGE_TO;
  [CCode(cprefix = "TOX_")]
  public const int PORT_DEFAULT;

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
  
  [CCode (cprefix="TOX_FILECONTROL_")]
  public enum FileControlStatus {
    ACCEPT,
    PAUSE,
    KILL,
    FINISHED
  }

  [Compact]
  [CCode (cname="Tox", free_function="tox_kill", cprefix="tox_")]
  public class Tox {
    /*
     *  Run this function at startup.
     *
     * Initializes a tox structure
     *  The type of communication socket depends on ipv6enabled:
     *  If set to 0 (zero), creates an IPv4 socket which subsequently only allows
     *    IPv4 communication
     *  If set to anything else, creates an IPv6 socket which allows both IPv4 AND
     *    IPv6 communication
     *
     *  return allocated instance of tox on success.
     *  return 0 if there are problems.
     */
    [CCode (cname = "tox_new")]
    public Tox(uint8 ipv6enabled);

    /*
     * returns a FRIEND_ADDRESS_SIZE byte address to give to others.
     * format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
     *
     */
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
    public FriendAddError addfriend([CCode(array_length=false)] uint8[] address, [CCode(array_length_type="guint16")] uint8[] data);

    /* Add a friend without sending a friendrequest.
     *  return the friend number if success.
     *  return -1 if failure.
     */
    public FriendAddError addfriend_norequest([CCode(array_length=false)] uint8[] client_id);

    /* return the friend id associated to that client id.
        return -1 if no such friend */
    public int getfriend_id([CCode(array_length=false)] uint8[] client_id);

    /* Copies the public key associated to that friend id into client_id buffer.
     * Make sure that client_id is of size CLIENT_ID_SIZE.
     *  return 0 if success.
     *  return -1 if failure.
     */
    public int getclient_id(int friend_id, [CCode(array_length=false)] uint8[] client_id);

    /* Remove a friend. */
    public int delfriend(int friendnumber);

    /* Checks friend's connecting status.
     *
     *  return 1 if friend is connected to us (Online).
     *  return 0 if friend is not connected to us (Offline).
     *  return -1 on failure.
     */
    public int get_friend_connectionstatus(int friendnumber);

    /* Checks if there exists a friend with given friendnumber.
     *
     *  return 1 if friend exists.
     *  return 0 if friend doesn't exist.
     */
     public int friend_exists(int friendnumber);

    /* Send a text chat message to an online friend.
     *
     *  return the message id if packet was successfully put into the send queue.
     *  return 0 if it was not.
     *
     * You will want to retain the return value, it will be passed to your read receipt callback
     * if one is received.
     * m_sendmessage_withid will send a message with the id of your choosing,
     * however we can generate an id for you by calling plain m_sendmessage.
     */
    public uint32 sendmessage(int friendnumber, [CCode(array_length_type="guint32")] uint8[] message);
    public uint32 sendmessage_withid(int friendnumber, uint32 id, [CCode(array_length_type="guint32")] uint8[] message);

    /* Send an action to an online friend.
     *
     *  return 1 if packet was successfully put into the send queue.
     *  return 0 if it was not.
     */
    public int sendaction(int friendnumber, [CCode(array_length_type="guint32")] uint8[] action);

    /* Set friendnumber's nickname.
     * name must be a string of maximum MAX_NAME_LENGTH length.
     * length must be at least 1 byte.
     * length is the length of name with the NULL terminator.
     *
     *  return 0 if success.
     *  return -1 if failure.
     */
    public int setfriendname(int friendnumber, [CCode(array_length_type="guint16")] uint8[] name);

    /* Set our nickname.
     * name must be a string of maximum MAX_NAME_LENGTH length.
     * length must be at least 1 byte.
     * length is the length of name with the NULL terminator.
     *
     *  return 0 if success.
     *  return -1 if failure.
     */
    public int setname([CCode(array_length_type="guint16")] uint8[] name);

    /*
     * Get your nickname.
     * m - The messanger context to use.
     * name - Pointer to a string for the name.
     * nlen - The length of the string buffer.
     *
     *  return length of name.
     *  return 0 on error.
     */
    public uint16 getselfname([CCode(array_length_type="guint16")] uint8[] name);

     /* Get name of friendnumber and put it in name.
     * name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
     *
     *  return length of name (with the NULL terminator) if success.
     *  return -1 if failure.
     */
    public int getname(int friendnumber, [CCode(array_length=false)] uint8[] name);

    /* Set our user status.
     * You are responsible for freeing status after.
     *
     *  returns 0 on success.
     *  returns -1 on failure.
     */
    public int set_statusmessage([CCode(array_length_type="guint16")] uint8[] status);
    public int set_userstatus(UserStatus status);

    /*  return the length of friendnumber's status message, including null.
     *  Pass it into malloc
     */
    public int get_statusmessage_size(int friendnumber);

    /* Copy friendnumber's status message into buf, truncating if size is over maxlen.
     * Get the size you need to allocate from m_get_statusmessage_size.
     * The self variant will copy our own status message.
     *
     * returns the length of the copied data on success
     * retruns -1 on failure.
     */
    public int copy_statusmessage(int friendnumber, [CCode(array_length_type="guint32")] uint8[] buf);
    public int copy_self_statusmessage([CCode(array_length_type="guint32")] uint8[] buf);

    /*  return one of USERSTATUS values.
     *  Values unknown to your application should be represented as USERSTATUS_NONE.
     *  As above, the self variant will return our own USERSTATUS.
     *  If friendnumber is invalid, this shall return USERSTATUS_INVALID.
     */
    public UserStatus get_userstatus(int friendnumber);
    public UserStatus get_selfuserstatus();

    /* Sets whether we send read receipts for friendnumber.
     * This function is not lazy, and it will fail if yesno is not (0 or 1).
     */
    public void set_send_receipts(int friendnumber, int yesno);

    /* Return the number of friends in the instance m.
     * You should use this to determine how much memory to allocate
     * for copy_friendlist. */
    public uint32 count_friendlist();

    /* Copy a list of valid friend IDs into the array out_list.
     * If out_list is NULL, returns 0.
     * Otherwise, returns the number of elements copied.
     * If the array was too small, the contents
     * of out_list will be truncated to list_size. */
    public uint32 copy_friendlist(int[] out_list);

    /* Set the function that will be executed when a friend request is received.
     *  Function format is function(uint8_t * public_key, uint8_t * data, uint16_t length)
     */
    public delegate void FriendrequestCallback([CCode(array_length=false)] uint8[] public_key, [CCode(array_length_type="guint16")] uint8[] data);
    public void callback_friendrequest(FriendrequestCallback callback);

    /* Set the function that will be executed when a message from a friend is received.
     *  Function format is: function(int friendnumber, uint8_t * message, uint32_t length)
     */
    public delegate void FriendmessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] message);
    public void callback_friendmessage(FriendmessageCallback callback);

    /* Set the function that will be executed when an action from a friend is received.
     *  Function format is: function(int friendnumber, uint8_t * action, uint32_t length)
     */
    public delegate void ActionCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] action);
    public void callback_action(ActionCallback callback);

    /* Set the callback for name changes.
     *  function(int friendnumber, uint8_t *newname, uint16_t length)
     *  You are not responsible for freeing newname
     */
    public delegate void NamechangeCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] new_name);
    public void callback_namechange(NamechangeCallback callback);

    /* Set the callback for status message changes.
     *  function(int friendnumber, uint8_t *newstatus, uint16_t length)
     *  You are not responsible for freeing newstatus.
     */
    public delegate void StatusmessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] new_status);
    public void callback_statusmessage(StatusmessageCallback callback);

    /* Set the callback for status type changes.
     *  function(int friendnumber, USERSTATUS kind)
     */
    public delegate void UserstatusCallback(Tox tox, int friend_number, UserStatus user_status);
    public void callback_userstatus(UserstatusCallback callback);

    /* Set the callback for read receipts.
     *  function(int friendnumber, uint32_t receipt)
     *
     *  If you are keeping a record of returns from m_sendmessage;
     *  receipt might be one of those values, meaning the message
     *  has been received on the other side.
     *  Since core doesn't track ids for you, receipt may not correspond to any message.
     *  In that case, you should discard it.
     */
    public delegate void ReadReceiptCallback(Tox tox, int friend_number, uint32 receipt);
    public void callback_read_receipt(ReadReceiptCallback callback);

    /* Set the callback for connection status changes.
     *  function(int friendnumber, uint8_t status)
     *
     *  Status:
     *    0 -- friend went offline after being previously online
     *    1 -- friend went online
     *
     *  NOTE: This callback is not called when adding friends, thus the "after
     *  being previously online" part. it's assumed that when adding friends,
     *  their connection status is offline.
     */
    public delegate void ConnectionstatusCallback(Tox tox, int friend_number, uint8 status);
    public void callback_connectionstatus(ConnectionstatusCallback callback);


    /**********GROUP CHAT FUNCTIONS: WARNING WILL BREAK A LOT************/

    /* Set the callback for group invites.
     *
     *  Function(Tox *tox, int friendnumber, uint8_t *group_public_key, void *userdata)
     */
    public delegate void GroupInviteCallback(Tox tox, int friendnumber, [CCode(array_length=false)] uint8[] group_public_key);
    public void callback_group_invite(GroupInviteCallback callback);

    /* Set the callback for group messages.
     *
     *  Function(Tox *tox, int groupnumber, int friendgroupnumber, uint8_t * message, uint16_t length, void *userdata)
     */
    public delegate void GroupMessageCallback(Tox tox, int groupnumber, int friendgroupnumber, [CCode(array_length_type="guint16")] uint8[] message);
    public void callback_group_message(GroupMessageCallback callback);

    /* Creates a new groupchat and puts it in the chats array.
     *
     * return group number on success.
     * return -1 on failure.
     */
    public int add_groupchat();

    /* Delete a groupchat from the chats array.
     *
     * return 0 on success.
     * return -1 if failure.
     */
    public int del_groupchat(int groupnumber);

    /* Copy the name of peernumber who is in groupnumber to name.
     * name must be at least TOX_MAX_NAME_LENGTH long.
     *
     * return length of name if success
     * return -1 if failure
     */
    public int group_peername(int groupnumber, int peernumber, [CCode(array_length=false)] uint8[] name);

    /* invite friendnumber to groupnumber
     * return 0 on success
     * return -1 on failure
     */
    public int invite_friend(int friendnumber, int groupnumber);

    /* Join a group (you need to have been invited first.)
     *
     * returns group number on success
     * returns -1 on failure.
     */
    public int join_groupchat(int friendnumber, [CCode(array_length=false)] uint8[] friend_group_public_key);

    /* send a group message
     * return 0 on success
     * return -1 on failure
     */
    public int group_message_send(int groupnumber, [CCode(array_length_type="guint32")] uint8[] message);

    /******************END OF GROUP CHAT FUNCTIONS************************/

    /****************FILE SENDING FUNCTIONS*****************/
    /* NOTE: This how to will be updated.
     *
     * HOW TO SEND FILES CORRECTLY:
     * 1. Use tox_new_filesender(...) to create a new file sender.
     * 2. Wait for the callback set with tox_callback_file_control(...) to be called with receive_send == 1 and control_type == TOX_FILECONTROL_ACCEPT
     * 3. Send the data with tox_file_senddata(...)
     * 4. When sending is done, send a tox_file_sendcontrol(...) with send_receive = 0 and message_id = TOX_FILECONTROL_FINISHED
     *
     * HOW TO RECEIVE FILES CORRECTLY:
     * 1. wait for the callback set with tox_callback_file_sendrequest(...)
     * 2. accept or refuse the connection with tox_file_sendcontrol(...) with send_receive = 1 and message_id = TOX_FILECONTROL_ACCEPT or TOX_FILECONTROL_KILL
     * 3. save all the data received with the callback set with tox_callback_file_data(...) to a file.
     * 4. when the callback set with tox_callback_file_control(...) is called with receive_send == 0 and control_type == TOX_FILECONTROL_FINISHED
     * the file is done transferring.
     *
     * tox_file_dataremaining(...) can be used to know how many bytes are left to send/receive.
     *
     * More to come...
     */

    /* Set the callback for file send requests.
     *
     *  Function(Tox *tox, int friendnumber, uint8_t filenumber, uint64_t filesize, uint8_t *filename, uint16_t filename_length, void *userdata)
     */
    public delegate void FileSendrequestCallback(Tox tox, int friendnumber, uint8 filenumber, uint64 filesize, [CCode(array_length_type="guint16")] uint8[] filename);
    public void callback_file_sendrequest(FileSendrequestCallback callback);

    /* Set the callback for file control requests.
     *
     *  receive_send is 1 if the message is for a slot on which we are currently sending a file and 0 if the message
     *  is for a slot on which we are receiving the file
     *
     *  Function(Tox *tox, int friendnumber, uint8_t receive_send, uint8_t filenumber, uint8_t control_type, uint8_t *data, uint16_t length, void *userdata)
     *
     */
    public delegate void FileControlCallback(Tox tox, int friendnumber, uint8 receive_send, uint8 filenumber, FileControlStatus status, [CCode(array_length_type="guint16")] uint8[] data);
    public void callback_file_control(FileControlCallback callback);

    /* Set the callback for file data.
     *
     *  Function(Tox *tox, int friendnumber, uint8_t filenumber, uint8_t *data, uint16_t length, void *userdata)
     *
     */
    public delegate void FileDataCallback(Tox tox, int friendnumber, uint8 filenumber, [CCode(array_length_type="guint16")] uint8[] data);
    public void callback_file_data(FileDataCallback callback);

    /* Send a file send request.
     * Maximum filename length is 255 bytes.
     *  return file number on success
     *  return -1 on failure
     */
     public int new_filesender(int friendnumber, uint64 filesize, [CCode(array_length_type="guint16")] uint8[] filename);

    /* Send a file control request.
     *
     * send_receive is 0 if we want the control packet to target a file we are currently sending,
     * 1 if it targets a file we are currently receiving.
     *
     *  return 1 on success
     *  return 0 on failure
     */
    public int tox_file_sendcontrol(int friendnumber, uint8 send_receive, uint8 filenumber, uint8 message_id, [CCode(array_length_type="guint16")] uint8[] data);

    /* Send file data.
     *
     *  return 1 on success
     *  return 0 on failure
     */
    public int file_senddata(int friendnumber, uint8 filenumber, [CCode(array_length_type="guint16")] uint8[] data);

    /* Give the number of bytes left to be sent/received.
     *
     *  send_receive is 0 if we want the sending files, 1 if we want the receiving.
     *
     *  return number of bytes remaining to be sent/received on success
     *  return 0 on failure
     */
    uint64 file_dataremaining(int friendnumber, uint8 filenumber, uint8 send_receive);

    /***************END OF FILE SENDING FUNCTIONS******************/
    /*
     * Use these two functions to bootstrap the client.
     */
    /* Sends a "get nodes" request to the given node with ip, port and public_key
     *   to setup connections
     */
    // FIXME
    //public void bootstrap_from_ip( IPAnyPort ip_port, [CCode(array_length=false)]uint8[] public_key );

    /* Resolves address into an IP address. If successful, sends a "get nodes"
     *   request to the given node with ip, port and public_key to setup connections
     *
     * address can be a hostname or an IP address (IPv4 or IPv6).
     * if ipv6enabled is 0 (zero), the resolving sticks STRICTLY to IPv4 addresses
     * if ipv6enabled is not 0 (zero), the resolving looks for IPv6 addresses first,
     *   then IPv4 addresses.
     *
     *  returns 1 if the address could be converted into an IP address
     *  returns 0 otherwise
     */
    public int bootstrap_from_address(string address, uint8 ipv6enabled, uint16 port, [CCode(array_length=false)] uint8[] public_key);
    /* returns 0 if we are not connected to the DHT
        returns 1 if we are */
    public int isconnected();

    /* the main loop that needs to be run at least 20 times per second */
    public void do();

    /* SAVING AND LOADING FUNCTIONS: */

    /* returns the size of the messenger data (for saving) */
    public uint32 size();

    /* save the messenger in data (must be allocated memory of size Messenger_size()) */
    public void save([CCode(array_length=false)] uint8[] data);

    /* load the messenger from data of size length */
    public int load([CCode(array_length_type = "guint32")] uint8[] data);
  }
}
