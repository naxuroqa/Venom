/*
 *    tox-1.0.vapi
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
 *
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

[CCode (cheader_filename = "tox/tox.h", cprefix = "tox_")]
namespace Tox {
  [CCode (cprefix = "TOX_")]
  public const int MAX_NAME_LENGTH;
  [CCode (cprefix = "TOX_")]
  public const int MAX_MESSAGE_LENGTH;
  [CCode (cprefix = "TOX_")]
  public const int MAX_STATUSMESSAGE_LENGTH;
  [CCode (cprefix = "TOX_")]
  public const int CLIENT_ID_SIZE;
  [CCode (cprefix = "TOX_")]
  public const int FRIEND_ADDRESS_SIZE;
  [CCode (cprefix = "TOX_")]
  public const int PORTRANGE_FROM;
  [CCode (cprefix = "TOX_")]
  public const int PORTRANGE_TO;
  [CCode (cprefix = "TOX_")]
  public const int PORT_DEFAULT;
  [CCode (cprefix = "TOX_")]
  public const int ENABLE_IPV6_DEFAULT;

  /* Errors for m_addfriend
   * FAERR - Friend Add Error
   */
  [CCode (cname = "gint32", cprefix = "TOX_FAERR_", has_type_id = false)]
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

  /* USERSTATUS -
   * Represents userstatuses someone can have.
   */
  [CCode (cname = "TOX_USERSTATUS", cprefix = "TOX_USERSTATUS_", has_type_id = false)]
  public enum UserStatus {
    NONE,
    AWAY,
    BUSY,
    INVALID
  }

  [CCode (cname = "int", cprefix = "TOX_FILECONTROL_", has_type_id = false)]
  public enum FileControlStatus {
    ACCEPT,
    PAUSE,
    KILL,
    FINISHED,
    RESUME_BROKEN
  }

  [CCode (cname = "guint8", cprefix = "TOX_CHAT_CHANGE_", has_type_id = false)]
  public enum ChatChange{
    PEER_ADD,
    PEER_DEL,
    PEER_NAME
  }

  [CCode (cname = "Tox", free_function = "tox_kill", cprefix = "tox_", has_type_id = false)]
  [Compact]
  public class Tox {
    /* NOTE: Strings in Tox are all UTF-8, (This means that there is no terminating NULL character.)
     *
     * The exact buffer you send will be received at the other end without modification.
     *
     * Do not treat Tox strings as C strings.
     */

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

    /*  return TOX_FRIEND_ADDRESS_SIZE byte address to give to others.
     * format: [client_id (32 bytes)][nospam number (4 bytes)][checksum (2 bytes)]
     */
    public void get_address([CCode(array_length=false)] uint8[] address);

    /* Add a friend.
     * Set the data that will be sent along with friend request.
     * address is the address of the friend (returned by getaddress of the friend you wish to add) it must be TOX_FRIEND_ADDRESS_SIZE bytes. TODO: add checksum.
     * data is the data and length is the length.
     *
     *  return the friend number if success.
     *  return TOX_FA_TOOLONG if message length is too long.
     *  return TOX_FAERR_NOMESSAGE if no message (message length must be >= 1 byte).
     *  return TOX_FAERR_OWNKEY if user's own key.
     *  return TOX_FAERR_ALREADYSENT if friend request already sent or already a friend.
     *  return TOX_FAERR_UNKNOWN for unknown error.
     *  return TOX_FAERR_BADCHECKSUM if bad checksum in address.
     *  return TOX_FAERR_SETNEWNOSPAM if the friend was already there but the nospam was different.
     *  (the nospam for that friend was set to the new one).
     *  return TOX_FAERR_NOMEM if increasing the friend list size fails.
     */
    public FriendAddError add_friend([CCode(array_length=false)] uint8[] address, [CCode(array_length_type="guint16")] uint8[] data);

    /* Add a friend without sending a friendrequest.
     *  return the friend number if success.
     *  return -1 if failure.
     */
    public int32 add_friend_norequest([CCode(array_length=false)] uint8[] client_id);

    /* return the friend id associated to that client id.
        return -1 if no such friend */
    public int32 tox_get_friend_number([CCode(array_length=false)] uint8[] client_id);

    /* Copies the public key associated to that friend id into client_id buffer.
     * Make sure that client_id is of size CLIENT_ID_SIZE.
     *  return 0 if success.
     *  return -1 if failure.
     */
    public int get_client_id(int32 friend_id, [CCode(array_length=false)] uint8[] client_id);

    /* Remove a friend.
     *
     *  return 0 if success.
     *  return -1 if failure.
     */
    public int del_friend(int32 friendnumber);

    /* Checks friend's connecting status.
     *
     *  return 1 if friend is connected to us (Online).
     *  return 0 if friend is not connected to us (Offline).
     *  return -1 on failure.
     */
    public int get_friend_connection_status(int32 friendnumber);

    /* Checks if there exists a friend with given friendnumber.
     *
     *  return 1 if friend exists.
     *  return 0 if friend doesn't exist.
     */
     public int friend_exists(int32 friendnumber);

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
    public uint32 send_message(int32 friendnumber, [CCode(array_length_type="guint32")] uint8[] message);
    public uint32 send_message_withid(int32 friendnumber, uint32 theid, [CCode(array_length_type="guint32")] uint8[] message);

    /* Send an action to an online friend.
     *
     *  return the message id if packet was successfully put into the send queue.
     *  return 0 if it was not.
     *
     *  You will want to retain the return value, it will be passed to your read_receipt callback
     *  if one is received.
     *  m_sendaction_withid will send an action message with the id of your choosing,
     *  however we can generate an id for you by calling plain m_sendaction.
     */
    public uint32 send_action(int32 friendnumber, [CCode(array_length_type="guint32")] uint8[] action);
    public uint32 send_action_withid(int32 friendnumber, uint32 action_id, [CCode(array_length_type="guint32")] uint8[] action);

    /* Set our nickname.
     * name must be a string of maximum MAX_NAME_LENGTH length.
     * length must be at least 1 byte.
     * length is the length of name with the NULL terminator.
     *
     *  return 0 if success.
     *  return -1 if failure.
     */
    public int set_name([CCode(array_length_type="guint16")] uint8[] name);

    /*
     * Get your nickname.
     * m - The messanger context to use.
     * name - needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
     *
     *  return length of name.
     *  return 0 on error.
     */
    public uint16 get_self_name([CCode(array_length=false)] uint8[] name);

    /* Get name of friendnumber and put it in name.
     * name needs to be a valid memory location with a size of at least MAX_NAME_LENGTH (128) bytes.
     *
     *  return length of name if success.
     *  return -1 if failure.
     */
    public int get_name(int32 friendnumber, [CCode(array_length=false)] uint8[] name);

    /*  returns the length of name on success.
     *  returns -1 on failure.
     */
    public int get_name_size(int32 friendnumber);
    public int get_self_name_size();

    /* Set our user status.
     *
     * userstatus must be one of TOX_USERSTATUS values.
     *
     *  returns 0 on success.
     *  returns -1 on failure.
     */
    public int set_status_message([CCode(array_length_type="guint16")] uint8[] status);
    public int set_user_status(UserStatus status);

    /*  returns the length of status message on success.
     *  returns -1 on failure.
     */
    public int get_status_message_size(int32 friendnumber);
    public int get_self_status_message_size();

    /* Copy friendnumber's status message into buf, truncating if size is over maxlen.
     * Get the size you need to allocate from m_get_statusmessage_size.
     * The self variant will copy our own status message.
     *
     * returns the length of the copied data on success
     * retruns -1 on failure.
     */
    public int get_status_message(int32 friendnumber, [CCode(array_length_type="guint32")] uint8[] buf);
    public int get_self_status_message([CCode(array_length_type="guint32")] uint8[] buf);

    /*  return one of USERSTATUS values.
     *  Values unknown to your application should be represented as USERSTATUS_NONE.
     *  As above, the self variant will return our own USERSTATUS.
     *  If friendnumber is invalid, this shall return USERSTATUS_INVALID.
     */
    public UserStatus get_user_status(int32 friendnumber);
    public UserStatus get_self_user_status();

    /* returns timestamp of last time friendnumber was seen online, or 0 if never seen.
     * returns -1 on error.
     */
    public uint64 get_last_online(int32 friendnumber);

    /* Set our typing status for a friend.
     * You are responsible for turning it on or off.
     *
     * returns 0 on success.
     * returns -1 on failure.
     */
    public int set_user_is_typing(int32 friendnumber, uint8 is_typing);

    /* Get the typing status of a friend.
     *
     * returns 0 if friend is not typing.
     * returns 1 if friend is typing.
     */
    public uint8 get_is_typing(int32 friendnumber);

    /* Sets whether we send read receipts for friendnumber.
     * This function is not lazy, and it will fail if yesno is not (0 or 1).
     */
    public void set_send_receipts(int32 friendnumber, int yesno);

    /* Return the number of friends in the instance m.
     * You should use this to determine how much memory to allocate
     * for copy_friendlist. */
    public uint32 count_friendlist();

    /* Return the number of online friends in the instance m. */
    public uint32 get_num_online_friends();

    /* Copy a list of valid friend IDs into the array out_list.
     * If out_list is NULL, returns 0.
     * Otherwise, returns the number of elements copied.
     * If the array was too small, the contents
     * of out_list will be truncated to list_size. */
    public uint32 get_friendlist([CCode(array_length_type="guint32")] int[] out_list);

    /* Set the function that will be executed when a friend request is received.
     *  Function format is function(Tox *tox, uint8_t * public_key, uint8_t * data, uint16_t length, void *userdata)
     */
    public delegate void FriendRequestCallback(Tox tox, [CCode(array_length=false)] uint8[] public_key, [CCode(array_length_type="guint16")] uint8[] data);
    public void callback_friend_request(FriendRequestCallback callback);

    /* Set the function that will be executed when a message from a friend is received.
     *  Function format is: function(int friendnumber, uint8_t * message, uint32_t length)
     */
    public delegate void FriendMessageCallback(Tox tox, int friend_number, [CCode(array_length_type="guint16")] uint8[] message);
    public void callback_friend_message(FriendMessageCallback callback);

    /* Set the function that will be executed when an action from a friend is received.
     *  Function format is: function(int friendnumber, uint8_t * action, uint32_t length)
     */
    public delegate void FriendActionCallback(Tox tox, int32 friend_number, [CCode(array_length_type="guint16")] uint8[] action);
    public void callback_friend_action(FriendActionCallback callback);

    /* Set the callback for name changes.
     *  function(int friendnumber, uint8_t *newname, uint16_t length)
     *  You are not responsible for freeing newname
     */
    public delegate void NameChangeCallback(Tox tox, int32 friend_number, [CCode(array_length_type="guint16")] uint8[] new_name);
    public void callback_name_change(NameChangeCallback callback);

    /* Set the callback for status message changes.
     *  function(int friendnumber, uint8_t *newstatus, uint16_t length)
     *  You are not responsible for freeing newstatus.
     */
    public delegate void StatusMessageCallback(Tox tox, int32 friend_number, [CCode(array_length_type="guint16")] uint8[] new_status);
    public void callback_status_message(StatusMessageCallback callback);

    /* Set the callback for status type changes.
     *  function(Tox *tox, int32_t friendnumber, uint8_t TOX_USERSTATUS, void *userdata)
     */
    public delegate void UserStatusCallback(Tox tox, int32 friend_number, uint8 user_status);
    public void callback_user_status(UserStatusCallback callback);

    /* Set the callback for typing changes.
     *  function (int friendnumber, uint8_t is_typing)
     */
    public delegate void TypingChangeCallback(Tox tox, int32 friendnumber, uint8 is_typing);
    public void callback_typing_change(TypingChangeCallback callback);

    /* Set the callback for read receipts.
     *  function(int friendnumber, uint32_t receipt)
     *
     *  If you are keeping a record of returns from m_sendmessage;
     *  receipt might be one of those values, meaning the message
     *  has been received on the other side.
     *  Since core doesn't track ids for you, receipt may not correspond to any message.
     *  In that case, you should discard it.
     */
    public delegate void ReadReceiptCallback(Tox tox, int32 friend_number, uint32 receipt);
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
    public delegate void ConnectionStatusCallback(Tox tox, int32 friend_number, uint8 status);
    public void callback_connection_status(ConnectionStatusCallback callback);


    /**********GROUP CHAT FUNCTIONS: WARNING WILL BREAK A LOT************/

    /* Set the callback for group invites.
     *
     *  Function(Tox *tox, int friendnumber, uint8_t *group_public_key, void *userdata)
     */
    public delegate void GroupInviteCallback(Tox tox, int32 friendnumber, [CCode(array_length=false)] uint8[] group_public_key);
    public void callback_group_invite(GroupInviteCallback callback);

    /* Set the callback for group messages.
     *
     *  Function(Tox *tox, int groupnumber, int friendgroupnumber, uint8_t * message, uint16_t length, void *userdata)
     */
    public delegate void GroupMessageCallback(Tox tox, int groupnumber, int friendgroupnumber, [CCode(array_length_type="guint16")] uint8[] message);
    public void callback_group_message(GroupMessageCallback callback);

    /* Set the callback for group actions.
     *
     *  Function(Tox *tox, int groupnumber, int friendgroupnumber, uint8_t * action, uint16_t length, void *userdata)
     */
     public delegate void GroupActionCallback(Tox tox, int groupnumber, int friendgroupnumber, [CCode(array_length_type="guint16")] uint8[] action);
     public void callback_group_action(GroupActionCallback callback);

    /* Set callback function for peer name list changes.
     *
     * It gets called every time the name list changes(new peer/name, deleted peer)
     *  Function(Tox *tox, int groupnumber, int peernumber, TOX_CHAT_CHANGE change, void *userdata)
     */
    public delegate void GroupNamelistChangeCallback(Tox tox, int groupnumber, int peernumber, ChatChange change);
    public void callback_group_namelist_change(GroupNamelistChangeCallback callback);

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
    public int invite_friend(int32 friendnumber, int groupnumber);

    /* Join a group (you need to have been invited first.)
     *
     * returns group number on success
     * returns -1 on failure.
     */
    public int join_groupchat(int32 friendnumber, [CCode(array_length=false)] uint8[] friend_group_public_key);

    /* send a group message
     * return 0 on success
     * return -1 on failure
     */
    public int group_message_send(int groupnumber, [CCode(array_length_type="guint32")] uint8[] message);
    
    /* send a group action
     * return 0 on success
     * return -1 on failure
     */
    public int group_action_send(int groupnumber, [CCode(array_length_type="guint32")] uint8[] action);

    /* Return the number of peers in the group chat on success.
     * return -1 on failure
     */
    public int group_number_peers(int groupnumber);

    /* List all the peers in the group chat.
     *
     * Copies the names of the peers to the name[length][TOX_MAX_NAME_LENGTH] array.
     *
     * returns the number of peers on success.
     *
     * return -1 on failure.
     */
    //FIXME
    //int tox_group_get_names(Tox *tox, int groupnumber, uint8_t names[][TOX_MAX_NAME_LENGTH], uint16_t length);

    /* Return the number of chats in the instance m.
     * You should use this to determine how much memory to allocate
     * for copy_chatlist.
     */
    public uint32 count_chatlist();

    /* Copy a list of valid chat IDs into the array out_list.
     * If out_list is NULL, returns 0.
     * Otherwise, returns the number of elements copied.
     * If the array was too small, the contents
     * of out_list will be truncated to list_size.
     */
    public uint32 get_chatlist([CCode(array_length_type="guint32")] int[] out_list);

    /******************END OF GROUP CHAT FUNCTIONS************************/

    /****************FILE SENDING FUNCTIONS*****************/
    /* NOTE: This how to will be updated.
     *
     * HOW TO SEND FILES CORRECTLY:
     * 1. Use tox_new_file_sender(...) to create a new file sender.
     * 2. Wait for the callback set with tox_callback_file_control(...) to be called with receive_send == 1 and control_type == TOX_FILECONTROL_ACCEPT
     * 3. Send the data with tox_file_send_data(...) with chunk size tox_file_data_size(...)
     * 4. When sending is done, send a tox_file_send_control(...) with send_receive = 0 and message_id = TOX_FILECONTROL_FINISHED
     *
     * HOW TO RECEIVE FILES CORRECTLY:
     * 1. wait for the callback set with tox_callback_file_send_request(...)
     * 2. accept or refuse the connection with tox_file_send_control(...) with send_receive = 1 and message_id = TOX_FILECONTROL_ACCEPT or TOX_FILECONTROL_KILL
     * 3. save all the data received with the callback set with tox_callback_file_data(...) to a file.
     * 4. when the callback set with tox_callback_file_control(...) is called with receive_send == 0 and control_type == TOX_FILECONTROL_FINISHED
     * the file is done transferring.
     *
     * tox_file_data_remaining(...) can be used to know how many bytes are left to send/receive.
     *
     * If the connection breaks during file sending (The other person goes offline without pausing the sending and then comes back)
     * the reciever must send a control packet with receive_send == 0 message_id = TOX_FILECONTROL_RESUME_BROKEN and the data being
     * a uint64_t (in host byte order) containing the number of bytes recieved.
     *
     * If the sender receives this packet, he must send a control packet with receive_send == 1 and control_type == TOX_FILECONTROL_ACCEPT
     * then he must start sending file data from the position (data , uint64_t in host byte order) recieved in the TOX_FILECONTROL_RESUME_BROKEN packet.
     *
     * More to come...
     */

    /* Set the callback for file send requests.
     *
     *  Function(Tox *tox, int friendnumber, uint8_t filenumber, uint64_t filesize, uint8_t *filename, uint16_t filename_length, void *userdata)
     */
    public delegate void FileSendRequestCallback(Tox tox, int32 friendnumber, uint8 filenumber, uint64 filesize, [CCode(array_length_type="guint16")] uint8[] filename);
    public void callback_file_send_request(FileSendRequestCallback callback);

    /* Set the callback for file control requests.
     *
     *  receive_send is 1 if the message is for a slot on which we are currently sending a file and 0 if the message
     *  is for a slot on which we are receiving the file
     *
     *  Function(Tox *tox, int friendnumber, uint8_t receive_send, uint8_t filenumber, uint8_t control_type, uint8_t *data, uint16_t length, void *userdata)
     *
     */
    public delegate void FileControlCallback(Tox tox, int32 friendnumber, uint8 receive_send, uint8 filenumber, uint8 status, [CCode(array_length_type="guint16")] uint8[] data);
    public void callback_file_control(FileControlCallback callback);

    /* Set the callback for file data.
     *
     *  Function(Tox *tox, int friendnumber, uint8_t filenumber, uint8_t *data, uint16_t length, void *userdata)
     *
     */
    public delegate void FileDataCallback(Tox tox, int32 friendnumber, uint8 filenumber, [CCode(array_length_type="guint16")] uint8[] data);
    public void callback_file_data(FileDataCallback callback);

    /* Send a file send request.
     * Maximum filename length is 255 bytes.
     *  return file number on success
     *  return -1 on failure
     */
     public int new_file_sender(int32 friendnumber, uint64 filesize, [CCode(array_length_type="guint16")] uint8[] filename);

    /* Send a file control request.
     *
     * send_receive is 0 if we want the control packet to target a file we are currently sending,
     * 1 if it targets a file we are currently receiving.
     *
     *  return 0 on success
     *  return -1 on failure
     */
    public int file_send_control(int32 friendnumber, uint8 send_receive, uint8 filenumber, uint8 message_id, [CCode(array_length_type="guint16")] uint8[]? data);

    /* Send file data.
     *
     *  return 0 on success
     *  return -1 on failure
     */
    public int file_send_data(int32 friendnumber, uint8 filenumber, [CCode(array_length_type="guint16")] uint8[] data);

    /* Returns the recommended/maximum size of the filedata you send with tox_file_send_data()
     *
     *  return size on success
     *  return 0 on failure (currently will never return 0)
     */
    public int file_data_size(int32 friendnumber);

    /* Give the number of bytes left to be sent/received.
     *
     *  send_receive is 0 if we want the sending files, 1 if we want the receiving.
     *
     *  return number of bytes remaining to be sent/received on success
     *  return 0 on failure
     */
    public uint64 file_data_remaining(int32 friendnumber, uint8 filenumber, uint8 send_receive);

    /***************END OF FILE SENDING FUNCTIONS******************/


    /*
     * Use this function to bootstrap the client.
     */

    /* Resolves address into an IP address. If successful, sends a "get nodes"
     *   request to the given node with ip, port (in network byte order, HINT: use htons())
     *   and public_key to setup connections
     *
     * address can be a hostname or an IP address (IPv4 or IPv6).
     * if ipv6enabled is 0 (zero), the resolving sticks STRICTLY to IPv4 addresses
     * if ipv6enabled is not 0 (zero), the resolving looks for IPv6 addresses first,
     *   then IPv4 addresses.
     *
     *  returns 1 if the address could be converted into an IP address
     *  returns 0 otherwise
     */
    public int bootstrap_from_address(string address, uint8 ipv6enabled,
                   uint16 port,[CCode(array_length=false)] uint8[] public_key);

    /*  return 0 if we are not connected to the DHT.
     *  return 1 if we are.
     */
    public int isconnected();

    // only here for completeness
    /* Run this before closing shop.
     * Free all datastructures. */
    //void tox_kill(Tox *tox);


    /* the main loop that needs to be run at least 20 times per second */
    public void do();
    
    /*
     * tox_wait_prepare(): function should be called under lock
     * Prepares the data required to call tox_wait_execute() asynchronously
     *
     * data[] is reserved and kept by the caller
     * len is in/out: in = reserved data[], out = required data[]
     *
     *  returns 1 on success
     *  returns 0 on failure (length is insufficient)
     */
    public int wait_prepare([CCode(array_length=false)]out uint8[] data, ref uint16 lenptr);

    /* tox_wait_execute(): function can be called asynchronously
     * Waits for something to happen on the socket for up to milliseconds milliseconds.
     * *** Function MUSTN'T poll. ***
     * The function mustn't modify anything at all, so it can be called completely
     * asynchronously without any worry.
     *
     *  returns  1 if there is socket activity (i.e. tox_do() should be called)
     *  returns  0 if the timeout was reached
     *  returns -1 if data was NULL or len too short
     */
    public int wait_execute([CCode(array_length_type="guint16")]uint8[] data, uint16 milliseconds);

    /* tox_wait_cleanup(): function should be called under lock
     * Stores results from tox_wait_execute().
     *
     * data[]/len shall be the exact same as given to tox_wait_execute()
     *
     */
    public void wait_cleanup([CCode(array_length_type="guint16")]uint8[] data);

    /* SAVING AND LOADING FUNCTIONS: */

    /* returns the size of messenger data (for saving) */
    public uint32 size();

    /* Save the messenger in data (must be allocated memory of size Messenger_size()). */
    public void save([CCode(array_length=false)] uint8[] data);

    /* Load the messenger from data of size length. */
    public int load([CCode(array_length_type = "guint32")] uint8[] data);
  }
}

