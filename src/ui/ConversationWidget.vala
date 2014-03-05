/*
 *    ConversationWidget.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
  public class ConversationWidget : Gtk.EventBox {
    private static string empty_message = "Type your message here...";
    private bool textview_message_empty = true;
    private Gtk.Label label_contact_name;
    private Gtk.Label label_contact_statusmessage;
    private Gtk.Image image_contact_image;

    private Gtk.TextTag empty_message_tag;

    private IConversationView conversation_view;
    public unowned Contact contact {get; private set;}

    public signal void new_outgoing_message(Message message);
    public signal void new_outgoing_action(ActionMessage action);
    public signal void new_outgoing_file(FileTransfer ft);
    public signal void filetransfer_accepted(FileTransfer ft);
    public signal void filetransfer_rejected(FileTransfer ft);


    public ConversationWidget( Contact contact ) {
      this.contact = contact;
      init_widgets();
      setup_drag_drop();
      update_contact();
    }

    public void update_contact() {
      // update contact name
      if(contact.name == null || contact.name == "") {
        label_contact_name.set_text(Tools.bin_to_hexstring(contact.public_key));
      } else {
        label_contact_name.set_text(contact.name);
      }

      // update contact status message
      label_contact_statusmessage.set_text(contact.status_message);

      // update contact image
      image_contact_image.set_from_pixbuf(contact.image != null ? contact.image : ResourceFactory.instance.default_contact);
    }

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/conversation_window.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading conversation window failed!\n");
      }
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.add(box);
      this.get_style_context().add_class("conversation_widget");
      label_contact_name = builder.get_object("label_contact_name") as Gtk.Label;
      label_contact_statusmessage = builder.get_object("label_contact_statusmessage") as Gtk.Label;
      image_contact_image = builder.get_object("image_contact_image") as Gtk.Image;

      Gtk.Image image_call = builder.get_object("image_call") as Gtk.Image;
      Gtk.Image image_call_video = builder.get_object("image_call_video") as Gtk.Image;
      Gtk.Image image_send_file = builder.get_object("image_send_file") as Gtk.Image;

      //TODO
      //Gtk.Button button_call = builder.get_object("button_call") as Gtk.Button;
      //Gtk.Button button_call_video = builder.get_object("button_call_video") as Gtk.Button;
      Gtk.Button button_send_file = builder.get_object("button_send_file") as Gtk.Button;

      button_send_file.clicked.connect(button_send_file_clicked);

      Gtk.TextView textview_message = builder.get_object("textview_message") as Gtk.TextView;
      empty_message_tag = textview_message.buffer.create_tag(null, "foreground", "grey");
      append_tagged_text_to_buffer(textview_message.buffer, empty_message, empty_message_tag);

      textview_message.key_press_event.connect((k) => {
        // only catch return if shift or control keys are not pressed
        if(k.keyval == Gdk.Key.Return && (k.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) == 0) {
          textview_activate(textview_message);
          return true;
        }
        return false;
      });

      textview_message.focus_in_event.connect(() => {
        if(textview_message_empty == true) {
          textview_message.buffer.text = "";
        }
        return false;
      });

      textview_message.focus_out_event.connect(() => {
        if(textview_message.buffer.text == "") {
          append_tagged_text_to_buffer(textview_message.buffer, empty_message, empty_message_tag);
          textview_message_empty = true;
        } else {
          textview_message_empty = false;
        }
        return false;
      });

      image_call.set_from_pixbuf(ResourceFactory.instance.call);
      image_call_video.set_from_pixbuf(ResourceFactory.instance.call_video);
      image_send_file.set_from_pixbuf(ResourceFactory.instance.send_file);

      Gtk.ScrolledWindow scrolled_window = builder.get_object("scrolled_window") as Gtk.ScrolledWindow;

      if( ResourceFactory.instance.textview_mode ) {
        conversation_view = new ConversationTextView();
        scrolled_window.add(conversation_view);
      } else {
        conversation_view = new ConversationView();
        scrolled_window.add_with_viewport(conversation_view);
      }
      conversation_view.get_style_context().add_class("chat_list");
      conversation_view.short_names = true;

      Gtk.Overlay overlay = builder.get_object("overlay") as Gtk.Overlay;
      Gtk.Entry entry_search = new SearchEntry();
      entry_search.halign = Gtk.Align.END;
      entry_search.valign = Gtk.Align.START;
      entry_search.no_show_all = true;
      conversation_view.register_search_entry(entry_search);
      overlay.add_overlay(entry_search);

      Gtk.Adjustment vadjustment = scrolled_window.get_vadjustment();
      bool scroll_to_bottom = true;
      conversation_view.size_allocate.connect( () => {
        if(scroll_to_bottom) {
          vadjustment.value = vadjustment.upper - vadjustment.page_size;
        }
      });
      vadjustment.value_changed.connect( () => {
        scroll_to_bottom = (vadjustment.value == vadjustment.upper - vadjustment.page_size);
      });

      delete_event.connect(hide_on_delete);
    }

    private void add_filetransfer(FileTransfer ft) {
      FileTransferChatEntry entry = new FileTransferChatEntry(ft);
      entry.filetransfer_accepted.connect((ft) => { filetransfer_accepted(ft); });
      entry.filetransfer_rejected.connect((ft) => { filetransfer_rejected(ft); });
      conversation_view.add_filetransfer(entry);
    }

    private void append_tagged_text_to_buffer(Gtk.TextBuffer buffer, string text, Gtk.TextTag tag) {
      Gtk.TextIter text_end;
      buffer.get_end_iter(out text_end);
      buffer.insert_with_tags(text_end, text, text.length, tag);
    }

    //history

    public void load_history(GLib.List<Message> messages) {
      messages.foreach((message) => {
          conversation_view.add_message(message);
        });
    }

    //drag-and-drop

    private void setup_drag_drop() {
      const Gtk.TargetEntry[] targets = {
        {"text/uri-list",0,0}
      };
      Gtk.drag_dest_set(this,Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
      this.drag_data_received.connect(this.on_drag_data_received);
    }


    public void on_incoming_message(Message message) {
      if(message.from != contact)
        return;
      conversation_view.add_message(message);
    }

    public void on_incoming_filetransfer(FileTransfer ft) {
      add_filetransfer(ft);
    }

    public void textview_activate(Gtk.TextView source) {
      string s = source.buffer.text;
      if(s == "")
        return;

      GLib.MatchInfo info = null;
      if(Tools.action_regex.match(s, 0, out info) && info.fetch_named("action_name") == "me") {
        string action_string = info.fetch_named("action_string");
        if(action_string == null) {
          action_string = "";
        }
        ActionMessage a = new ActionMessage.outgoing(contact, action_string);
        conversation_view.add_message(a);
        new_outgoing_action(a);
      } else {
        Message m = new Message.outgoing(User.instance.user, contact, s);
        conversation_view.add_message(m);
        new_outgoing_message(m);
      }
      source.buffer.text = "";
    }

    //GUI events
    public void button_send_file_clicked(Gtk.Button source){
      Gtk.FileChooserDialog file_selection_dialog = new Gtk.FileChooserDialog("Select a file to send",null,
                                                                              Gtk.FileChooserAction.OPEN,
                                                                              "Cancel", Gtk.ResponseType.CANCEL,
                                                                              "Select", Gtk.ResponseType.ACCEPT);
      int response = file_selection_dialog.run();
      if(response != Gtk.ResponseType.ACCEPT){
        file_selection_dialog.destroy();
        return;
      }
      File file = file_selection_dialog.get_file();
      file_selection_dialog.destroy();
      prepare_send_file(file);
    }

    private void on_drag_data_received(Gtk.Widget sender, Gdk.DragContext drag_context, int x, int y, Gtk.SelectionData data, uint info, uint time) {
      string[] uris = data.get_uris();

      foreach (string uri in uris) {
        File file = File.new_for_uri(uri);
        prepare_send_file(file);
      }
      Gtk.drag_finish (drag_context, true, false, time);
    }

    private void prepare_send_file(File file) {
      uint64 file_size;
      try {
        file_size = file.query_info ("*", FileQueryInfoFlags.NONE).get_size ();
      } catch (Error e) {
        stderr.printf("Error occured while getting file size: %s",e.message);
        return;
      }
      FileTransfer ft = new FileTransfer(contact, FileTransferDirection.OUTGOING, file_size, file.get_basename(), file.get_path() );
      new_outgoing_file(ft);
      add_filetransfer(ft);
    }
  }
}
