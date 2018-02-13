/*
 *    GroupBot.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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

using ToxCore;

namespace Testing {
  public class GroupBot : Object {
    private const string DEFAULT_CHANNEL = "tox-ontopic";

    private Tox tox;
    private HashTable<string, uint32> channels;
    private Connection connection_status = Connection.NONE;
    private static bool running = true;

    public GroupBot() {
      channels = new HashTable<string, uint32>(str_hash, str_equal);

      var optionsErr = ErrOptionsNew.OK;
      var options = new Options(ref optionsErr);

      var file = File.new_for_path("groupbot.data");
      try {
        file.load_contents(null, out options.savedata_data, null);
        options.savedata_type = SaveDataType.TOX_SAVE;
      } catch (Error e) {
        stdout.printf("[LOG] Could not read tox savefile: %s\n", e.message);
      }

      var err = ErrNew.OK;
      tox = new Tox(options, ref err);
      if (err != ErrNew.OK) {
        stderr.printf("[FTL] Could not create new tox instance: %s\n", err.to_string());
        assert_not_reached();
      }

      tox.callback_friend_request(on_friend_request);
      tox.callback_friend_message(on_friend_message);
      tox.callback_friend_connection_status(on_friend_connection_status);
      tox.callback_conference_invite(on_conference_invite);
      tox.callback_conference_message(on_conference_message);
      tox.callback_conference_namelist_change(on_conference_namelist_change);

      add_channel(DEFAULT_CHANNEL);
    }

    ~GroupBot() {
      var file = File.new_for_path("groupbot.data");
      try {
        file.replace_contents(tox.get_savedata(), null, false, FileCreateFlags.NONE, null, null);
      } catch (Error e) {
        stderr.printf("[ERR] Saving tox session data failed: %s\n", e.message);
      }
    }

    private uint32 add_channel(string name) {
      var err = ErrConferenceNew.OK;
      var channel_number = tox.conference_new(ref err);
      if (err != ErrConferenceNew.OK) {
        stderr.printf("[ERR] Creating new channel \"%s\" failed: %s\n", name, err.to_string());
      } else {
        stdout.printf("[LOG] Created new channel #%s [%u]\n", name, channel_number);
        channels.set(name, channel_number);
      }
      return channel_number;
    }

    private static string get_friend_name(Tox tox, uint32 friend_number) {
      var err = ErrFriendQuery.OK;
      var name = tox.friend_get_name(friend_number, ref err);
      if (err != ErrFriendQuery.OK) {
        stderr.printf("[ERR] Could not query friend name: %s\n", err.to_string());
        name = "FRIEND #%u".printf(friend_number);
      }
      return name;
    }

    private static void on_conference_invite(Tox tox, uint32 friend_number, ConferenceType type, uint8[] cookie, void *user_data) {
      stdout.printf("[CI ] from %s\n", get_friend_name(tox, friend_number));
      var err = ErrConferenceJoin.OK;
      tox.conference_join(friend_number, cookie, ref err);
      if (err != ErrConferenceJoin.OK) {
        stderr.printf("[ERR] Could not join conference: %s\n", err.to_string());
      }
    }

    private static string get_peer_name(Tox tox, uint32 conference_number, uint32 peer_number) {
      var err = ErrConferencePeerQuery.OK;
      var name = tox.conference_peer_get_name(conference_number, peer_number, ref err);
      if (err != ErrConferencePeerQuery.OK) {
        stderr.printf("[ERR] Could not get name for peer #%u: %s\n", peer_number, err.to_string());
        return "PEER #%u".printf(peer_number);
      }
      return name;
    }

    private static void on_conference_message(Tox tox, uint32 conference_number, uint32 peer_number, MessageType type, uint8[] message, void* data) {
      var name = get_peer_name(tox, conference_number, peer_number);
      stdout.printf("[CM ] %s: %s\n", name, (string) message);
    }

    private static void on_conference_namelist_change(Tox tox, uint32 conference_number, uint32 peer_number, ConferenceStateChange change, void* data) {
      var name = get_peer_name(tox, conference_number, peer_number);
      if (change == ConferenceStateChange.PEER_JOIN || change == ConferenceStateChange.PEER_EXIT) {
        var change_str = change == ConferenceStateChange.PEER_JOIN ? "joined" : "exited";
        stdout.printf("[CC ] %s %s\n", name, change_str);
      } else {
        stdout.printf("[CC ] %s %s\n", name, change.to_string());
      }
    }

    private static void on_friend_request(Tox tox, uint8[] key, uint8[] message, void* data) {
      var pub_key = copy_data(key, address_size());
      stdout.printf("[LOG] Friend request from %s received.\n", Venom.Tools.bin_to_hexstring(pub_key));
      var err = ErrFriendAdd.OK;
      tox.friend_add_norequest(pub_key, ref err);
      if (err != ErrFriendAdd.OK) {
        stderr.printf("[ERR] Could not add friend: %s\n", err.to_string());
      }
    }

    private static void on_friend_connection_status(Tox tox, uint32 friend_number, Connection connection_status, void* data) {
      var name = get_friend_name(tox, friend_number);
      stdout.printf("[LOG] Connection status changed for friend #%u (%s): %s\n", friend_number, name, connection_status.to_string());
      if (connection_status == Connection.NONE) {
        return;
      }
      var err = ErrFriendSendMessage.OK;
      tox.friend_send_message(friend_number, MessageType.NORMAL, "info", ref err);
      if (err != ErrFriendSendMessage.OK) {
        stderr.printf("[ERR] Could not send message to %u: %s\n", friend_number, err.to_string());
        return;
      }
      tox.friend_send_message(friend_number, MessageType.NORMAL, "invite", ref err);
      if (err != ErrFriendSendMessage.OK) {
        stderr.printf("[ERR] Could not send message to %u: %s\n", friend_number, err.to_string());
        return;
      }
    }

    private static void on_friend_message(Tox tox, uint32 friend_number, MessageType type, uint8[] message, void* data) {
      var gb = data as GroupBot;
      var name = get_friend_name(tox, friend_number);
      var message_str = copy_data_string(message);
      stdout.printf("[LOG] Message from %s: %s\n", name, message_str);
      if (message_str.has_prefix("invite")) {
        var error = ErrConferenceInvite.OK;
        tox.conference_invite(friend_number, gb.channels.@get(DEFAULT_CHANNEL), ref error);
        if (error != ErrConferenceInvite.OK) {
          stderr.printf("[ERR] Could not invite %s to channel %u\n", name, gb.channels.@get(DEFAULT_CHANNEL));
          return;
        }
        stdout.printf("[LOG] Sent an invite to %s\n", name);
      }
    }

    private static string copy_data_string(uint8[] data) {
      var t = new uint8[data.length + 1];
      Memory.copy(t, data, data.length);
      return (string) t;
    }

    private static uint8[] copy_data(uint8[] data, uint len) {
      var t = new uint8[len];
      Memory.copy(t, data, len);
      return t;
    }

    public void run(string ip_string, string pub_key_string, uint16 port = 33445)
    requires(pub_key_string != null && ip_string != null && port != 0) {
      stdout.printf("[LOG] Running Groupbot\n");
      var pub_key = Venom.Tools.hexstring_to_bin(pub_key_string);

      assert(pub_key.length == public_key_size());
      stdout.printf("[LOG] Bootstrap node: %s:%u.\n", ip_string, port);

      stdout.printf("[LOG] Bootstrapping...\n");
      var error_bootstrap = ErrBootstrap.OK;
      if (!tox.bootstrap(ip_string, (uint16) port, pub_key, ref error_bootstrap)) {
        stderr.printf("[ERR] Bootstrapping failed: %s\n", error_bootstrap.to_string());
        return;
      }

      stdout.printf("[LOG] Bootstrapping done.\n");
      stdout.printf("[LOG] Tox ID: %s\n", Venom.Tools.bin_to_hexstring(tox.self_get_address()));

      var setNameError = ErrSetInfo.OK;
      if (!tox.self_set_name("Groupbot", ref setNameError) || setNameError != ErrSetInfo.OK) {
        stderr.printf("[ERR] Setting user name failed: %s\n", setNameError.to_string());
        return;
      }

      stdout.printf("[LOG] Connecting...\n");
      while (running) {
        var new_connection_status = tox.self_get_connection_status();
        if (new_connection_status != connection_status) {
          switch (new_connection_status) {
            case Connection.NONE:
              stdout.printf("[LOG] Not Connected.\n");
              break;
            case Connection.UDP:
            case Connection.TCP:
              stdout.printf("[LOG] Connected.\n");
              var groupbot_pub_key = Venom.Tools.hexstring_to_bin("56A1ADE4B65B86BCD51CC73E2CD4E542179F47959FE3E0E21B4B0ACDADE51855D34D34D37CB5");
              var addFriendErr = ErrFriendAdd.OK;
              tox.friend_add(groupbot_pub_key, "Please add me", ref addFriendErr);
              if (addFriendErr != ErrFriendAdd.OK) {
                stderr.printf("[ERR] Could not add friend: %s\n", addFriendErr.to_string());
              } else {
                stdout.printf("[LOG] Friend request sent.\n");
              }
              break;
          }
          connection_status = new_connection_status;
        }

        tox.iterate(this);
        MainContext.@default().iteration(false);
        Thread.usleep(tox.iteration_interval() * 1000);
      }
      stdout.printf("[LOG] Saved tox data, exiting now.\n");
    }

    private static bool on_sig_int() {
      running = false;
      return false;
    }

    public static void main(string[] args) {
      Unix.signal_add(Posix.SIGINT, on_sig_int, Priority.HIGH);
      var bot = new GroupBot();
      bot.run("node.tox.biribiri.org", "F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67");
    }
  }
}