namespace Vpx {
  [CCode (cname = "vpx_img_fmt_t", cprefix = "VPX_IMG_FMT_", has_type_id = false)]
  public enum ImageFormat {
    RGB24,      // 24 bit per pixel packed RGB
    RGB32,      // 32 bit per pixel packed 0RGB
    RGB565,     // 16 bit per pixel, 565
    RGB555,     // 16 bit per pixel, 555
    UYVY,       // UYVY packed YUV
    YUY2,       // YUYV packed YUV
    YVYU,       // YVYU packed YUV
    BGR24,      // 24 bit per pixel packed BGR
    RGB32_LE,   // 32 bit packed BGR0
    ARGB,       // 32 bit packed ARGB, alpha=255
    ARGB_LE,    // 32 bit packed BGRA, alpha=255
    RGB565_LE,  // 16 bit per pixel, gggbbbbb rrrrrggg
    RGB555_LE,  // 16 bit per pixel, gggbbbbb 0rrrrrgg
    YV12,       // planar YVU
    VPXI420     // < planar 4:2:0 format with vpx color space
  }

  [CCode (cname = "vpx_image_t", free_function = "vpx_image_free", cprefix = "vpx_image_", has_type_id = false)]
  public class Image {
    [CCode (cname = "fmt")]
    public ImageFormat fmt;
    [CCode (cname = "w")]
    public uint w;
    [CCode (cname = "h")]
    public uint h;
    [CCode (cname = "d_w")]
    public uint d_w;
    [CCode (cname = "d_h")]
    public uint d_h;
    [CCode (cname = "x_chroma_shift")]
    public uint x_chroma_shift;
    [CCode (cname = "y_chroma_shift")]
    public uint y_chroma_shift;
    [CCode (cname = "planes")]
    public uint8[][] planes;
    [CCode (cname = "stride")]
    public int[] stride;
    [CCode (cname = "bps")]
    public int bps;
    //void* user_priv
    [CCode (cname = "img_data")]
    public uint8[] img_data;
    [CCode (cname = "img_data_owner")]
    public int img_data_owner;
    [CCode (cname = "self_alloced")]
    public int self_alloced;

