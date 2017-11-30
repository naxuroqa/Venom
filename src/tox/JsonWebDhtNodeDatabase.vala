/*
 *    JsonWebDhtNodeDatabase.vala
 *
 *    Copyright (C) 2017  Venom authors and contributors
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

namespace Venom {
  public class JsonWebDhtNodeDatabase : IDhtNodeDatabase, Object {
    private ILogger logger;
    public JsonWebDhtNodeDatabase(ILogger logger) {
      this.logger = logger;
    }
    public List<IDhtNode> getDhtNodes(IDhtNodeFactory factory) {
      var dhtNodes = new List<IDhtNode>();

      var uri = "https://nodes.tox.chat/json";

      var session = new Soup.Session();
      var message = new Soup.Message("GET", uri);
      session.send_message(message);

      try {
        var parser = new Json.Parser();
        parser.load_from_data((string) message.response_body.flatten().data, -1);

        var root_object = parser.get_root().get_object();
        //var last_scan = (uint) root_object.get_int_member("last_scan");
        //var last_refresh = (uint) root_object.get_int_member("last_refresh");

        var nodes = root_object.get_array_member("nodes");

        foreach (var node in nodes.get_elements()) {
          var nodeObj = node.get_object();
          var ipv4 = nodeObj.get_string_member("ipv4");
          //var ipv6 = nodeObj.get_string_member("ipv6");
          var port = (int) nodeObj.get_int_member("port");
          var key = nodeObj.get_string_member("public_key");
          var maintainer = nodeObj.get_string_member("maintainer");
          var location = nodeObj.get_string_member("location");
          //var statusUdp = nodeObj.get_boolean_member("status_udp");
          //var statusTcp = nodeObj.get_boolean_member("status_tcp");
          //var version = nodeObj.get_string_member("version");
          //var motd = nodeObj.get_string_member("motd");
          //var last_ping = nodeObj.get_int_member("last_ping");

          var dhtNode = factory.createDhtNode(key, ipv4, port, false, maintainer, location);
          dhtNodes.append(dhtNode);
        }
      } catch (Error e) {
        logger.e("Failed to load dht nodes from uri: " + e.message);
      }
      return dhtNodes;
    }

    public void insertDhtNode(string key, string address, uint port, bool isBlocked, string owner, string location) {}
    public void deleteDhtNode(string key) {}
  }
}
