/*
 *    GroupBot.vala
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

namespace Testing {
  public class GroupBot : GLib.Object {
    private delegate void ActionDelegate(string action_string, int friend_number);
    private class ActionWrapper : GLib.Object {
      public ActionDelegate action;
      public ActionWrapper(ActionDelegate action) {
        this.action = action;
      }
    }
    public const string DEFAULT_CHANNEL = "tox-ontopic";
    private Tox.Tox tox;
    private HashTable<string, int> channels = new HashTable<string, int>(str_hash, str_equal);
    private HashTable<string, ActionWrapper> actions = new HashTable<string, ActionWrapper>(str_hash, str_equal);
    public GroupBot( bool ipv6 = false ) {
      tox = new Tox.Tox(ipv6 ? 1 : 0);
      tox.callback_friend_request(on_friend_request);
      tox.callback_friend_message(on_friend_message);
      tox.callback_group_message(on_groupchat_message);
      tox.callback_group_namelist_change(on_group_namelist_change);

      actions.insert("j",    new ActionWrapper(on_action_join));
      actions.insert("join", new ActionWrapper(on_action_join));
      actions.insert("h",    new ActionWrapper(on_action_help));
      actions.insert("help", new ActionWrapper(on_action_help));
      
      add_channel(DEFAULT_CHANNEL);
    }
    
    private int add_channel(string name) {
      int channel_number = tox.add_groupchat();
      if(channel_number < 0) {
        stderr.printf("[ERR] Creating a new channel %s failed.\n", name);
      } else {
        stdout.printf("[LOG] Created new channel #%s [%i]\n", name, channel_number);
        channels.set(name, channel_number);
      }
      return channel_number;
    }

    private string get_name(int friend_number) {
      uint8[] name_buf = new uint8[Tox.MAX_NAME_LENGTH];
      if( tox.get_name(friend_number, name_buf) < 0) {
        stderr.printf("[ERR] Could not get name for friend #%i\n", friend_number);
      }
      return (string) name_buf;
    }

    private void on_action_join(string action_string, int friend_number) {
      string name = get_name(friend_number);
      stdout.printf("[LOG] Join action from %s: /j %s\n", name, action_string);
      string channel = DEFAULT_CHANNEL;
      int channel_number = -1;

      if(action_string != "") {
        GLib.Regex channel_regex = null;
        GLib.MatchInfo info = null;
        try {
          channel_regex = new GLib.Regex("^#?(?P<channel_string>[[:alnum:]]+(-[[:alnum:]]+)*)$");
        } catch (GLib.RegexError e) {
          stderr.printf("Can't create action regex: %s.\n", e.message);
          return;
        }
        if( channel_regex.match(action_string, 0, out info) ) {
          string channel_string = info.fetch_named("channel_string");
          if(channel_string != null)
            channel = channel_string;
        } else {
          stdout.printf("[LOG] Join action with invalid channel\n");
        }
      }
      
      if(channels.contains(channel)) {
        channel_number = channels.get(channel);
      } else {
        channel_number = add_channel(channel);
      }
      stdout.printf("[LOG] Inviting '%s' to channel #%s [%i]\n", name, channel, channel_number);
      if(tox.invite_friend(friend_number, channel_number) != 0) {
        stderr.printf("[ERR] Failed to invite '%s' to channel #%s\n", name, channel);
      }
    }
    
    private void on_action_help(string action_string, int friend_number) {
      string name = get_name(friend_number);
      stdout.printf("[LOG] Help action from %s: %s\n", name, action_string);
      send_message(friend_number, "Currently supported commands: j, join, h, help, invite");
    }

    private void on_groupchat_message(Tox.Tox tox, int groupnumber, int friendgroupnumber, uint8[] message) {
      uint8[] name_buf = new uint8[Tox.MAX_NAME_LENGTH];
      if( tox.group_peername(groupnumber, friendgroupnumber, name_buf) < 0 ) {
        stderr.printf("[ERR] Could not get name for peer #%i\n", friendgroupnumber);
      }
      string friend_name = (string)name_buf;
      stdout.printf("[GM ] %s: %s\n", friend_name, (string)message);
    }

    private void on_group_namelist_change(Tox.Tox tox, int groupnumber, int peernumber, Tox.ChatChange change) {
      if(change == Tox.ChatChange.PEER_ADD || change == Tox.ChatChange.PEER_DEL) {
        stdout.printf("[LOG] Peer connected/disconnect, updating status message\n");
        update_status_message();
      }
    }

    private void on_friend_request(uint8[] key, uint8[] data) {
      uint8[] public_key = Venom.Tools.clone(key, Tox.CLIENT_ID_SIZE);
      stdout.printf("[LOG] Friend request from %s received.\n", Venom.Tools.bin_to_hexstring(public_key));
      Tox.FriendAddError friend_number = tox.add_friend_norequest(public_key);
      if(friend_number < 0) {
        stderr.printf("[ERR] Friend could not be added :%s\n", Venom.Tools.friend_add_error_to_string(friend_number));
      }
    }
    
    private bool send_message(int friend_number, string message) {
      return tox.send_message(friend_number, 
        Venom.Tools.string_to_nullterm_uint(message)) != 0;
    }

    private void on_friend_message(Tox.Tox tox, int friend_number, uint8[] message) {
      string name = get_name(friend_number);
      string message_str = (string) message;
      stdout.printf("[PM ] %s: %s\n", name, message_str);

      GLib.MatchInfo info = null;
      if(message_str == "invite") {
        int groupchat_number = channels.get(DEFAULT_CHANNEL);
        stdout.printf("[LOG] Inviting '%s' to default groupchat #%i\n", name, groupchat_number);
        if(tox.invite_friend(friend_number, groupchat_number) != 0) {
          stderr.printf("[ERR] Failed to invite '%s' to groupchat #%i\n", name, groupchat_number);
        }
      } else if (Venom.Tools.action_regex.match(message_str, 0, out info)) {
        string action_name = info.fetch_named("action_name");
        string action_string = info.fetch_named("action_string");
        ActionWrapper w = actions.get(action_name);
        if(w != null) {
          w.action(action_string != null ? action_string : "", friend_number);
        } else {
          stderr.printf("[ERR] Action \"%s\" not understood.\n", action_name);
          send_message(friend_number, "Error: action %s not understood.".printf(action_name));
        }
      }
    }

    private void update_status_message() {
      int group_number_peers = tox.group_number_peers(channels.get(DEFAULT_CHANNEL));
      string status_message = "send me 'invite' to get invited to groupchat (%i online)".printf(group_number_peers);
      if(group_number_peers < 0 || tox.set_status_message(Venom.Tools.string_to_nullterm_uint(status_message)) < 0) {
        stderr.printf("[ERR] Setting status message failed.\n");
      }
    }

    public void run(string ip_string, string pub_key_string, int port = 33445, bool ipv6 = true) {
      tox.bootstrap_from_address(ip_string,
          ipv6 ? 1 : 0,
          ((uint16)port).to_big_endian(),
          Venom.Tools.hexstring_to_bin(pub_key_string)
      );

      uint8[] buf = new uint8[Tox.FRIEND_ADDRESS_SIZE];
      tox.get_address(buf);
      stdout.printf("[LOG] Tox ID: %s\n", Venom.Tools.bin_to_hexstring(buf));

      if(tox.set_name(Venom.Tools.string_to_nullterm_uint("Group bot")) != 0) {
        stderr.printf("[ERR] Setting user name failed.\n");
      }

      update_status_message();

      bool connection_status = false;
      bool running = true;
      while( running ) {
        bool new_connection_status = (tox.isconnected() != 0);
        if(new_connection_status != connection_status) {
          connection_status = new_connection_status;
          if(connection_status)
            stdout.printf("[LOG] Connected to DHT.\n");
          else
            stdout.printf("[LOG] Connection to DHT lost.\n");
        }

        tox.do();
        Thread.usleep(25000);
      }
    }

    public static void main(string[] args) {
      GroupBot bot = new GroupBot();
      bot.run("66.175.223.88", "B24E2FB924AE66D023FE1E42A2EE3B432010206F751A2FFD3E297383ACF1572E");
    }
  }
}
