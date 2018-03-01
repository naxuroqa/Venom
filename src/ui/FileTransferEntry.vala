/*
 *    FileTransferEntry.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/file_transfer_entry.ui")]
  public class FileTransferEntry : Gtk.ListBoxRow {
    private ILogger logger;
    private FileTransfer file_transfer;

    [GtkChild] private Gtk.Label description;
    [GtkChild] private Gtk.ProgressBar progress;
    [GtkChild] private Gtk.Button open_file;
    [GtkChild] private Gtk.Button resume_transfer;
    [GtkChild] private Gtk.Button pause_transfer;
    [GtkChild] private Gtk.Button delete_transfer;

    public FileTransferEntry(ILogger logger, FileTransfer file_transfer) {
      logger.d("FileTransferEntry created.");
      this.logger = logger;
      this.file_transfer = file_transfer;
      description.label = file_transfer.get_description();

      update_progress();
      file_transfer.progress_changed.connect(update_progress);
    }

    private void update_progress() {
      logger.d("update_progress");
      progress.fraction = file_transfer.get_transmitted_size() / ((double) file_transfer.get_file_size());
    }

    public FileTransfer get_file_transfer() {
      return file_transfer;
    }

    ~FileTransferEntry() {
      logger.d("FileTransferEntry destroyed.");
    }
  }
}
