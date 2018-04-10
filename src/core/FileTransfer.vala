/*
 *    FileTransfer.vala
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

namespace Venom {
  public enum FileTransferState {
    INIT,
    PAUSED,
    RUNNING,
    CANCEL,
    FINISHED,
    FAILED
  }

  public enum FileTransferDirection {
    INCOMING,
    OUTGOING
  }

  public errordomain FileTransferError {
    READ,
    WRITE,
    INIT,
    OVERFLOW
  }

  public interface FileTransfer : GLib.Object {
    public signal void state_changed();
    public signal void progress_changed();

    public abstract FileTransferDirection get_direction();
    public abstract uint32 get_friend_number();
    public abstract uint32 get_file_number();
    public abstract uint64 get_file_size();
    public abstract uint64 get_transmitted_size();
    public abstract FileTransferState get_state();
    public abstract bool is_avatar();
    public abstract unowned uint8[] ? get_avatar_buffer();

    public abstract void init_file(File file) throws Error;

    public abstract void write_data(uint8[] data) throws Error;
    public abstract uint8[] read_data(uint64 length) throws Error;

    public abstract string? get_file_name();
    public abstract string? get_file_path();
    public abstract void set_state(FileTransferState state);
  }

  public class FileTransferImpl : FileTransfer, GLib.Object {
    private FileTransferDirection direction;
    private uint32 friend_number;
    private uint32 file_number;
    private uint64 file_size;
    private uint64 transmitted_size;
    private FileTransferState state;

    private bool _is_avatar;
    private uint8[] avatar_buffer;

    private string file_name;
    private File file;

    private FileTransferImpl(FileTransferDirection direction, uint32 friend_number, uint32 file_number, uint64 file_size) {
      this.friend_number = friend_number;
      this.file_number = file_number;
      this.direction = direction;
      this.file_size = file_size;

      state = FileTransferState.INIT;
      transmitted_size = 0;
    }

    public FileTransferImpl.File(FileTransferDirection direction, uint32 friend_number, uint32 file_number, uint64 file_size, string file_name) {
      this(direction, friend_number, file_number, file_size);
      this.file_name = file_name;
      _is_avatar = false;
    }

    public FileTransferImpl.Avatar(FileTransferDirection direction, uint32 friend_number, uint32 file_number, uint64 file_size) {
      this(direction, friend_number, file_number, file_size);
      avatar_buffer = new uint8[file_size];
      _is_avatar = true;
    }

    public void init_file(File file) throws Error {
      this.file = file;
      if (direction == INCOMING) {
        file.replace(null, false, GLib.FileCreateFlags.NONE);
      }
    }

    private static void copy_with_offset(uint8[] dest, uint8[] src, uint64 offset) {
      unowned uint8[] dest_ptr = dest[offset : dest.length];
      GLib.Memory.copy(dest_ptr, src, src.length);
    }

    public bool is_avatar() {
      return _is_avatar;
    }

    public uint64 get_transmitted_size() {
      return transmitted_size;
    }

    public uint64 get_file_size() {
      return file_size;
    }

    public void write_data(uint8[] data) throws Error {
      if (data.length + transmitted_size > file_size) {
        set_state(FileTransferState.FAILED);
        throw new FileTransferError.OVERFLOW("Appending too much data, discarding data");
      }

      if (_is_avatar) {
        copy_with_offset(avatar_buffer, data, transmitted_size);
      } else {
        if (file == null) {
          set_state(FileTransferState.FAILED);
          throw new FileTransferError.INIT("File is not initialized");
        }
        try {
          file.append_to(GLib.FileCreateFlags.NONE).write(data);
        } catch (Error e) {
          set_state(FileTransferState.FAILED);
          throw new FileTransferError.WRITE("Writing to file failed: " + e.message);
        }
      }

      transmitted_size += data.length;
      progress_changed();
    }

    public uint8[] read_data(uint64 length) throws Error {
      if (length + transmitted_size > file_size) {
        set_state(FileTransferState.FAILED);
        throw new FileTransferError.OVERFLOW("Appending too much data, discarding data");
      }
      if (file == null) {
        set_state(FileTransferState.FAILED);
        throw new FileTransferError.INIT("File is not initialized");
      }
      var buf = new uint8[length];
      try {
        var istream = file.read();
        istream.seek((int64) transmitted_size, SeekType.SET);
        istream.read(buf);
      } catch (Error e) {
        set_state(FileTransferState.FAILED);
        throw new FileTransferError.WRITE("Writing to file failed: " + e.message);
      }

      transmitted_size += length;
      progress_changed();
      return buf;
    }

    public unowned uint8[] ? get_avatar_buffer() {
      return avatar_buffer;
    }

    public FileTransferState get_state() {
      return state;
    }

    public void set_state(FileTransferState state) {
      this.state = state;
      state_changed();
    }

    public uint32 get_friend_number() {
      return friend_number;
    }

    public uint32 get_file_number() {
      return file_number;
    }

    public FileTransferDirection get_direction() {
      return direction;
    }

    public string? get_file_name() {
      return file_name;
    }

    public string? get_file_path() {
      if (file == null) {
        return null;
      }
      return file.get_path();
    }
  }
}
