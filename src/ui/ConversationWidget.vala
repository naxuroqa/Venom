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
    private Gtk.Label label_contact_name;
    private Gtk.Label label_contact_statusmessage;
    private Gtk.Image image_contact_image;

    private Gtk.ListBox conversation_list;
    private Contact last_sender;
    private string self_name;

    public unowned Contact contact {get; private set;}

    public signal void new_outgoing_message(Message message);
    public signal void new_outgoing_action(ActionMessage action);
    public signal void new_outgoing_file(FileTransfer ft);
    public signal void filetransfer_accepted(FileTransfer ft);
    public signal void filetransfer_rejected(FileTransfer ft);

    public ConversationWidget(Contact contact, string self_name) {
      this.self_name = self_name;
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

      Gtk.Entry entry_message = builder.get_object("entry_message") as Gtk.Entry;
      entry_message.activate.connect(entry_activate);

      image_call.set_from_pixbuf(ResourceFactory.instance.call);
      image_call_video.set_from_pixbuf(ResourceFactory.instance.call_video);
      image_send_file.set_from_pixbuf(ResourceFactory.instance.send_file);

      conversation_list = new Gtk.ListBox();
      conversation_list.set_size_request(300,400);
      conversation_list.get_style_context().add_class("chat_list");
      conversation_list.selection_mode = Gtk.SelectionMode.MULTIPLE;
      Gtk.Viewport viewport = new Gtk.Viewport(null,null);
      viewport.add(conversation_list);
      viewport.set_size_request(300,400);
      Gtk.ScrolledWindow scrolled_window = builder.get_object("scrolled_window") as Gtk.ScrolledWindow;
      scrolled_window.add(viewport);

      //TODO: move to bottom only when wanted
      conversation_list.size_allocate.connect( () => {
        Gtk.Adjustment adjustment = scrolled_window.get_vadjustment();
        adjustment.set_value(adjustment.upper - adjustment.page_size);
      });

      delete_event.connect(hide_on_delete);
    }

    private void display_message(Message message) {
      bool following = false;
      if(conversation_list.get_children().length() > 0) {
        if( (message.from == null) && ( last_sender == null )) {
          following = true;
        } else if ( (message.from != null ) && ( last_sender != null ) ) {
          following = message.from.friend_id == last_sender.friend_id;
        }
      }
      ChatMessage cm;
      if(message.from == null) {
        cm = new ChatMessage.own(message,self_name,following);
      } else {
        cm = new ChatMessage.private(message,following);        
      }

      conversation_list.add(cm);
      last_sender = message.from;
    }

    private void display_filetransfer(FileTransfer ft) {
      FileTransferChatEntry entry = new FileTransferChatEntry(ft);
      entry.filetransfer_accepted.connect((ft) => { filetransfer_accepted(ft); });
      entry.filetransfer_rejected.connect((ft) => { filetransfer_rejected(ft); });
      conversation_list.add(entry);
      entry.set_visible(true);
    }

    //history

    public void load_history(GLib.List<Message> messages) {
      messages.foreach((message) => {
          display_message(message);
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
      display_message(message);
    }

    public void on_incoming_filetransfer(FileTransfer ft) {
      display_filetransfer(ft);
    }

    public void entry_activate(Gtk.Entry source) {
      string s = source.text;
      if(s == "")
        return;

      GLib.MatchInfo info = null;
      if(Tools.action_regex.match(s, 0, out info) && info.fetch_named("action_name") == "me") {
        string action_string = info.fetch_named("action_string");
        if(action_string == null) {
          action_string = "";
        }
        ActionMessage a = new ActionMessage.outgoing(contact, action_string);
        display_message(a);
        new_outgoing_action(a);
      } else {
        Message m = new Message.outgoing(contact, s);
        display_message(m);
        new_outgoing_message(m);
      }
      source.text = "";
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
      display_filetransfer(ft);
    }
  }
}
