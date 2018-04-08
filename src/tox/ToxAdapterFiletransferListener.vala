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
  public interface ConversationWidgetFiletransferListener : GLib.Object {
    public abstract void on_start_filetransfer(IContact contact, File file) throws Error;
  }

  public interface FileTransferEntryListener : GLib.Object {
    public abstract void start_transfer(FileTransfer transfer) throws Error;
    public abstract void stop_transfer(FileTransfer transfer) throws Error;
    public abstract void pause_transfer(FileTransfer transfer) throws Error;
    public abstract void remove_transfer(FileTransfer transfer) throws Error;
    public abstract IContact get_contact_from_transfer(FileTransfer transfer) throws Error;
  }

  public class ToxAdapterFiletransferListenerImpl : ToxAdapterFiletransferListener, FileTransferEntryListener, ConversationWidgetFiletransferListener, GLib.Object {
    private const int MAX_AVATAR_SIZE = 64 * 1024;

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

    public virtual void attach_to_session(ToxSession session) {
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
      set_file_transfer(transfer.get_friend_number(), transfer.get_file_number(), null);
    }

    public virtual void pause_transfer(FileTransfer transfer) throws Error {
      logger.d("pause_transfer");
      session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.PAUSE);
      transfer.set_state(FileTransferState.PAUSED);
    }

    public virtual void remove_transfer(FileTransfer transfer) throws Error {
      logger.d("remove_transfer %u:%u".printf(transfer.get_friend_number(), transfer.get_file_number()));
      var state = transfer.get_state();
      try {
        if (state != FileTransferState.CANCEL && state != FileTransferState.FINISHED) {
          session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.CANCEL);
        }
      } finally {
        transfers.remove(transfer);
        set_file_transfer(transfer.get_friend_number(), transfer.get_file_number(), null);
      }
    }

    public virtual IContact get_contact_from_transfer(FileTransfer transfer) throws Error {
      var contact = friends.@get(transfer.get_friend_number());
      if (contact == null) {
        throw new ToxError.GENERIC("Contact not found");
      }
      return contact;
    }

    public virtual void on_start_filetransfer(IContact contact, File file) throws Error {
      logger.d("on_start_filetransfer");
      var c = contact as Contact;
      session.file_send(c.tox_friend_number, ToxCore.FileKind.DATA, file);
    }

    public virtual void on_file_chunk_request(uint32 friend_number, uint32 file_number, uint64 position, uint64 length) {
      logger.d("on_file_chunk_request");
      var file_transfer = get_file_transfer(friend_number, file_number);
      var state = file_transfer.get_state();
      if (length <= 0) {
        file_transfer.set_state(FileTransferState.FINISHED);
        return;
      }
      try {
        var buf = file_transfer.read_data(length);
        session.file_send_chunk(friend_number, file_number, position, buf);
      } catch (Error e) {
        logger.e("Reading data from file failed: " + e.message);
        file_transfer.set_state(FileTransferState.FAILED);
        return;
      }
    }

    public virtual void on_file_send_received(uint32 friend_number, uint32 file_number, ToxCore.FileKind kind, uint64 file_size, string file_name, GLib.File file) {
      logger.d("on_file_send_received");
      try {
        logger.d("file_control resume sent");
        FileTransfer transfer;
        if (kind == ToxCore.FileKind.AVATAR) {
          transfer = new FileTransferImpl.Avatar(FileTransferDirection.OUTGOING, friend_number, file_number, file_size);
        } else {
          transfer = new FileTransferImpl.File(FileTransferDirection.OUTGOING, friend_number, file_number, file_size, file_name);
        }
        transfer.init_file(file);

        set_file_transfer(friend_number, file_number, transfer);
        transfers.append(transfer);
      } catch (Error e) {
        logger.e("file_control failed: " + e.message);
        return;
      }
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
            if (file_transfer.get_direction() == FileTransferDirection.OUTGOING) {
              try {
                session.file_control(friend_number, file_number, ToxCore.FileControl.RESUME);
              } catch (Error e) {
                logger.e("Error sending file: " + e.message);
                file_transfer.set_state(FileTransferState.FAILED);
                return;
              }
            }
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
        var transfer = new FileTransferImpl.File(FileTransferDirection.INCOMING, friend_number, file_number, file_size, filename);
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
        var transfer = new FileTransferImpl.Avatar(FileTransferDirection.INCOMING, friend_number, file_number, file_size);
        transfer.set_state(FileTransferState.RUNNING);
        set_file_transfer(friend_number, file_number, transfer);
        //transfers.append(transfer);
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
        transfer.write_data(data);
      } else {
        transfer.set_state(FileTransferState.FINISHED);
        set_file_transfer(transfer.get_friend_number(), transfer.get_file_number(), null);
        if (!transfer.is_avatar()) {
          return;
        }

        var contact = friends.@get(friend_number) as Contact;
        try {
          var buf = transfer.get_avatar_buffer();
          var directory = File.new_for_path(R.constants.avatars_folder());
          if (!directory.query_exists()) {
            directory.make_directory();
          }

          var id = contact.get_id();
          var filepath = GLib.Path.build_filename(R.constants.avatars_folder(), @"$id.png");
          var file = File.new_for_path(filepath);
          file.replace_contents(buf, null, false, FileCreateFlags.NONE, null, null);
          var pixbuf_loader = new Gdk.PixbufLoader();
          pixbuf_loader.write(buf);
          pixbuf_loader.close();
          contact.tox_image = pixbuf_loader.get_pixbuf();
          contact.changed();
        } catch (Error e) {
          logger.e("set image failed: " + e.message);
        }
      }
    }
  }
}
