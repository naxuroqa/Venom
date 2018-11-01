/*
 *    JsonWebDhtNodeDatabase.vala
 *
 *    Copyright (C) 2017-2018 Venom authors and contributors
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
  public class JsonDhtNode : GLib.Object {
    public string ipv4 { get; set; }
    public string ipv6 { get; set; }
    public int port { get; set; }
    //public int[] tcp_ports { get; set; }
    public string public_key { get; set; }
    public string maintainer { get; set; }
    public string location { get; set; }
    public bool status_udp { get; set; }
    public bool status_tcp { get; set; }
    public string version { get; set; }
    public string motd { get; set; }
    public int last_ping { get; set; }
  }

  public class JsonWebDhtNodeUpdater : GLib.Object {
    private ILogger logger;
    public JsonWebDhtNodeUpdater(ILogger logger) {
      this.logger = logger;
    }

    public Gee.Iterable<IDhtNode> get_dht_nodes() {
      var dht_nodes = new Gee.LinkedList<IDhtNode>();

      var uri = "https://nodes.tox.chat/json";

      var session = new Soup.Session();
      var message = new Soup.Message("GET", uri);
      session.send_message(message);

      try {
        var parser = new Json.Parser();
        parser.load_from_data((string) message.response_body.flatten().data);
        var root_object = parser.get_root().get_object();
        //var last_scan = (uint) root_object.get_int_member("last_scan");
        //var last_refresh = (uint) root_object.get_int_member("last_refresh");

        var nodes = root_object.get_array_member("nodes");
        foreach (var node in nodes.get_elements()) {
          var json_node = Json.gobject_deserialize(typeof(JsonDhtNode), node) as JsonDhtNode;
          if (json_node.ipv4 != "-") {
            var dht_node = new DhtNode.with_params(json_node.public_key, json_node.ipv4, json_node.port, false, json_node.maintainer, json_node.location);
            dht_nodes.add(dht_node);
          }
          if (json_node.ipv6 != "-") {
            var dht_node = new DhtNode.with_params(json_node.public_key, json_node.ipv6, json_node.port, false, json_node.maintainer, json_node.location);
            dht_nodes.add(dht_node);
          }
          //FIXME allow multiple addresses per pubkey in node database
          // if (json_node.ipv6 != "-") {
          //   dht_nodes.append(factory.createDhtNode(json_node.public_key, json_node.ipv6, json_node.port, false, json_node.maintainer, json_node.location));
          // }

        }
      } catch (Error e) {
        logger.e("Failed to load dht nodes from uri: " + e.message);
      }
      return dht_nodes;
    }

  }
}
