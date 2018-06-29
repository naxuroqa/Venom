/*
 *    ConversationWindow.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/conversation_window.ui")]
  public class ConversationWindow : Gtk.Box {
    [GtkChild] private Gtk.Image user_image;
    [GtkChild] private Gtk.TextView text_view;
    [GtkChild] private Gtk.ListBox message_list;
    [GtkChild] private Gtk.ScrolledWindow scrolled_window;
    [GtkChild] private Gtk.Revealer typing_revealer;
    [GtkChild] private Gtk.Label typing_label;
    [GtkChild] private Gtk.Overlay overlay;
    [GtkChild] private Gtk.Popover popover;
    [GtkChild] private Gtk.Box placeholder;
    [GtkChild] private Gtk.Widget header_start;
    [GtkChild] private Gtk.Widget header_end;

    private const GLib.ActionEntry win_entries[] =
    {
      { "contact-info",      on_contact_info,  null, null, null },
      { "start-call",        on_start_call,    null, null, null },
      { "start-video",       on_start_video,   null, null, null },
      { "insert-file",       on_insert_file,   null, null, null },
      { "insert-screenshot", on_insert_screenshot,   null, null, null },
      { "insert-smiley",     on_insert_smiley, null, null, null }
    };

    private unowned ApplicationWindow app_window;
    private ILogger logger;
    private ObservableList conversation;
    private ConversationWidgetListener listener;
    private ConversationWidgetFiletransferListener filetransfer_listener;
    private bool is_typing;
    private IContact contact;
    private TextViewEventHandler text_view_event_handler;
    private AdjustmentAutoScroller auto_scroller;
    private Cancellable cancellable;
    private Undo.TextBufferUndoBinding text_buffer_undo_binding;

    public ConversationWindow(ApplicationWindow app_window,
                              ILogger logger,
                              ObservableList conversation,
                              IContact contact,
                              ISettingsDatabase settings,
                              ConversationWidgetListener listener,
                              ConversationWidgetFiletransferListener filetransfer_listener,
                              FileTransferEntryListener file_transfer_entry_listener) {
      this.app_window = app_window;
      this.logger = logger;
      this.conversation = conversation;
      this.contact = contact;
      this.listener = listener;
      this.filetransfer_listener = filetransfer_listener;
      this.cancellable = new Cancellable();

      this.text_buffer_undo_binding = new Undo.TextBufferUndoBinding();
      text_buffer_undo_binding.add_actions_to(app_window);
      text_buffer_undo_binding.bind_buffer(text_view.buffer);
      text_view.populate_popup.connect(text_buffer_undo_binding.populate_popup);

      if (settings.enable_spelling) {
        Gspell.TextView.get_from_gtk_text_view(text_view).basic_setup();
      }

      text_view_event_handler = new TextViewEventHandler();
      text_view_event_handler.send.connect(on_send);
      text_view.key_press_event.connect(text_view_event_handler.on_key_press_event);

      overlay.add_overlay(typing_revealer);

      app_window.reset_header_bar();
      app_window.header_start.pack_start(header_start);
      app_window.header_end.pack_start(header_end);

      contact.changed.connect(update_widgets);
      update_widgets();

      var model = new LazyObservableListModel(logger, conversation, cancellable);
      var creator = new MessageWidgetCreator(logger, settings, file_transfer_entry_listener);
      message_list.bind_model(model, creator.create_message);
      message_list.set_placeholder(placeholder);

      text_view.buffer.changed.connect(on_buffer_changed);
      app_window.add_action_entries(win_entries, this);
      app_window.focus_in_event.connect(on_focus_in_event);

      auto_scroller = new AdjustmentAutoScroller(scrolled_window.vadjustment);
      auto_scroller.scroll_to_bottom();

      logger.d("ConversationWindow created.");
    }

    private void update_widgets() {
      if (contact.get_requires_attention() && app_window.is_active) {
        contact.clear_attention();
        contact.changed();
        return;
      }
      app_window.header_bar.title = contact.get_name_string();
      app_window.header_bar.subtitle = contact.get_status_string();
      var pixbuf = contact.get_image();
      if (pixbuf != null) {
        user_image.pixbuf = round_corners(pixbuf.scale_simple(22, 22, Gdk.InterpType.BILINEAR));
      }
      typing_label.label = _("%s is typing…").printf(contact.get_name_string());
      typing_revealer.reveal_child = contact.is_typing();
    }

    private bool on_focus_in_event() {
      contact.clear_attention();
      contact.changed();
      return false;
    }

    ~ConversationWindow() {
      logger.d("ConversationWindow destroyed.");
      cancellable.cancel();
      foreach (var entry in win_entries) {
        app_window.remove_action(entry.name);
      }
      logger = null;
    }

    private void on_buffer_changed() {
      var typing = text_view.buffer.text != "";
      if (typing != is_typing) {
        is_typing = typing;
        try_set_typing(typing);
      }
    }

    private void try_set_typing(bool typing) {
      try {
        listener.on_set_typing(contact, typing);
      } catch (Error e) {
        logger.e("Could not set typing status: " + e.message);
      }
    }

    private void on_send() {
      logger.d("on_send");
      var message = text_view.buffer.text;
      if (message.length > 0) {
        try {
          listener.on_send_message(contact, message);
        } catch (Error e) {
          logger.e("Could not send message: " + e.message);
          return;
        }
        text_view.buffer.text = "";
        text_buffer_undo_binding.clear();
        try_set_typing(false);
      }
    }
    
    private void on_insert_new_line() {
      text_view.buffer.insert_at_cursor("\n", 1);
    }

    private void on_contact_info() {
      logger.d("on_contact_info");
      app_window.on_show_friend(contact);
    }

    private void on_start_call() {
      logger.d("on_start_call");
    }

    private void on_start_video() {
      logger.d("on_start_video");
    }

    private async void insert_screenshot_async() {
      try {
        logger.d("insert_screenshot_async");
        var bus = yield Bus.get(BusType.SESSION);
        var screenshot = yield bus.get_proxy<org.freedesktop.portal.Screenshot>("org.freedesktop.portal.Desktop", "/org/freedesktop/portal/desktop");

        var options = new GLib.HashTable<string, GLib.Variant>(str_hash, str_equal);
        var handle = screenshot.screenshot("", options);
        var request = yield bus.get_proxy<org.freedesktop.portal.Request>("org.freedesktop.portal.Desktop", handle);
        request.response.connect((response, results) => {
          if (response != 0) {
            logger.d("Insert screenshot cancelled.");
          } else {
            var uri = results.@get("uri").get_string();
            logger.d(@"Insert screenshot with uri $uri.");
            var file = GLib.File.new_for_uri(uri);
            try {
              filetransfer_listener.on_start_filetransfer(contact, file);
            } catch (Error e) {
              logger.e("Can not start file transfer: " + e.message);
            }
          }
          insert_screenshot_async.callback();
        });
        yield;
      } catch (Error e) {
        logger.e("Can not take screenshot: " + e.message);
      }
    }

    private void on_insert_screenshot() {
      logger.d("on_insert_screenshot");
      popover.popdown();
      insert_screenshot_async.begin();
    }

    private void on_insert_file() {
      logger.d("on_insert_file");
      popover.popdown();
      var file_chooser_dialog = new Gtk.FileChooserNative(_("Choose a file to send"),
                                                          app_window,
                                                          Gtk.FileChooserAction.OPEN,
                                                          _("_Open"),
                                                          _("_Cancel"));
      var result = file_chooser_dialog.run();
      var file = file_chooser_dialog.get_file();
      if (result == Gtk.ResponseType.ACCEPT && file != null) {
        try {
          filetransfer_listener.on_start_filetransfer(contact, file);
        } catch (Error e) {
          logger.e("Could not start file transfer: " + e.message);
        }
      }
    }

    private void on_insert_smiley() {
      logger.d("on_insert_smiley");
      text_view.grab_focus();
      text_view.insert_emoji();
    }
  }

  public class AdjustmentAutoScroller {
    public bool auto_scroll { get; set; default = true; }
    private bool scrolled_to_bottom = true;
    private Gtk.Adjustment adjustment;

    public AdjustmentAutoScroller(Gtk.Adjustment adjustment) {
      this.adjustment = adjustment;
      adjustment.changed.connect(on_changed);
      adjustment.value_changed.connect(on_value_changed);
    }

    public void scroll_to_bottom() {
      adjustment.value = adjustment.upper - adjustment.page_size;
    }

    private void on_changed() {
      if (scrolled_to_bottom && auto_scroll) {
        scroll_to_bottom();
      }
    }

    private void on_value_changed() {
      scrolled_to_bottom = (adjustment.value == adjustment.upper - adjustment.page_size);
    }
  }

  public interface ConversationWidgetFiletransferListener : GLib.Object {
    public abstract void on_start_filetransfer(IContact contact, File file) throws Error;
  }

  public class TextViewEventHandler {
    Gtk.AccelKey key;

    public TextViewEventHandler() {
      var accel_path = "<Venom>/Message/Send";
      if (!Gtk.AccelMap.lookup_entry(accel_path, out key)) {
        key.accel_mods = ~Gdk.ModifierType.MODIFIER_MASK;
        key.accel_key = Gdk.Key.Return;
        Gtk.AccelMap.add_entry(accel_path, key.accel_key, key.accel_mods);
      }
    }

    public signal void send();
    public signal void insert_new_line();
    
    public bool on_key_press_event(Gdk.EventKey event) {
      if (event.keyval == key.accel_key) {
        if ((event.state & Gdk.ModifierType.SHIFT_MASK) > 0) {
          insert_new_line();
        } else {
          send();
        }
        return true;
      }
      return false;
    }
  }

  public class MessageWidgetCreator {
    private unowned ILogger logger;
    private ISettingsDatabase settings;
    private FileTransferEntryListener? file_transfer_entry_listener;
    public MessageWidgetCreator(ILogger logger, ISettingsDatabase settings, FileTransferEntryListener? file_transfer_entry_listener) {
      this.logger = logger;
      this.settings = settings;
      this.file_transfer_entry_listener = file_transfer_entry_listener;
    }

    public Gtk.Widget create_message(GLib.Object object) {
      if (object is IMessage) {
        return new MessageWidget(logger, (IMessage) object, settings);
      } else if (file_transfer_entry_listener != null && object is FileTransfer) {
        return new FileTransferEntryInline(logger, (FileTransfer) object, file_transfer_entry_listener);
      } else {
        assert_not_reached();
      }
    }
  }

  public interface ConversationWidgetListener : GLib.Object {
    public abstract void on_send_message(IContact contact, string message) throws Error;
    public abstract void on_set_typing(IContact contact, bool typing) throws Error;
  }
}