    [CCode (cname = "vpx_image_alloc")]
    public Image(ImageFormat fmt, uint d_w, uint d_h, uint align);

    public Image wrap(ImageFormat fmt, uint d_w, uint d_h, uint align, [CCode(array_length=false)] uint8[] img_data);

    public int set_rect(uint x, uint y, uint w, uint h);

    public void flip();
  }
}

[CCode (cheader_filename = "tox/toxav.h", cprefix = "")]
namespace ToxAV {

  public const int RTP_PAYLOAD_SIZE;

  /**
   * @brief Callbacks ids that handle the call states.
   */
  [CCode (cname = "ToxAvCallbackID", cprefix = "av_On", has_type_id = false)]
  public enum CallbackID {
    /* Requests */
    [CCode (cname = "av_OnInvite")]
    INVITE,
    [CCode (cname = "av_OnStart")]
    START,
    [CCode (cname = "av_OnCancel")]
    CANCEL,
    [CCode (cname = "av_OnReject")]
    REJECT,
    [CCode (cname = "av_OnEnd")]
    END,

    /* Responses */
    [CCode (cname = "av_OnRinging")]
    RINGING,
    [CCode (cname = "av_OnStarting")]
    STARTING,
    [CCode (cname = "av_OnEnding")]
    ENDING,

