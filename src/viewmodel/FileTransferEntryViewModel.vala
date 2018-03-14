/*
 *    FileTransferEntryViewModel.vala
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
  public class FileTransferEntryViewModel : GLib.Object {
    private ILogger logger;
    private FileTransfer file_transfer;

    public string description { get; set; }
    public double progress { get; set; }
    public bool open_visible { get; set; }
    public bool resume_visible { get; set; }
    public bool pause_visible { get; set; }

    public FileTransferEntryViewModel(ILogger logger, FileTransfer file_transfer) {
      logger.d("FileTransferEntryViewModel created.");
      this.logger = logger;
      this.file_transfer = file_transfer;

      description = file_transfer.get_description();

      update_progress();
      file_transfer.progress_changed.connect(update_progress);
    }

    private void update_progress() {
      logger.d("update_progress");
      progress = file_transfer.get_transmitted_size() / ((double) file_transfer.get_file_size());
    }

    ~FileTransferEntryViewModel() {
      logger.d("FileTransferEntryViewModel destroyed.");
    }
  }
}
