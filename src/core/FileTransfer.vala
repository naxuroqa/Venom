/*
 *    FileTransfer.vala
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
  public enum FileTransferDirection {
    OUTGOING,
    INCOMING
  }
  public enum FileTransferStatus {
    PENDING,
    SENDING_FAILED,
    RECEIVING_FAILED,
    REJECTED,
    IN_PROGRESS,
    PAUSED,
    DONE
  }

  public class FileTransfer : GLib.Object {
    public signal void status_changed(FileTransferStatus status, FileTransferDirection direction);
    public signal void progress_update(uint64 processed, uint64 filesize);

    public Contact friend {get; set; }
    public uint8 filenumber {get; set; }
    private FileTransferStatus _status;
    public FileTransferStatus status {
      get { return _status; }
      set {
        _status = value;
        status_changed(_status, direction);
      }
    }

    public uint8 send_receive { get; set; }
    public FileTransferDirection direction {get; set;}
    public uint64 file_size { get; set; }
    /* amount of bytes sent or received during transfer */
    public uint64 _bytes_processed;
    public uint64 bytes_processed {
      get { return _bytes_processed; }
      set {
        progress_update(value,file_size);
        _bytes_processed = value;
      }
    }
    public string name { get; set; }
    public string path { get; set; }
    public DateTime time_sent { get; set; }
    public FileTransfer(Contact friend, FileTransferDirection send_receive, uint64 file_size, string name, string? path) {
      this.friend = friend;
      this.direction = send_receive;
      this.send_receive = send_receive;
      this.file_size = file_size;
      this.name = name;
      this.path = path;
      this.time_sent = new DateTime.now_local();
      this.status = FileTransferStatus.PENDING;
      this.bytes_processed = 0;
    }
  }
}