    /* Protocol */
    [CCode (cname = "av_OnError")]
    ERROR,
    [CCode (cname = "av_OnRequestTimeout")]
    REQUEST_TIMEOUT,
    [CCode (cname = "av_OnPeerTimeout")]
    PEER_TIMEOUT
  }

  /**
   * @brief Call type identifier.
   */
  [CCode (cname = "ToxAvCallType", cprefix = "Type", has_type_id = false)]
  public enum CallType {
    [CCode (cname = "TypeAudio")]
    AUDIO,
    [CCode (cname = "TypeVideo")]
    VIDEO
  }

  /**
   * @brief Error indicators.
   *
   */
  [CCode (cname = "ToxAvError", cprefix = "Error", has_type_id = false)]
  public enum AV_Error {
    [CCode (cname = "ErrorNone")]
    NONE,
    [CCode (cname = "ErrorInternal")]
    INTERNAL,
    [CCode (cname = "ErrorAlreadyInCall")]
    ALREADY_IN_CALL,
    [CCode (cname = "ErrorNoCall")]
    NO_CALL,
    [CCode (cname = "ErrorInvalidState")]
    INVALID_STATE,
    [CCode (cname = "ErrorNoRtpSession")]
    NO_RTP_SESSION,
    [CCode (cname = "ErrorAudioPacketLost")]
    AUDIO_PACKET_LOST,
    [CCode (cname = "ErrorStartingAudioRtp")]
    STARTING_AUDIO_RTP,
    [CCode (cname = "ErrorStartingVideoRtp")]
    STARTING_VIDEO_RTP,
    [CCode (cname = "ErrorTerminatingAudioRtp")]
    TERMINATING_AUDIO_RTP,
    [CCode (cname = "ErrorTerminatingVideoRtp")]
    TERMINATING_VIDEO_RTP
  }

