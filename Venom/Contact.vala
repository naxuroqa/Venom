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

namespace Venom {
  public class Contact {
    private uint32[] _public_key;
    private string   _name;
    private string   _local_name;
    private string   _status_message;
    private DateTime _last_seen;

    public Contact(uint32[] public_key, string name) {
      _public_key = public_key;
      _name = name;
      _local_name = name;
      _status_message = "";
      _last_seen = new DateTime.now_local();
    }

    public uint32[] public_key {
      get { return _public_key; }
      set { _public_key = value; }
    }

    public string name {
      get { return _name; }
      set { _name = value; }
    }

    public string local_name {
      get { return _local_name; }
      set { _local_name = value; }
    }

    public string status_message {
      get { return _status_message; }
      set { _status_message = value; }
    }

    public DateTime last_seen {
      get { return _last_seen; }
      set { _last_seen = value; }
    }

    public void resetLocalName() {
      _local_name = _name;
    }

    public string get_public_key_string() {
      return "%08X%08X%08X%08X%08X%08X%08X%08X".printf(
              _public_key[0],
              _public_key[1],
              _public_key[2],
              _public_key[3],
              _public_key[4],
              _public_key[5],
              _public_key[6],
              _public_key[7]);
    }
  }
}
