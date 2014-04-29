/*
 *    LocalStorage.vala
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

namespace Venom {
  public errordomain SqliteError {
    INDEX,
    BIND
  }
  public class SqliteTools {
    private SqliteTools() {}

    public static void put_int(Sqlite.Statement statement, string name, int value) throws SqliteError {
      int index = statement.bind_parameter_index(name);
      if(index == 0) {
        throw new SqliteError.INDEX(@"Index for \"$(name)\" not found.");
      }
      if(statement.bind_int(index, value) != Sqlite.OK) {
        throw new SqliteError.BIND(@"Could not bind int to \"$(name)\".");
      }
    }

    public static void put_int64(Sqlite.Statement statement, string name, int64 value) throws SqliteError {
      int index = statement.bind_parameter_index(name);
      if(index == 0) {
        throw new SqliteError.INDEX(@"Index for \"$(name)\" not found.");
      }
      if(statement.bind_int64(index, value) != Sqlite.OK) {
        throw new SqliteError.BIND(@"Could not bind int64 to \"$(name)\".");
      }
    }

    public static void put_text(Sqlite.Statement statement, string name, string value) throws SqliteError {
      int index = statement.bind_parameter_index(name);
      if(index == 0) {
        throw new SqliteError.INDEX(@"Index for \"$(name)\" not found.");
      }
      if(statement.bind_text(index, value) != Sqlite.OK) {
        throw new SqliteError.BIND(@"Could not bind text to \"$(name)\".");
      }
    }
  }
}