  /**
   * @brief Locally supported capabilities.
   */
  [Flags]
  [CCode (cname = "ToxAvCapabilities", cprefix = "", has_type_id = false)]
  public enum Capabilities {
    [CCode (cname = "None")]
    NONE,
    [CCode (cname = "AudioEnconding")]
    AUDIO_ENCODING,
    [CCode (cname = "AudioDecoding")]
    AUDIO_DECODING,
    [CCode (cname = "VideoEncoding")]
    VIDEO_ENCODING,
    [CCode (cname = "VideoDecoding")]
    VIDEO_DECODING
  }

  /**
   * @brief Encoding settings.
   */
  [CCode (cname = "ToxAvCodecSettings", destroy_function = "", cprefix = "", has_copy_function = false, has_type_id = false)]
  public struct CodecSettings {
      uint32 video_bitrate; /* In bits/s */
      uint16 video_width; /* In px */
      uint16 video_height; /* In px */
      
      uint32 audio_bitrate; /* In bits/s */
      uint16 audio_frame_duration; /* In ms */
      uint32 audio_sample_rate; /* In Hz */
      uint32 audio_channels;
      
      uint32 jbuf_capacity; /* Size of jitter buffer */
  }

  [CCode (cname = "av_DefaultSettings", has_type_id = false)]
  public const CodecSettings DefaultCodecSettings;

