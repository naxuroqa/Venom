/*
 *    FileTransfer.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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
    FINISHED
  }

  public interface FileTransfer : GLib.Object {
    public signal void state_changed();
    public signal void progress_changed();

    public abstract bool is_avatar();
    public abstract string get_description();
    public abstract uint64 get_transmitted_size();
    public abstract uint64 get_file_size();
    public abstract unowned uint8[]? get_file_data();
    public abstract void set_file_data(uint64 offset, uint8[] data);
    public abstract FileTransferState get_state();
    public abstract void set_state(FileTransferState state);
    public abstract string? get_file_path();

    public abstract uint32 get_friend_number();
    public abstract uint32 get_file_number();
  }

  public class FileTransferImpl : FileTransfer, GLib.Object {
    private uint8[] file_data;
    private uint64 transmitted_size;
    private ILogger logger;
    private string description;
    private bool _is_avatar;
    private FileTransferState state;
    private uint32 friend_number;
    private uint32 file_number;

    private FileTransferImpl(ILogger logger, uint32 friend_number, uint32 file_number) {
      this.logger = logger;
      this.friend_number = friend_number;
      this.file_number = file_number;
    }

    public FileTransferImpl.File(ILogger logger, uint32 friend_number, uint32 file_number, uint64 file_size, string filename) {
      this(logger, friend_number, file_number);
      this.description = filename;
      transmitted_size = 0;
      state = FileTransferState.INIT;
      _is_avatar = false;
    }

    public FileTransferImpl.Avatar(ILogger logger, uint32 friend_number, uint32 file_number, uint64 file_size, string description) {
      this(logger, friend_number, file_number);
      this.description = description;
      file_data = new uint8[file_size];
      transmitted_size = 0;
      state = FileTransferState.INIT;
      _is_avatar = true;
    }

    private static void copy_with_offset(uint8[] dest, uint8[] src, uint64 offset) {
      unowned uint8[] dest_ptr = dest[offset : dest.length];
      GLib.Memory.copy(dest_ptr, src, src.length);
    }

    public virtual bool is_avatar() {
      return _is_avatar;
    }

    public virtual string get_description() {
      return description;
    }

    public virtual uint64 get_transmitted_size() {
      return transmitted_size;
    }

    public virtual uint64 get_file_size() {
      return file_data.length;
    }

    public virtual void set_file_data(uint64 offset, uint8[] data) {
      if (!is_avatar()) {
        //FIXME implement this
        transmitted_size += data.length;
        progress_changed();
        return;
      }

      if (data.length + offset > file_data.length) {
        logger.e("set_data overflow");
        return;
      }
      copy_with_offset(file_data, data, offset);
      transmitted_size += data.length;
      progress_changed();
    }

    public virtual string? get_file_path() {
      return ".";
    }

    public virtual unowned uint8[]? get_file_data() {
      return file_data;
    }

    public virtual FileTransferState get_state() {
      return state;
    }

    public virtual void set_state(FileTransferState state) {
      this.state = state;
      state_changed();
    }

    public virtual uint32 get_friend_number() {
      return friend_number;
    }

    public virtual uint32 get_file_number() {
      return file_number;
    }
  }
}
