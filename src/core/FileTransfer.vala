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
    REJECTED,
    IN_PROGRESS,
    PAUSED,
    DONE
  }
  public class FileTransfer : GLib.Object {
    //public int friendnumber { get; set; }
    public Contact friend {get; set; }
    public FileTransferStatus status { get; set;}
    //public uint8 filenumber { get; set; }
    public uint8 send_receive { get; set; }
    public uint64 file_size { get; set; }
    public uint64 bytes_sent { get; set; }
    public string name { get; set; }
    public string path { get; set; }
    public DateTime time_sent { get; set; }
    public FileTransfer(Contact friend, FileTransferDirection send_receive, uint64 file_size, string name, string? path) {
      this.friend = friend;
      this.send_receive = send_receive;
      this.file_size = file_size;
      //this.filenumber = filenumber;
      this.name = name;
      this.path = path;
      time_sent = new DateTime.now_local();
      this.status = FileTransferStatus.PENDING;
      this.bytes_sent = 0;
    }
  }
}
