/*
 *    ConferenceWindow.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/conference_window.ui")]
  public class ConferenceWindow : Gtk.Box {
    [GtkChild] private Gtk.Image user_image;
    [GtkChild] private Gtk.TextView text_view;
    [GtkChild] private Gtk.ListBox message_list;
    [GtkChild] private Gtk.ScrolledWindow scrolled_window;
    [GtkChild] private Gtk.Box placeholder;
    [GtkChild] private Gtk.Widget header_start;
    [GtkChild] private Gtk.Widget header_end;
    [GtkChild] private Gtk.ListBox peers;
    [GtkChild] private Gtk.Widget peers_placeholder;

    private const GLib.ActionEntry win_entries[] =
    {
      { "conference-info", on_conference_info,  null, null, null },
      { "insert-smiley", on_insert_smiley, null, null, null }
    };

    private unowned ApplicationWindow app_window;
    private Logger logger;
    private ObservableList conversation;
    private ConferenceWidgetListener listener;
    private IContact contact;
    private UserInfo user_info;
    private TextViewEventHandler text_view_event_handler;
    private AdjustmentAutoScroller auto_scroller;
    private Cancellable cancellable;
    private ObservableList peers_list;
    private Undo.TextBufferUndoBinding text_buffer_undo_binding;

    public ConferenceWindow(ApplicationWindow app_window, Logger logger, ObservableList conversation, IContact contact, UserInfo user_info, ISettingsDatabase settings, ConferenceWidgetListener listener) {
      this.app_window = app_window;
      this.logger = logger;
      this.conversation = conversation;
      this.listener = listener;
      this.contact = contact;
      this.user_info = user_info;
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

      app_window.reset_header_bar();
      app_window.header_start.pack_start(header_start);
      app_window.header_end.pack_start(header_end);

      contact.changed.connect(update_widgets);
      update_widgets();

      var model = new LazyObservableListModel(logger, conversation, cancellable);
      var creator = new MessageWidgetCreator(logger, user_info, settings, null);
      message_list.bind_model(model, creator.create_message);
      message_list.set_placeholder(placeholder);

      peers.set_placeholder(peers_placeholder);

      model.notify["initialized"].connect(show_messages);
      if (model.initialized) {
        show_messages();
      }

      app_window.add_action_entries(win_entries, this);
      app_window.focus_in_event.connect(on_focus_in_event);

      auto_scroller = new AdjustmentAutoScroller(scrolled_window.vadjustment);
      auto_scroller.scroll_to_bottom();

      logger.d("ConferenceWindow created.");
    }

    ~ConferenceWindow() {
      logger.d("ConferenceWindow destroyed.");
      cancellable.cancel();
      foreach (var entry in win_entries) {
        app_window.remove_action(entry.name);
      }
      logger = null;
    }

    private void show_messages() {
      var stack = scrolled_window.parent as Gtk.Stack;
      stack.set_visible_child(scrolled_window);
    }

    private bool on_focus_in_event() {
      contact.clear_attention();
      contact.changed();
      return false;
    }

    private void update_widgets() {
      if (contact.get_requires_attention() && app_window.is_active) {
        contact.clear_attention();
        contact.changed();
        return;
      }

      var pixbuf = contact.get_image();
      if (pixbuf != null) {
        user_image.pixbuf = round_corners(pixbuf.scale_simple(22, 22, Gdk.InterpType.BILINEAR));
      }

      this.peers_list = new ObservableList();
      peers_list.set_collection((contact as Conference).get_peers().values);
      var peers_list_model = new ObservableListModel(peers_list);
      var peers_list_creator = new PeersListCreator(logger);
      peers.bind_model(peers_list_model, peers_list_creator.create);

      app_window.header_bar.title = contact.get_name_string();
      app_window.header_bar.subtitle = contact.get_status_string();
    }

    private void on_send() {
      logger.d("on_send");
      var message = text_view.buffer.text;
      if (message.length > 0) {
        try {
          listener.on_send_conference_message(contact, message);
        } catch (Error e) {
          logger.e("Could not send message: " + e.message);
          return;
        }
        text_view.buffer.text = "";
      }
    }

    private void on_conference_info() {
      app_window.on_show_conference(contact);
    }

    private void on_insert_smiley() {
      logger.d("on_insert_smiley");
      text_view.grab_focus();
      text_view.insert_emoji();
    }

    private class PeersListCreator {
      Logger logger;
      public PeersListCreator(Logger logger) {
        this.logger = logger;
      }
      public Gtk.Widget create(GLib.Object o) {
        return new PeerEntryCompact(logger, o as ConferencePeer);
      }
    }
  }

  public interface ConferenceWidgetListener : GLib.Object {
    public abstract void on_send_conference_message(IContact contact, string message) throws Error;
  }
}