  /**
   * @brief Register callback for call state.
   *
   * @param callback The callback
   * @param id One of the ToxAvCallbackID values
   * @return void
   */
  //typedef void ( *ToxAVCallback ) ( void *arg );
  [CCode (cname = "ToxAVCallback", has_type_id = false)]
  public delegate void CallstateCallback ();
  //FIXME
  [CCode (cname = "toxav_register_callstate_callback", has_type_id = false)]
  public static void register_callstate_callback ([CCode( delegate_target_pos = 3 )] CallstateCallback callback, CallbackID id);


  [CCode (cname = "ToxAv", free_function = "toxav_kill", cprefix = "toxav_", has_type_id = false)]
  [Compact]
  public class ToxAV {
    /**
     * @brief Start new A/V session. There can only be one session at the time. If you register more
     *        it will result in undefined behaviour.
     *
     * @param messenger The messenger handle.
     * @param userdata The agent handling A/V session (i.e. phone).
     * @param video_width Width of video frame.
     * @param video_height Height of video frame.
     * @return ToxAv*
     * @retval NULL On error.
     */
    [CCode (cname = "toxav_new")]
    public ToxAV(Tox.Tox messenger, CodecSettings codec_settings);

    /* #### only here for completeness #### */
    ///**
    // * @brief Remove A/V session.
    // *
    // * @param av Handler.
    // * @return void
    // */
    //void toxav_kill(ToxAv *av);

