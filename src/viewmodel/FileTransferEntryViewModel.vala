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
    public signal void open_save_file_dialog(string path, string filename);

    public FileTransferEntryViewModel(ILogger logger, FileTransfer file_transfer, FileTransferEntryListener listener) {
      logger.d("FileTransferEntryViewModel created.");
      this.logger = logger;
      this.file_transfer = file_transfer;
      this.listener = listener;

      update_description();
      update_progress();
      update_state();
      file_transfer.progress_changed.connect(update_progress);
      file_transfer.state_changed.connect(update_state);
    }

    private void update_description() {
      try {
        var contact = listener.get_contact_from_transfer(file_transfer);
        if (file_transfer.is_avatar()) {
          description = "New avatar from %s".printf(contact.get_name_string());
        } else {
          description = file_transfer.get_file_name();
        }
      } catch (Error e) {
        logger.e("Contact lookup failed: " + e.message);
      }
    }

    public void on_open_clicked() {
      string? path = null;
      if (file_transfer.is_avatar()) {
        path = R.constants.avatars_folder();
      } else {
        path = Path.get_dirname(file_transfer.get_file_path());
      }

      if (path != null) {
        open_file(path);
      }
    }

    public void on_save_file_chosen(File file) {
      file_transfer.init_file(file);
      listener.start_transfer(file_transfer);
    }

    public void on_resume_transfer() {
      if (file_transfer.get_direction() == FileTransferDirection.INCOMING
          && file_transfer.get_state() == FileTransferState.INIT) {
        open_save_file_dialog(R.constants.downloads_dir, file_transfer.get_file_name());
      } else {
        listener.start_transfer(file_transfer);
      }
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
      var file_size = file_transfer.get_file_size();
      progress = file_size > 0
                 ? file_transfer.get_transmitted_size() / ((double) file_transfer.get_file_size())
                 : 0;
    }

    private void update_state() {
      logger.d("update_state");
      var outgoing = file_transfer.get_direction() == FileTransferDirection.OUTGOING;
      switch (file_transfer.get_state()) {
        case FileTransferState.FAILED:
          open_visible = false;
          resume_visible = false;
          pause_visible = false;
          stop_visible = false;
          break;
        case FileTransferState.FINISHED:
          open_visible = !outgoing;
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
          resume_visible = !outgoing;
          pause_visible = false;
          stop_visible = outgoing;
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
