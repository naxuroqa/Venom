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
    private EditableLabel label_contact_name;
    private Gtk.Label label_contact_statusmessage;
    private Gtk.Image image_contact_image;
    private Gtk.Button button_send;
    private Gtk.Button button_send_file;
    private Gtk.Button button_call;
    private Gtk.Button button_call_video;
    //private Gtk.Box box_volume;    

    private MessageTextView message_textview;
    private IConversationView conversation_view;
    public unowned Contact contact {get; private set;}

    public signal void new_outgoing_message(Message message);
    public signal void new_outgoing_action(ActionMessage action);
    public signal void new_outgoing_file(FileTransfer ft);
    public signal void typing_status(bool typing);
    public signal void filetransfer_accepted(FileTransfer ft);
    public signal void filetransfer_rejected(FileTransfer ft);
    public signal void contact_changed(Contact c);
    public signal void start_audio_call(Contact c);
    public signal void stop_audio_call(Contact c);
    public signal void start_video_call(Contact c);
    public signal void stop_video_call(Contact c);

    public ConversationWidget( Contact contact ) {
      this.contact = contact;
      init_widgets();
      setup_drag_drop();
      update_contact();
    }

    public void update_contact() {
      // update contact name
      label_contact_name.label.label = _("<b>%s</b>").printf(contact.get_name_string_with_hyperlinks());

      // update contact status message
      label_contact_statusmessage.label = contact.get_status_string_with_hyperlinks();

      // update contact image
      image_contact_image.set_from_pixbuf(contact.image != null ? contact.image : ResourceFactory.instance.default_contact);

      if( contact.name != null )
        conversation_view.is_typing_string = _("%s is typing...").printf(Markup.escape_text(contact.name));

      button_send_file.sensitive = contact.online;
      button_send.sensitive = contact.online;
      button_call.sensitive = contact.online;
      button_call_video.sensitive = contact.online;

      // remove is_typing notification for offline contacts
      if(!contact.online){
        on_typing_changed(false);
      }
    }

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/conversation_window.ui");
      } catch (GLib.Error e) {
        Logger.log(LogLevel.FATAL, "Loading conversation window failed: " + e.message);
      }
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.add(box);
      this.get_style_context().add_class("conversation_widget");
      label_contact_statusmessage = builder.get_object("label_contact_statusmessage") as Gtk.Label;
      image_contact_image = builder.get_object("image_contact_image") as Gtk.Image;

      Gtk.Image image_send = builder.get_object("image_send") as Gtk.Image;
      Gtk.Image image_call = builder.get_object("image_call") as Gtk.Image;
      Gtk.Image image_call_video = builder.get_object("image_call_video") as Gtk.Image;

      //box_volume = builder.get_object("box_volume") as Gtk.Box;

      Gtk.Image image_send_file = builder.get_object("image_send_file") as Gtk.Image;
      Gtk.Image image_insert_smiley = builder.get_object("image_insert_smiley") as Gtk.Image;

      Gtk.Label label_contact_name_ = builder.get_object("label_contact_name") as Gtk.Label;
      Gtk.Box box_user_info = builder.get_object("box_user_info") as Gtk.Box;
      box_user_info.remove(label_contact_name_);
      label_contact_name = new EditableLabel.with_label(label_contact_name_);
      box_user_info.pack_start(label_contact_name, false);
      label_contact_name.button_cancel.get_style_context().add_class("sendbutton");
      label_contact_name.button_ok.get_style_context().add_class("sendbutton");
      label_contact_name.show_all();
      label_contact_name.show_entry.connect_after(() => {
        label_contact_name.entry.text = contact.alias;
      });
      label_contact_name.label_changed.connect((new_alias) => {
        contact.alias = new_alias;
        contact_changed(contact);
      });

      //TODO
      button_call = builder.get_object("button_call") as Gtk.Button;
      button_call_video = builder.get_object("button_call_video") as Gtk.Button;
      button_call.clicked.connect(button_call_clicked);
      button_call_video.clicked.connect(button_call_video_clicked);
      button_call_video.sensitive = false;
      contact.notify["call-state"].connect(() => {
        Logger.log(LogLevel.DEBUG, "Changing call state to " + contact.call_state.to_string());
        //box_volume.visible = contact.call_state == CallState.STARTED;
        unowned Gtk.StyleContext ctx_ca = button_call.get_style_context();
        unowned Gtk.StyleContext ctx_cv = button_call_video.get_style_context();
        switch(contact.call_state) {
          case CallState.RINGING:
          case CallState.CALLING:
            ctx_ca.remove_class("callbutton");
            ctx_ca.remove_class("callbutton-started");
            ctx_ca.add_class("callbutton-ringing");
            if(contact.video) {
              ctx_cv.remove_class("callbutton");
              ctx_cv.remove_class("callbutton-started");
              ctx_cv.add_class("callbutton-ringing");
            }
            break;
          case CallState.STARTED:
            ctx_ca.remove_class("callbutton");
            ctx_ca.remove_class("callbutton-ringing");
            ctx_ca.add_class("callbutton-started");
            if(contact.video) {
              ctx_cv.remove_class("callbutton");
              ctx_cv.remove_class("callbutton-ringing");
              ctx_cv.add_class("callbutton-started");
            }
            break;
          default:
            ctx_ca.add_class("callbutton");
            ctx_ca.remove_class("callbutton-ringing");
            ctx_ca.remove_class("callbutton-started");
            if(contact.video) {
              ctx_cv.add_class("callbutton");
              ctx_cv.remove_class("callbutton-ringing");
              ctx_cv.remove_class("callbutton-started");
            }
            break;
        }
        ctx_ca.invalidate();
        ctx_cv.invalidate();
      });
      //FIXME currently commented out as it introduces sigsev on gtk 3.4