    /**
     * @brief Call user. Use its friend_id.
     *
     * @param av Handler.
     * @param user The user.
     * @param call_type Call type.
     * @param ringing_seconds Ringing timeout.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error call(int user, CallType call_type, int ringing_seconds);

    /**
     * @brief Hangup active call.
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error hangup();

    /**
     * @brief Answer incomming call.
     *
     * @param av Handler.
     * @param call_type Answer with...
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error answer(CallType call_type );

    /**
     * @brief Reject incomming call.
     *
     * @param av Handler.
     * @param reason Optional reason. Set NULL if none.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error reject(string reason);

    /**
     * @brief Cancel outgoing request.
     *
     * @param av Handler.
     * @param reason Optional reason.
     * @param peer_id peer friend_id
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error cancel(int peer_id, string reason);

    /**
     * @brief Terminate transmission. Note that transmission will be terminated without informing remote peer.
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error stop_call();

    /**
     * @brief Must be call before any RTP transmission occurs.
     *
     * @param av Handler.
     * @param support_video Is video supported ? 1 : 0
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error prepare_transmission(int support_video);

    /**
     * @brief Call this at the end of the transmission.
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error kill_transmission();

    /**
     * @brief Receive decoded video packet.
     *
     * @param av Handler.
     * @param output Storage.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On Error.
     */
    public AV_Error recv_video ( out Vpx.Image output);

