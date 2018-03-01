/*
 *    FileTransferWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/file_transfer_widget.ui")]
  public class FileTransferWidget : Gtk.Box {
    private ILogger logger;
    private FileTransfers transfers;

    [GtkChild]
    private Gtk.ListBox file_transfers;

    public FileTransferWidget(ILogger logger, FileTransfers transfers) {
      logger.d("FileTransferWidget created.");
      this.logger = logger;
      this.transfers = transfers;

      file_transfers.bind_model(new FileTransferModel(transfers), create_entry);
      unmap.connect(() => { file_transfers.bind_model(null, null); } );
    }

    private Gtk.Widget create_entry(GLib.Object object) {
      return new FileTransferEntry(logger, object as FileTransfer);
    }

    ~FileTransferWidget() {
      logger.d("FileTransferWidget destroyed.");
    }
  }

  public class FileTransferModel : GLib.Object, GLib.ListModel {
    private unowned FileTransfers transfers;
    public FileTransferModel(FileTransfers transfers) {
      this.transfers = transfers;
      transfers.added.connect(on_added);
      transfers.removed.connect(on_removed);
    }

    private void on_added(FileTransfer f, uint position) {
      items_changed(position, 0, 1);
    }

    private void on_removed(FileTransfer f, uint position) {
      items_changed(position, 1, 0);
    }

    public virtual GLib.Object ? get_item(uint position) {
      return transfers.get_item(position);
    }

    public virtual GLib.Type get_item_type() {
      return typeof (FileTransfer);
    }

    public virtual uint get_n_items() {
      return transfers.get_size();
    }

    public virtual GLib.Object ? get_object(uint position) {
      return get_item(position);
    }

  }
}
