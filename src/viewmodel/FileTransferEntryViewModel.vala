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
    private unowned FileTransfer file_transfer;
    private unowned FileTransferEntryListener listener;

    public string description { get; set; }
    public double progress { get; set; }
    public bool open_visible { get; set; }
    public bool resume_visible { get; set; }
    public bool pause_visible { get; set; }
    public bool stop_visible { get; set; }

    public signal void open_file(string filename);

    public FileTransferEntryViewModel(ILogger logger, FileTransfer file_transfer, FileTransferEntryListener listener) {
      logger.d("FileTransferEntryViewModel created.");
      this.logger = logger;
      this.file_transfer = file_transfer;
      this.listener = listener;

      description = file_transfer.get_description();

      update_progress();
      update_state();
      file_transfer.progress_changed.connect(update_progress);
      file_transfer.state_changed.connect(update_state);
    }

    public void on_open_clicked() {
      var path = file_transfer.get_file_path();
      if (path != null) {
        open_file(path);
      }
    }

    public void on_resume_transfer() {
      listener.start_transfer(file_transfer);
    }

    public void on_pause_transfer() {
      listener.pause_transfer(file_transfer);
    }

    public void on_stop_transfer() {
      listener.stop_transfer(file_transfer);
    }

    public void on_remove_transfer() {
      listener.remove_transfer(file_transfer);
    }

    private void update_progress() {
      logger.d("update_progress");
      progress = file_transfer.get_transmitted_size() / ((double) file_transfer.get_file_size());
    }

    private void update_state() {
      logger.d("update_state");
      switch (file_transfer.get_state()) {
        case FileTransferState.FINISHED:
          open_visible = true;
          resume_visible = false;
          pause_visible = false;
          stop_visible = false;
          break;
        case FileTransferState.CANCEL:
          open_visible = false;
          resume_visible = false;
          pause_visible = false;
          stop_visible = false;
          break;
        case FileTransferState.INIT:
          open_visible = false;
          resume_visible = true;
          pause_visible = false;
          stop_visible = false;
          break;
        case FileTransferState.RUNNING:
          open_visible = false;
          resume_visible = false;
          pause_visible = true;
          stop_visible = true;
          break;
        case FileTransferState.PAUSED:
          open_visible = false;
          resume_visible = true;
          pause_visible = false;
          stop_visible = true;
          break;
      }
    }

    ~FileTransferEntryViewModel() {
      logger.d("FileTransferEntryViewModel destroyed.");
    }
  }
}
