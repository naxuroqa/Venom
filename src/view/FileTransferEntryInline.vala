/*
 *    FileTransferEntryInline.vala
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/file_transfer_entry_inline.ui")]
  public class FileTransferEntryInline : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label description;
    [GtkChild] private Gtk.ProgressBar progress;
    [GtkChild] private Gtk.Button open_file;
    [GtkChild] private Gtk.Button resume_transfer;
    [GtkChild] private Gtk.Button pause_transfer;
    [GtkChild] private Gtk.Button stop_transfer;
    [GtkChild] private Gtk.Button remove_transfer;

    private ILogger logger;
    private FileTransferEntryViewModel view_model;
    private FileTransferExternalCommands external_commands;

    public FileTransferEntryInline(ILogger logger, FileTransfer file_transfer, FileTransferEntryListener listener) {
      logger.d("FileTransferEntryInline created.");

      this.logger = logger;
      this.view_model = new FileTransferEntryViewModel(logger, file_transfer, listener);
      this.external_commands = new FileTransferExternalCommands(logger);

      view_model.bind_property("description", description, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("progress", progress, "fraction", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("open-visible", open_file, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("resume-visible", resume_transfer, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("pause-visible", pause_transfer, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("stop-visible", stop_transfer, "sensitive", GLib.BindingFlags.SYNC_CREATE);

      open_file.clicked.connect(view_model.on_open_clicked);
      resume_transfer.clicked.connect(view_model.on_resume_transfer);
      pause_transfer.clicked.connect(view_model.on_pause_transfer);
      stop_transfer.clicked.connect(view_model.on_stop_transfer);
      remove_transfer.clicked.connect(view_model.on_remove_transfer);

      view_model.open_file.connect(external_commands.open_file);
      view_model.open_save_file_dialog.connect(external_commands.open_save_file_dialog);
      external_commands.save_file_chosen.connect(view_model.on_save_file_chosen);
    }

    ~FileTransferEntryInline() {
      logger.d("FileTransferEntryInline destroyed.");
    }
  }
}
