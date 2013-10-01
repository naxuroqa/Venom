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

namespace Testing {
  public class GroupTest {
    private Tox.Tox tox;
    private int groupchat_number = 0;
    private Gee.List<int> new_contacts = new Gee.ArrayList<int>();
    private Gee.List<int> online_contacts = new Gee.ArrayList<int>();
    public GroupTest( bool ipv6 = false ) {
      tox = new Tox.Tox(ipv6 ? 1 : 0);
      tox.callback_friendrequest(on_friend_request);
      tox.callback_group_message(on_groupchat_message);
      tox.callback_connectionstatus(on_connection_status);
    }

    public void on_connection_status(Tox.Tox tox, int friend_number, uint8 status) {
      if(status != 1)
        return;
      if(!new_contacts.contains(friend_number))
        return;
        
      new_contacts.remove(friend_number);
      online_contacts.add(friend_number);
    }

    public void on_groupchat_message(Tox.Tox tox, int groupnumber, int friendgroupnumber, uint8[] message) {
      uint8[] name_buf = new uint8[Tox.MAX_NAME_LENGTH];
      tox.getname(friendgroupnumber, name_buf);
      string friend_name = (string)name_buf;
      stdout.printf("%s: %s\n", friend_name, (string)message);
    }

    public void on_friend_request(uint8[] key, uint8[] data) {
      uint8[] public_key = Venom.Tools.clone(key, Tox.CLIENT_ID_SIZE);
      stdout.printf("Friend request from %s received.\n", Venom.Tools.bin_to_hexstring(public_key));
      int friend_number = tox.addfriend_norequest(public_key);
      if(friend_number < 0) {
        stdout.printf("Friend could not be added :%i\n", friend_number);
        return;
      }
      
      new_contacts.add(friend_number);
      
    }
    public void run_group_test(string ip_string, string pub_key_string, int port = 33445, int timeout = 5000, bool ipv6 = true) {
      string ip_address = ip_string;
      uint16 ip_port_be = ((uint16)port).to_big_endian();
      uint8[] pub_key = Venom.Tools.hexstring_to_bin(pub_key_string);
      
      stdout.printf("Connecting to: %s:%u\n", ip_address, uint16.from_big_endian(ip_port_be));
      stdout.printf("Public key:    %s\n", pub_key_string);

      tox.bootstrap_from_address(ip_address, ipv6 ? 1 : 0, ip_port_be, pub_key);
      
      stdout.printf("-----------------------------------\n");
      
      uint8[] buf = new uint8[Tox.FRIEND_ADDRESS_SIZE];
      tox.getaddress(buf);
      stdout.printf("Address: %s\n", Venom.Tools.bin_to_hexstring(buf));
      
      tox.setname(Venom.Tools.string_to_nullterm_uint("Groupchat bot"));
      
      groupchat_number = tox.add_groupchat();
      stdout.printf("Created new groupchat %i\n", groupchat_number);
      
      bool connected = false;
      bool running = true;
      while( running ) {
        bool new_status = (tox.isconnected() != 0);
        if(new_status != connected) {
          connected = new_status;
          if(connected)
            stdout.printf("Connected to %s.\n", ip_address);
          else
            stdout.printf("Connection to %s lost.\n", ip_address);
        }
        
        foreach(int friend_number in online_contacts) {
          uint8[] name_buf = new uint8[Tox.MAX_NAME_LENGTH];
          tox.getname(friend_number, name_buf);
          string friend_name = (string)name_buf;
          
          stdout.printf("Friend %s came online, inviting him to groupchat.\n", friend_name);
          tox.sendmessage(friend_number, Venom.Tools.string_to_nullterm_uint("Trying to invite you to my groupchat..."));
          
          if(tox.invite_friend(friend_number, groupchat_number) == 0) {
            stdout.printf("Successfully invited friend %i to groupchat %i.\n", friend_number, groupchat_number);
            tox.sendmessage(friend_number, Venom.Tools.string_to_nullterm_uint("Success!"));
            tox.group_message_send(groupchat_number, Venom.Tools.string_to_nullterm_uint("%s was invited to groupchat.".printf(friend_name)));
            online_contacts.remove(friend_number);//FIXME this may be a very bad idea
          } else {
            stdout.printf("Could not invite friend %i to groupchat %i.\n", friend_number, groupchat_number);
            tox.sendmessage(friend_number, Venom.Tools.string_to_nullterm_uint("Failed :/"));
          }
        }
        tox.do();
        Thread.usleep(10000);
      }
    }

    public static void main(string[] args) {
      GroupTest test = new GroupTest();
      test.run_group_test("54.215.145.71",  "6EDDEE2188EF579303C0766B4796DCBA89C93058B6032FEA51593DCD42FB746C");
      stdout.printf("Grouptest shut down.\n");
    }
  }
}
