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
  public class ToxAdapterFiletransferListenerImpl : ToxAdapterFiletransferListener, FileTransferEntryListener, ConversationWidgetFiletransferListener, GLib.Object {
    private const int MAX_AVATAR_SIZE = 64 * 1024;

    private unowned ToxSession session;
    private ILogger logger;
    private NotificationListener notification_listener;

    private unowned GLib.HashTable<uint32, IContact> friends;
    private Gee.Map<uint32, Gee.Map<uint32, FileTransfer> > file_transfers;
    private unowned GLib.HashTable<IContact, ObservableList> conversations;

    private ObservableList transfers;

    public ToxAdapterFiletransferListenerImpl(ILogger logger, ObservableList transfers, GLib.HashTable<IContact, ObservableList> conversations, NotificationListener notification_listener) {
      logger.d("ToxAdapterFiletransferListenerImpl created.");
      this.logger = logger;
      this.transfers = transfers;
      this.conversations = conversations;
      this.notification_listener = notification_listener;

      file_transfers = new Gee.HashMap<uint32, Gee.Map<uint32, FileTransfer> >();
    }

    ~ToxAdapterFiletransferListenerImpl() {
      logger.d("ToxAdapterFiletransferListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_filetransfer_listener(this);
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
      unset_file_transfer(transfer.get_friend_number(), transfer.get_file_number());
    }

    public virtual void pause_transfer(FileTransfer transfer) throws Error {
      logger.d("pause_transfer");
      session.file_control(transfer.get_friend_number(), transfer.get_file_number(), ToxCore.FileControl.PAUSE);
      transfer.set_state(FileTransferState.PAUSED);
    }

    public virtual void remove_transfer(FileTransfer transfer) throws Error {
      var friend_number = transfer.get_friend_number();
      var file_number = transfer.get_file_number();
      var state = transfer.get_state();
      logger.d(@"remove_transfer $friend_number:$file_number/%s".printf(state.to_string()));
      try {
        if (state != FileTransferState.CANCEL && state != FileTransferState.FINISHED) {
          session.file_control(friend_number, file_number, ToxCore.FileControl.CANCEL);
        }
      } finally {
        unset_file_transfer(friend_number, file_number);
        transfers.remove(transfer);
        conversations.get(friends.get(friend_number)).remove(transfer);
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
      session.file_send_data(c.tox_friend_number, file);
    }

    public virtual void on_file_chunk_request(uint32 friend_number, uint32 file_number, uint64 position, uint64 length) {
      logger.d("on_file_chunk_request");
      var file_transfer = get_file_transfer(friend_number, file_number);
      if (file_transfer == null) {
        logger.e("Received file chunk request, but filetransfer does not exist.");
        return;
      }
      var state = file_transfer.get_state();
      if (state != FileTransferState.RUNNING && state != FileTransferState.PAUSED) {
        logger.e("Received file chunk request, but filetransfer is not running/paused.");
        return;
      }
      if (length <= 0) {
        file_transfer.set_state(FileTransferState.FINISHED);
        unset_file_transfer(friend_number, file_number);
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

    public virtual void on_file_send_avatar_received(uint32 friend_number, uint32 file_number, uint8[] avatar_data) {
      logger.d("on_file_send_avatar_received");
      var transfer = new FileTransferImpl.AvatarOutgoing(FileTransferDirection.OUTGOING, friend_number, file_number, avatar_data);
      set_file_transfer(friend_number, file_number, transfer);
    }

    public virtual void on_file_send_data_received(uint32 friend_number, uint32 file_number, uint64 file_size, string file_name, GLib.File file) {
      logger.d("on_file_send_data_received");
      try {
        var transfer = new FileTransferImpl.File(FileTransferDirection.OUTGOING, friend_number, file_number, file_size, file_name);
        transfer.init_file(file);

        set_file_transfer(friend_number, file_number, transfer);
        transfers.append(transfer);
        conversations.get(friends.get(friend_number)).append(transfer);
      } catch (Error e) {
        logger.e("file_control failed: " + e.message);
      }
    }

    public virtual void on_file_recv_control(uint32 friend_number, uint32 file_number, ToxCore.FileControl control) {
      logger.d("on_file_recv_control");
      var file_transfer = get_file_transfer(friend_number, file_number);
      if (file_transfer == null) {
        logger.e("Received file control packet, but filetransfer does not exist");
        return;
      }
      var state = file_transfer.get_state();
      if (state != FileTransferState.INIT && state != FileTransferState.RUNNING && state != FileTransferState.PAUSED) {
        logger.e("Received file control packet, but filetransfer is not paused/running");
        return;
      }
      switch (control) {
        case ToxCore.FileControl.CANCEL:
          file_transfer.set_state(FileTransferState.CANCEL);
          unset_file_transfer(friend_number, file_number);
          break;
        case ToxCore.FileControl.PAUSE:
          file_transfer.set_state(FileTransferState.PAUSED);
          break;
        case ToxCore.FileControl.RESUME:
          file_transfer.set_state(FileTransferState.RUNNING);
          break;
      }
    }

    private string create_auto_path(string auto_location) {
      if (auto_location != "" && GLib.File.new_for_path(auto_location).query_exists()) {
        return auto_location;
      }
      return R.constants.downloads_dir;
    }

    private GLib.File create_auto_file(string path, string filename) throws Error {
      if (filename.length < 1 || filename == ".") {
        filename = "file";
      }
      var index = filename.index_of(".", 1);
      var start = filename.substring(0, index);
      var end = index > 0 ? filename.substring(index) : "";

      for (var i = 0;; i++) {
        var name = GLib.Path.build_filename(path, start + (i == 0 ? "" : @"_$i") + end);
        var file = File.new_for_path(name);
        if (!file.query_exists()) {
          return file;
        }
      }
    }

    public virtual void on_file_recv_data(uint32 friend_number, uint32 file_number, uint64 file_size, string filename) {
      logger.d("on_file_recv_data");

      var contact = friends.@get(friend_number) as Contact;
      try {
        var transfer = new FileTransferImpl.File(FileTransferDirection.INCOMING, friend_number, file_number, file_size, filename);
        set_file_transfer(friend_number, file_number, transfer);
        transfers.append(transfer);
        conversations.get(friends.get(friend_number)).append(transfer);
        contact.unread_messages++;
        contact.changed();
        notification_listener.on_filetransfer(transfer, contact);

        if (contact.auto_filetransfer) {
          var path = create_auto_path(contact.auto_location);
          transfer.init_file(create_auto_file(path, filename));
          start_transfer(transfer);
        }

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
      try {
        session.file_control(friend_number, file_number, ToxCore.FileControl.RESUME);
        var transfer = new FileTransferImpl.Avatar(FileTransferDirection.INCOMING, friend_number, file_number, file_size);
        transfer.set_state(FileTransferState.RUNNING);
        set_file_transfer(friend_number, file_number, transfer);
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

    private void unset_file_transfer(uint32 friend_number, uint32 file_number) {
      var friend_transfers = file_transfers.@get(friend_number);
      if (friend_transfers != null) {
        friend_transfers.unset(file_number);
      }
    }

    private Gee.Map<uint32, FileTransfer> init_friend_transfers(uint32 friend_number) {
      var friend_transfers = file_transfers.@get(friend_number);
      if (friend_transfers == null) {
        friend_transfers = new Gee.HashMap<uint32, FileTransfer>();
        file_transfers.@set(friend_number, friend_transfers);
      }
      return friend_transfers;
    }

    private void cancel_transfer(uint32 friend_number, uint32 file_number) {
      try {
        session.file_control(friend_number, file_number, ToxCore.FileControl.CANCEL);
      } catch (Error e) {
        logger.e("Could not cancel transfer: " + e.message);
      }
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
        try {
          transfer.write_data(data);
        } catch (Error e) {
          logger.e("Error writing data to disk: " + e.message);
          transfer.set_state(FileTransferState.FAILED);
          cancel_transfer(friend_number, file_number);
        }
      } else {
        transfer.set_state(FileTransferState.FINISHED);
        unset_file_transfer(transfer.get_friend_number(), transfer.get_file_number());
        if (!transfer.is_avatar()) {
          return;
        }

        var contact = friends.@get(friend_number) as Contact;
        try {
          var buf = transfer.get_avatar_buffer();
          var directory = GLib.File.new_for_path(R.constants.avatars_folder());
          if (!directory.query_exists()) {
            directory.make_directory();
          }

          var id = contact.get_id();
          var filepath = GLib.Path.build_filename(R.constants.avatars_folder(), @"$id.png");
          var file = GLib.File.new_for_path(filepath);
          if (buf == null) {
            logger.d("Empty avatar received.");
            if (file.query_exists()) {
              file.@delete();
            }
            contact.tox_image = null;
            contact.changed();
          } else {
            file.replace_contents(buf, null, false, FileCreateFlags.NONE, null);
            var pixbuf_loader = new Gdk.PixbufLoader();
            pixbuf_loader.write(buf);
            pixbuf_loader.close();
            contact.tox_image = pixbuf_loader.get_pixbuf();
            contact.changed();
          }
        } catch (Error e) {
          logger.e("set image failed: " + e.message);
        }
      }
    }
  }
}
