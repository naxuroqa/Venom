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

    private ObservableList<FileTransfer> transfers;

    public ToxAdapterFiletransferListenerImpl(ILogger logger, ObservableList<FileTransfer> transfers, NotificationListener notification_listener) {
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
        transfers.append(transfer);

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
        transfers.append(transfer);

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
}
