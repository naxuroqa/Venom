/*
 *    MockDhtNodeRepository.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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
using Mock;
using Testing;
namespace Mock {
  public class MockDhtNodeRepository : DhtNodeRepository, GLib.Object {
    public void create(DhtNode node) {
      mock().actual_call(this, "create", args().object(node).create());
    }
    public void read(DhtNode node) {
      mock().actual_call(this, "read", args().object(node).create());
    }
    public void update(DhtNode node) {
      mock().actual_call(this, "update", args().object(node).create());
    }
    public void delete (DhtNode node) {
      mock().actual_call(this, "delete", args().object(node).create());
    }
    public Gee.Iterable<DhtNode> query_all() {
      return (mock().actual_call(this, "query_all").get_object() ?? Gee.Collection.empty<DhtNode>()) as Gee.Collection<DhtNode>;
    }
  }
}
