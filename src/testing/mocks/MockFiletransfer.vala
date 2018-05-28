/*
 *    MockFiletransfer.vala
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

namespace Mock {
  public class MockFiletransfer : FileTransfer, GLib.Object {
    public bool is_avatar() {
      return mock().actual_call(this, "is_avatar").get_bool();
    }
    public string get_description() {
      return mock().actual_call(this, "get_description").get_string();
    }
    public uint64 get_transmitted_size() {
      return mock().actual_call(this, "get_transmitted_size").get_int();
    }
    public uint64 get_file_size() {
      return mock().actual_call(this, "get_file_size").get_int();
    }
    public unowned uint8[] ? get_avatar_buffer()  {
      mock().actual_call(this, "get_avatar_buffer");
      return null;
    }
    public void write_data(uint8[] data) throws Error {
      mock().actual_call(this, "write_data").get_throws();
    }
    public uint8[] read_data(uint64 length) throws Error{
      mock().actual_call(this, "read_data").get_throws();
      return (uint8[]) null;
    }
    public void init_file(File file) throws Error {
      mock().actual_call(this, "init_file").get_throws();
    }
    public FileTransferState get_state() {
      return (FileTransferState) mock().actual_call(this, "get_state").get_int();
    }
    public void set_state(FileTransferState state) {
      var args = Arguments.builder()
                     .int(state)
                     .create();
      mock().actual_call(this, "set_state", args);
    }
    public string? get_file_name() {
      return mock().actual_call(this, "get_file_name").get_string();
    }
    public string? get_file_path() {
      return mock().actual_call(this, "get_file_path").get_string();
    }
    public uint32 get_friend_number() {
      return mock().actual_call(this, "get_friend_number").get_int();
    }
    public uint32 get_file_number() {
      return mock().actual_call(this, "get_file_number").get_int();
    }
    public FileTransferDirection get_direction() {
      return (FileTransferDirection) mock().actual_call(this, "get_direction").get_int();
    }
  }
}
