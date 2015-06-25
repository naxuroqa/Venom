/*
 *    Copyright (C) 2013 Venom authors and contributors
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
  public class FileTransferChatEntry : Gtk.EventBox {
    public unowned FileTransfer ft;

    private Gtk.Label name_label;
    private Gtk.Label size_or_status_label;
    private Gtk.ProgressBar progress_bar;
    private Gtk.Button save_as_button;
    private Gtk.Button cancel_button;

    public signal void filetransfer_accepted(FileTransfer ft);
    public signal void filetransfer_rejected(FileTransfer ft);
    public signal void filetransfer_completed(FileTransferChatEntry entry, FileTransfer ft);

    public FileTransferChatEntry(FileTransfer ft){
      this.ft = ft;
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/chat_filetransfer.ui");
      } catch (GLib.Error e) {
        Logger.log(LogLevel.FATAL, "Loading message widget failed: " + e.message);
      }
      this.get_style_context().add_class("filetransfer_entry");
      //Gtk.Box box = builder.get_object("box1") as Gtk.Box;
      Gtk.Frame frame = builder.get_object("frame1") as Gtk.Frame;
      this.add(frame);
      frame.get_style_context().add_class("frame");

      name_label = builder.get_object("name_label") as Gtk.Label;
      size_or_status_label = builder.get_object("size_label") as Gtk.Label;
      progress_bar = builder.get_object("progress_bar") as Gtk.ProgressBar;
      progress_bar.can_focus = false;
      save_as_button = builder.get_object("save_as_button") as Gtk.Button;
      cancel_button = builder.get_object("cancel_button") as Gtk.Button;
      if( ft.direction == FileTransferDirection.OUTGOING ) {
        save_as_button.visible = false;
      }

      name_label.set_text( ft.name );
      size_or_status_label.set_text( UITools.format_filesize( ft.file_size ) );

      save_as_button.clicked.connect(accept_file);
      cancel_button.clicked.connect(reject_file);

      //filetransfer signals
      ft.progress_update.connect(update_progress);
      ft.status_changed.connect(status_changed);

      this.no_show_all = true;
    }

    private void update_progress(uint64 bytes_processed, uint64 file_size) {
      double progress = (double) bytes_processed / file_size;
      Idle.add( () => { progress_bar.set_fraction(progress); return false; } );
    }

    private void disable_buttons(){
      save_as_button.visible = false;
      cancel_button.visible = false;
    }
    
    private void status_changed(FileTransferStatus status,FileTransferDirection direction){
      switch (status) {
        case FileTransferStatus.DONE: {
          if(direction == FileTransferDirection.INCOMING) {
            size_or_status_label.set_text(_("File received"));
          } else if (direction == FileTransferDirection.OUTGOING) {
            size_or_status_label.set_text(_("File sent"));
          }
          progress_bar.visible = false;
          disable_buttons();
          filetransfer_completed(this, ft);
        } break;
        case FileTransferStatus.REJECTED: {
          size_or_status_label.set_text(_("File was rejected"));
          progress_bar.visible = false;
          disable_buttons();
        } break; 
        case FileTransferStatus.IN_PROGRESS: {
          save_as_button.visible = false;
          size_or_status_label.set_text( UITools.format_filesize( ft.file_size ) );
          cancel_button.visible = true;
        } break;
        case FileTransferStatus.PAUSED: {
          size_or_status_label.set_text(_("Paused"));
        } break;
        case FileTransferStatus.SENDING_FAILED: {
          size_or_status_label.set_text(_("Sending failed"));
          size_or_status_label.get_style_context().add_class("error");
          progress_bar.visible = false;
          disable_buttons();
        } break;
        case FileTransferStatus.RECEIVING_FAILED: {
          size_or_status_label.set_text(_("Receiving failed"));
          size_or_status_label.get_style_context().add_class("error");
          progress_bar.visible = false;
          disable_buttons();
        } break;
        case FileTransferStatus.CANCELED: {
          size_or_status_label.set_text(_("Canceled"));
          progress_bar.visible = false;
          disable_buttons();
        } break; 

        case FileTransferStatus.SENDING_BROKEN: {
          size_or_status_label.set_text(_("Disconnected"));
        } break;

        case FileTransferStatus.RECEIVING_BROKEN: {
          size_or_status_label.set_text(_("Disconnected"));
        } break;

        default:
          GLib.assert_not_reached();
      }
    }

    private void reject_file() {
      if(ft.status != FileTransferStatus.PENDING) {
        return;
      }

      if(ft.direction == FileTransferDirection.OUTGOING) {
        ft.status = FileTransferStatus.CANCELED;
      } else {
        ft.status = FileTransferStatus.REJECTED;
      }
      filetransfer_rejected(ft);
    }

    private void accept_file() {
      if(ft.status != FileTransferStatus.PENDING) {
        return;
      }
      
      Gtk.FileChooserDialog file_selection_dialog = new Gtk.FileChooserDialog(_("Save file"), null,
                                                                              Gtk.FileChooserAction.SAVE,
                                                                              _("_Cancel"), Gtk.ResponseType.CANCEL,
                                                                              _("_Save"), Gtk.ResponseType.ACCEPT);
      file_selection_dialog.do_overwrite_confirmation = true;
      file_selection_dialog.set_current_name(ft.name);
      int res = file_selection_dialog.run();
      if(res  == Gtk.ResponseType.ACCEPT) {
        string path = file_selection_dialog.get_filename();
        file_selection_dialog.destroy();
        Logger.log(LogLevel.INFO, "Saving to: " + path);
        File file = File.new_for_path(path);
        if(file.query_exists()){
          try {
            file.replace(null,false,FileCreateFlags.REPLACE_DESTINATION);
          } catch(Error e) {
            Logger.log(LogLevel.ERROR, "Error while trying to create file: " + e.message);
          }            
        }
        filetransfer_accepted(ft);
        ft.status = FileTransferStatus.IN_PROGRESS;
        ft.path = path;
        return;
      }
      file_selection_dialog.destroy();
    }
  }
}
