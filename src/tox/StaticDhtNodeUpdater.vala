/*
 *    StaticDhtNodeUpdater.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  public class StaticDhtNodeUpdater : Object {
    public Gee.Iterable<DhtNode> get_dht_nodes() {
      var nodes = new Gee.LinkedList<DhtNode>();
      nodes.add(new DhtNode.with_params(
                     "461FA3776EF0FA655F1A05477DF1B3B614F7D6B124F7DB1DD4FE3C08B03B640F",
                     "130.133.110.14",
                     33445,
                     false,
                     "manolis",
                     "DE"
                     ));
      nodes.add(new DhtNode.with_params(
                     "F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67",
                     "node.tox.biribiri.org",
                     33445,
                     false,
                     "nurupo",
                     "US"
                     ));

      return nodes;
    }
  }
}
