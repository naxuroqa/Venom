/*
 *    ToxAdapterFiletransferListener.vala
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
  public class ToxAdapterFiletransferListenerImpl : ToxAdapterFiletransferListener, GLib.Object {
    private const int MAX_AVATAR_SIZE = 250 * 1024;

    private unowned ToxSession session;
    private ILogger logger;
    private NotificationListener notification_listener;

    private unowned GLib.HashTable<uint32, IContact> friends;
    private GLib.HashTable<IContact, GLib.HashTable<uint32, FileTransfer> > filetransfers;

    private FileTransfers transfers;

    public ToxAdapterFiletransferListenerImpl(ILogger logger, FileTransfers transfers, NotificationListener notification_listener) {
      logger.d("ToxAdapterFiletransferListenerImpl created.");
      this.logger = logger;
      this.notification_listener = notification_listener;
      this.transfers = transfers;

      filetransfers = new GLib.HashTable<IContact, GLib.HashTable<uint32, FileTransfer> >(null, null);
    }

    ~ToxAdapterFiletransferListenerImpl() {
      logger.d("ToxAdapterFiletransferListenerImpl destroyed.");
    }

    public void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_filetransfer_listener(this);
      friends = session.get_friends();
    }

    public virtual void on_file_recv_data(uint32 friend_number, uint32 file_number, uint64 file_size, string filename) {
      logger.d("on_file_recv_data");

      try {
        session.file_control(friend_number, file_number, ToxCore.FileControl.RESUME);
        var contact = friends.@get(friend_number);
        var transfer = new FileTransferImpl.File(logger, file_size, "New file from \"%s\"".printf(contact.get_name_string()));
        set_filetransfer(friend_number, file_number, transfer);
        transfers.add(transfer);

        logger.d("file_control resume sent");
      } catch (Error e) {
        logger.e("file_control failed: " + e.message);
        return;
      }
    }

    public virtual void on_file_recv_avatar(uint32 friend_number, uint32 file_number, uint64 file_size) {
      logger.d("on_file_recv_avatar");
      if (file_size > MAX_AVATAR_SIZE) {
        logger.i("avatar > MAX_AVATAR_SIZE, dropping transfer request");
        drop_file_recv_avatar(friend_number, file_number);
        return;
      }

      try {
        session.file_control(friend_number, file_number, ToxCore.FileControl.RESUME);
        var contact = friends.@get(friend_number);
        var transfer = new FileTransferImpl.Avatar(logger, file_size, "New avatar from \"%s\"".printf(contact.get_name_string()));
        set_filetransfer(friend_number, file_number, transfer);
        transfers.add(transfer);

        logger.d("file_control resume sent");
      } catch (Error e) {
        logger.e("file_control failed: " + e.message);
        return;
      }
    }

    private void drop_file_recv_avatar(uint32 friend_number, uint32 file_number) {
      try {
        session.file_control(friend_number, file_number, ToxCore.FileControl.CANCEL);
      } catch (Error e) {
        logger.e("dropping transfer request failed: " + e.message);
      }
    }

    private void set_filetransfer(uint32 friend_number, uint32 file_number, FileTransfer transfer) {
      var contact = friends.@get(friend_number);
      var friend_transfers = init_friend_transfers(contact);
      friend_transfers.@set(file_number, transfer);
    }

    private HashTable<uint32, FileTransfer> init_friend_transfers(IContact contact) {
      var friend_transfers = filetransfers.@get(contact);
      if (friend_transfers == null) {
        friend_transfers = new GLib.HashTable<uint32, FileTransfer>(null, null);
        filetransfers.@set(contact, friend_transfers);
      }
      return friend_transfers;
    }

    public virtual void on_file_recv_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data) {
      var contact = friends.@get(friend_number);
      var friend_transfers = filetransfers.@get(contact);
      if (friend_transfers == null) {
        logger.e("on_file_recv_chunk no transfer found for contact");
        return;
      }
      var transfer = friend_transfers.@get(file_number);
      if (transfer == null) {
        logger.e("on_file_recv_chunk no transfer found for file number");
        return;
      }
      if (data.length > 0) {
        transfer.set_file_data(position, data);
      } else {
        var c = contact as Contact;
        try {
          friend_transfers.remove(file_number);
          unowned uint8[] buf = transfer.get_file_data();
          var file = File.new_for_path(@"avatar-$(friend_number).png");
          file.replace_contents(buf, null, false, FileCreateFlags.NONE, null, null);
          c.tox_image = new Gdk.Pixbuf.from_file_at_scale(file.get_path(), 44, 44, true);
          c.changed();
        } catch (Error e) {
          logger.e("set image failed: " + e.message);
        }
      }
    }
  }

  public interface FileTransfers : GLib.Object {
    public signal void added(FileTransfer transfer, uint position);
    public signal void removed(FileTransfer transfer, uint position);

    public abstract void add(FileTransfer transfer);
    public abstract void remove(FileTransfer transfer);

    public abstract uint get_size();
    public abstract FileTransfer get_item(uint position);

    public abstract unowned GLib.List<FileTransfer> get_transfers();
  }

  public class FileTransfersImpl : FileTransfers, GLib.Object {
    private GLib.List<FileTransfer> transfers;
    public FileTransfersImpl() {
      transfers = new GLib.List<FileTransfer>();
    }
    public virtual void add(FileTransfer transfer) {
      var position = get_size();
      transfers.append(transfer);
      added(transfer, position);
    }
    public virtual void remove(FileTransfer transfer) {
      var position = index(transfer);
      transfers.remove(transfer);
      removed(transfer, position);
    }
    public virtual uint get_size() {
      return transfers.length();
    }
    public virtual FileTransfer get_item(uint position) {
      return transfers.nth_data(position);
    }
    public virtual uint index(FileTransfer transfer) {
      return transfers.index(transfer);
    }
    public virtual unowned GLib.List<FileTransfer> get_transfers() {
      return transfers;
    }
  }

  public interface FileTransfer : GLib.Object {
    public signal void status_changed();
    public signal void progress_changed();

    public abstract bool is_avatar();
    public abstract string get_description();
    public abstract uint64 get_transmitted_size();
    public abstract uint64 get_file_size();
    public abstract unowned uint8[] get_file_data();
    public abstract void set_file_data(uint64 offset, uint8[] data);
  }

  public class FileTransferImpl : FileTransfer, GLib.Object {
    private uint8[] file_data;
    private uint64 transmitted_size;
    private ILogger logger;
    private string description;
    //private bool _is_avatar;

    public FileTransferImpl.File(ILogger logger, uint64 file_size, string filename) {
      this.logger = logger;
      this.description = filename;
      file_data = new uint8[file_size];
      transmitted_size = 0;
      //_is_avatar = false;
    }

    public FileTransferImpl.Avatar(ILogger logger, uint64 file_size, string description) {
      this.logger = logger;
      this.description = description;
      file_data = new uint8[file_size];
      transmitted_size = 0;
      //_is_avatar = true;
    }

    private static void copy_with_offset(uint8[] dest, uint8[] src, uint64 offset) {
      unowned uint8[] dest_ptr = dest[offset : dest.length];
      GLib.Memory.copy(dest_ptr, src, src.length);
    }

    public virtual bool is_avatar() {
      return false; //_is_avatar;
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
      if (data.length + offset > file_data.length) {
        logger.e("set_data overflow");
        return;
      }
      copy_with_offset(file_data, data, offset);
      transmitted_size += data.length;
      progress_changed();
    }

    public virtual unowned uint8[] get_file_data() {
      return file_data;
    }
  }
}