/*
      Gtk.ScaleButton volume_speakers = new Gtk.ScaleButton(Gtk.IconSize.SMALL_TOOLBAR);
      Gtk.ScaleButton volume_mic = new Gtk.ScaleButton(Gtk.IconSize.SMALL_TOOLBAR);
      volume_mic.set_icons({
        "microphone-sensitivity-muted",
        "microphone-sensitivity-high",
        "microphone-sensitivity-low",
        "microphone-sensitivity-medium",
        null
      });
      volume_speakers.show_all();
      volume_mic.show_all();
      box_volume.pack_start(volume_speakers, false);
      box_volume.pack_start(volume_mic, false);

      Settings.instance.bind_property(Settings.MIC_VOLUME_KEY, volume_mic, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      contact.bind_property("volume", volume_speakers, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      volume_speakers.value_changed.connect((d_volume) => {
        int volume = (int)(d_volume * 100.0);
        Logger.log(LogLevel.DEBUG, "Setting volume for %s to %i".printf(contact.name, volume));
        AudioManager.instance.set_volume(contact, volume);
      });*/

      button_send = builder.get_object("button_send") as Gtk.Button;
      button_send_file = builder.get_object("button_send_file") as Gtk.Button;

      button_send.clicked.connect(() => {textview_activate();});
      button_send_file.clicked.connect(button_send_file_clicked);

      Gtk.ScrolledWindow scrolled_window_message = builder.get_object("scrolled_window_message") as Gtk.ScrolledWindow;
      message_textview = new MessageTextView();
      message_textview.border_width = 6;
      message_textview.wrap_mode = Gtk.WrapMode.WORD_CHAR;
      message_textview.textview_activate.connect(textview_activate);
      message_textview.typing_status.connect((is_typing) => {
        typing_status(is_typing);
      });

      message_textview.paste_clipboard.connect(() => {
        Gtk.Clipboard cb = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
        if(cb.wait_is_image_available()) {
          Gdk.Pixbuf pb = cb.wait_for_image();
          try {
            uint8[] data;
            pb.save_to_buffer(out data, "png");
            if(data.length > 0x100000) {
              pb.save_to_buffer(out data, "jpeg");
              prepare_send_data("clipboard.jpg", data);
            } else {
              prepare_send_data("clipboard.png", data);
            }

          } catch (Error error) {
          }
        }
      });

      scrolled_window_message.add(message_textview);

      image_send.set_from_pixbuf(ResourceFactory.instance.send);
      image_call.set_from_pixbuf(ResourceFactory.instance.call);
      image_call_video.set_from_pixbuf(ResourceFactory.instance.call_video);
      image_send_file.set_from_pixbuf(ResourceFactory.instance.send_file);
      image_insert_smiley.set_from_pixbuf(ResourceFactory.instance.smiley);
      

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

    bool is_typing = false;
    // changes typing status to false after >= 15 seconds of inactivity
    bool is_typing_timeout_fn_running = false;
    Timer is_typing_timer = new Timer();
    private bool is_typing_timeout_fn() {
      if(is_typing) {
        if(is_typing_timer.elapsed() > 15) {
          is_typing = false;
          conversation_view.on_typing_changed(is_typing);
          is_typing_timeout_fn_running = false;
          return false;
        } else {
          // wait another second
          return true;
        }
      }
      // abort timeout function when is_typing is already false
      is_typing_timeout_fn_running = false;
      return false;
    }

    public void on_typing_changed(bool is_typing) {
      is_typing_timer.start();
      if(this.is_typing == is_typing) {
        return;
      }
      this.is_typing = is_typing;

      if(is_typing && !is_typing_timeout_fn_running) {
        is_typing_timeout_fn_running = true;
        Timeout.add(1, is_typing_timeout_fn);
      }

      conversation_view.on_typing_changed(is_typing);
    }

    private void add_filetransfer(FileTransfer ft) {
      FileTransferChatEntry entry = new FileTransferChatEntry(ft);
      entry.filetransfer_accepted.connect((ft) => { filetransfer_accepted(ft); });
      entry.filetransfer_rejected.connect((ft) => { filetransfer_rejected(ft); });
      conversation_view.add_filetransfer(entry);
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

    public void textview_activate() {
      string s = message_textview.buffer.text;
      if(!contact.online || message_textview.placeholder_visible || s == "") {
        return;
      }

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
        Message m = new Message.outgoing(contact, s);
        conversation_view.add_message(m);
        new_outgoing_message(m);
      }
      message_textview.buffer.text = "";
    }

    //GUI events
    public void button_send_file_clicked(Gtk.Button source){
      Gtk.FileChooserDialog file_selection_dialog = new Gtk.FileChooserDialog(_("Select a file to send"),null,
                                                                              Gtk.FileChooserAction.OPEN,
                                                                              "_Cancel", Gtk.ResponseType.CANCEL,
                                                                              _("Select"), Gtk.ResponseType.ACCEPT);
      int response = file_selection_dialog.run();
      if(response != Gtk.ResponseType.ACCEPT){
        file_selection_dialog.destroy();
        return;
      }
      File file = file_selection_dialog.get_file();
      file_selection_dialog.destroy();
      prepare_send_file(file);
    }

    public void button_call_clicked(Gtk.Button source) {
      if(contact.call_state != CallState.ENDED) {
        stop_audio_call(contact);
      } else {
        start_audio_call(contact);
      }
    }

    public void button_call_video_clicked(Gtk.Button source) {
      if(contact.call_state == CallState.ENDED) {
        start_video_call(contact);
      } else {
        //FIXME enable video when call already running
        stop_audio_call(contact);
      }
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
        Logger.log(LogLevel.ERROR, "Error occured while getting file size: " + e.message);
        return;
      }
      FileTransfer ft = new FileTransfer(contact, FileTransferDirection.OUTGOING, file_size, file.get_basename(), file.get_path() );
      new_outgoing_file(ft);
      add_filetransfer(ft);
    }

    private void prepare_send_data(string name, uint8[] data) {
      FileTransfer ft = new FileTransfer.senddata(contact, name, data);
      new_outgoing_file(ft);
      add_filetransfer(ft);
    }
  }
}
