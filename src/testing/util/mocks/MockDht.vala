/*
 *    DhtMock.vala
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

using Venom;

namespace Mock {
  public class MockDhtNode : IDhtNode, Object {
    public string pub_key    { get; set; }
    public string host       { get; set; }
    public uint   port       { get; set; }
    public bool   is_blocked { get; set; }
    public string maintainer { get; set; }
    public string location   { get; set; }
  }

  public class MockDhtNodeFactory : IDhtNodeFactory, GLib.Object {
    public IDhtNode createDhtNode(string address, string key, uint port, bool blocked, string owner, string location) {
      return (IDhtNode) mock().actual_call(this, "createDhtNode").get_object();
    }
  }
}