    /**
     * @brief Receive decoded audio frame.
     *
     * @param av Handler.
     * @param frame_size ...
     * @param dest Destination of the packet. Make sure it has enough space for
     *             RTP_PAYLOAD_SIZE bytes.
     * @return int
     * @retval >=0 Size of received packet.
     * @retval ToxAvError On error.
     */
    public AV_Error recv_audio( int frame_size, [CCode(array_length=false)] int16[] dest );

    /**
     * @brief Encode and send video packet.
     *
     * @param av Handler.
     * @param input The packet.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error send_video ( Vpx.Image input);

    /**
     * @brief Encode and send audio frame.
     *
     * @param av Handler.
     * @param frame The frame.
     * @param frame_size It's size.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error send_audio ( [CCode(array_length_type="int")] int16[] frame);

    /**
     * @brief Get peer transmission type. It can either be audio or video.
     *
     * @param av Handler.
     * @param peer The peer
     * @return int
     * @retval ToxAvCallType On success.
     * @retval ToxAvError On error.
     */
    public AV_Error get_peer_transmission_type ( int peer );

    /**
     * @brief Get id of peer participating in conversation
     * 
     * @param av Handler
     * @param peer peer index
     * @return int
     * @retval ToxAvError No peer id
     */
    public AV_Error get_peer_id ( int peer );

    /**
     * @brief Is certain capability supported
     * 
     * @param av Handler
     * @return int
     * @retval 1 Yes.
     * @retval 0 No.
     */
    public int capability_supported ( Capabilities capability );

    /**
     * @brief Get messenger handle
     * 
     * @param av Handler.
     * @return Tox*
     */
    public Tox.Tox tox_handle {
      [CCode (cname = "toxav_get_tox")] get;
    }
  }
}


