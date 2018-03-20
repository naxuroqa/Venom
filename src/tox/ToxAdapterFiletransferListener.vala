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
  public class ToxAdapterFiletransferListenerImpl : ToxAdapterFiletransferListener, FileTransferEntryListener, GLib.Object {
    private const int MAX_AVATAR_SIZE = 250 * 1024;

    private unowned ToxSession session;
    private ILogger logger;
    private NotificationListener notification_listener;

    private unowned GLib.HashTable<uint32, IContact> friends;
    private GLib.HashTable<uint32, GLib.HashTable<uint32, FileTransfer> > file_transfers;

    private ObservableList transfers;

    public ToxAdapterFiletransferListenerImpl(ILogger logger, ObservableList transfers, NotificationListener notification_listener) {
      logger.d("ToxAdapterFiletransferListenerImpl created.");
      this.logger = logger;
      this.notification_listener = notification_listener;
      this.transfers = transfers;

      file_transfers = new GLib.HashTable<uint32, GLib.HashTable<uint32, FileTransfer> >(null, null);
    }

    ~ToxAdapterFiletransferListenerImpl() {
      logger.d("ToxAdapterFiletransferListenerImpl destroyed.");
    }

    public void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_file_transfer_listener(this);
      friends = session.get_friends();
    }

    public virtual void start_transfer(FileTransfer transfer) throws Error {
      logger.d("start_transfer");
      session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.RESUME);
      transfer.set_state(FileTransferState.RUNNING);
    }

    public virtual void stop_transfer(FileTransfer transfer) throws Error {
      logger.d("stop_transfer");
      session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.CANCEL);
      transfer.set_state(FileTransferState.CANCEL);
    }

    public virtual void pause_transfer(FileTransfer transfer) throws Error {
      logger.d("pause_transfer");
      session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.PAUSE);
      transfer.set_state(FileTransferState.PAUSED);
    }

    public virtual void remove_transfer(FileTransfer transfer) throws Error {
      logger.d("remove_transfer %u:%u".printf(transfer.get_friend_number(), transfer.get_file_number()));
      var state = transfer.get_state();
      if (state != FileTransferState.CANCEL && state != FileTransferState.FINISHED) {
        session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.CANCEL);
      }
      transfers.remove(transfer);
    }

    public virtual void on_file_recv_control(uint32 friend_number, uint32 file_number, ToxCore.FileControl control) {
      logger.d("on_file_recv_control");
      var file_transfer = get_file_transfer(friend_number, file_number);
      var state = file_transfer.get_state();
      switch (control) {
        case ToxCore.FileControl.CANCEL:
          set_file_transfer(friend_number, file_number, null);
          file_transfer.set_state(FileTransferState.CANCEL);
          break;
        case ToxCore.FileControl.PAUSE:
          //FIXME handle this somehow
          //file_transfer.set_state(FileTransferState.PAUSED);
          break;
        case ToxCore.FileControl.RESUME:
          if (state == FileTransferState.INIT) {
            file_transfer.set_state(FileTransferState.RUNNING);
          }
          break;
      }
    }

    public virtual void on_file_recv_data(uint32 friend_number, uint32 file_number, uint64 file_size, string filename) {
      logger.d("on_file_recv_data");

      var contact = friends.@get(friend_number);
      var name = contact.get_name_string();
      try {
        // session.file_control(friend_number, file_number, ToxCore.FileControl.RESUME);
        // logger.d("file_control resume sent");
        var transfer = new FileTransferImpl.File(logger, friend_number, file_number, file_size, @"New file from \"$name\"");
        set_file_transfer(friend_number, file_number, transfer);
        transfers.append(transfer);

      } catch (Error e) {
        logger.e("file_control failed: " + e.message);
        return;
      }
    }

    public virtual void on_file_recv_avatar(uint32 friend_number, uint32 file_number, uint64 file_size) {
      logger.d(@"on_file_recv_avatar $friend_number:$file_number");
      if (file_size > MAX_AVATAR_SIZE) {
        logger.i("avatar > MAX_AVATAR_SIZE, dropping transfer request");
        try {
          session.file_control(friend_number, file_number, ToxCore.FileControl.CANCEL);
        } catch (Error e) {
          logger.e("dropping transfer request failed: " + e.message);
        }
        return;
      }
      var contact = friends.@get(friend_number);
      var name = contact.get_name_string();

      try {
        session.file_control(friend_number, file_number, ToxCore.FileControl.RESUME);
        var transfer = new FileTransferImpl.Avatar(logger, friend_number, file_number, file_size, @"New avatar from \"$name\"");
        transfer.set_state(FileTransferState.RUNNING);
        set_file_transfer(friend_number, file_number, transfer);
        transfers.append(transfer);
      } catch (Error e) {
        logger.e("file_control failed: " + e.message);
        return;
      }
    }

    private FileTransfer ? get_file_transfer(uint32 friend_number, uint32 file_number) {
      var friend_transfers = file_transfers.@get(friend_number);
      if (friend_transfers == null) {
        logger.e("on_file_recv_chunk no transfer found for contact");
        return null;
      }
      return friend_transfers.@get(file_number);
    }

    private void set_file_transfer(uint32 friend_number, uint32 file_number, FileTransfer? transfer) {
      var friend_transfers = init_friend_transfers(friend_number);
      friend_transfers.@set(file_number, transfer);
    }

    private HashTable<uint32, FileTransfer> init_friend_transfers(uint32 friend_number) {
      var friend_transfers = file_transfers.@get(friend_number);
      if (friend_transfers == null) {
        friend_transfers = new GLib.HashTable<uint32, FileTransfer>(null, null);
        file_transfers.@set(friend_number, friend_transfers);
      }
      return friend_transfers;
    }

    public virtual void on_file_recv_chunk(uint32 friend_number, uint32 file_number, uint64 position, uint8[] data) {
      var friend_transfers = file_transfers.@get(friend_number);
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
        transfer.set_state(FileTransferState.FINISHED);
        if (!transfer.is_avatar()) {
          return;
        }

        var contact = friends.@get(friend_number) as Contact;
        try {
          friend_transfers.remove(file_number);
          unowned uint8[] buf = transfer.get_file_data();
          var file = File.new_for_path(@"avatar-$(friend_number).png");
          file.replace_contents(buf, null, false, FileCreateFlags.NONE, null, null);
          contact.tox_image = new Gdk.Pixbuf.from_file_at_scale(file.get_path(), 44, 44, true);
          contact.changed();
        } catch (Error e) {
          logger.e("set image failed: " + e.message);
        }
      }
    }
  }
}
