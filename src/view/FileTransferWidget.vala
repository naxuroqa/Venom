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
    private ObservableList transfers;
    private FileTransferEntryListener listener;

    [GtkChild]
    private Gtk.ListBox file_transfers;

    public FileTransferWidget(ILogger logger, ObservableList transfers, FileTransferEntryListener listener) {
      logger.d("FileTransferWidget created.");
      this.logger = logger;
      this.transfers = transfers;
      this.listener = listener;

      file_transfers.bind_model(new ObservableListModel(transfers), create_entry);
      unmap.connect(() => { file_transfers.bind_model(null, null); } );
    }

    private Gtk.Widget create_entry(GLib.Object object) {
      return new FileTransferEntry(logger, object as FileTransfer, listener);
    }

    ~FileTransferWidget() {
      logger.d("FileTransferWidget destroyed.");
    }
  }
}
