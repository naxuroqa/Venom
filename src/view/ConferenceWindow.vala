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
  [GtkTemplate(ui = "/im/tox/venom/ui/conference_window.ui")]
  public class ConferenceWindow : Gtk.Box {
    [GtkChild]
    private Gtk.Label conference_title;
    [GtkChild]
    private Gtk.Label conference_peers;
    [GtkChild]
    private Gtk.TextView text_view;
    [GtkChild]
    private Gtk.ListBox message_list;
    [GtkChild]
    private Gtk.ScrolledWindow scrolled_window;

    private const GLib.ActionEntry win_entries[] =
    {
      { "conference-info",  on_conference_info,  null, null, null },
      { "show-peers",  on_show_peers,  null, null, null },
      { "insert-smiley", on_insert_smiley, null, null, null }
    };

    private unowned ApplicationWindow app_window;
    private ILogger logger;
    private ObservableList conversation;
    private ConferenceWidgetListener listener;
    private IContact contact;

    public ConferenceWindow(ApplicationWindow app_window, ILogger logger, ObservableList conversation, IContact contact, ConferenceWidgetListener listener) {
      this.app_window = app_window;
      this.logger = logger;
      this.conversation = conversation;
      this.listener = listener;
      this.contact = contact;

      contact.changed.connect(update_widgets);
      update_widgets();

      var model = new ObservableListModel(conversation);
      var creator = new MessageWidgetCreator(logger);
      message_list.bind_model(model, creator.create_message);

      text_view.key_press_event.connect(on_keypress);
      app_window.add_action_entries(win_entries, this);
      app_window.focus_in_event.connect(focus_in_event);

      delayed_scroll_to_end();
      model.items_changed.connect(on_items_changed);

      logger.d("ConferenceWindow created.");
    }

    ~ConferenceWindow() {
      logger.d("ConferenceWindow destroyed.");
      foreach (var entry in win_entries) {
        app_window.remove_action(entry.name);
      }
      logger = null;
    }

    private bool focus_in_event() {
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
      conference_title.label = contact.get_name_string();
      conference_peers.label = contact.get_status_string();
    }

    private void on_items_changed(uint pos, uint rem, uint add) {
      if (add - rem > 0) {
        delayed_scroll_to_end();
      }
    }

    private void delayed_scroll_to_end() {
      GLib.Timeout.add(50, scroll_to_end);
    }

    private bool scroll_to_end() {
      var adjustment = scrolled_window.vadjustment;
      adjustment.value = adjustment.upper - adjustment.page_size;
      return false;
    }

    private void on_message(string message) {
      logger.d("on_message");

      try {
        listener.on_send_conference_message(contact, message);
      } catch (Error e) {
        logger.e("Could not send message: " + e.message);
      }
    }

    private bool on_keypress(Gdk.EventKey event) {
      if (event.keyval == Gdk.Key.Return) {
        var message = text_view.buffer.text;
        text_view.buffer.text = "";
        if (message.length > 0) {
          on_message(message);
        }
        return true;
      }
      return false;
    }

    private void on_conference_info() {
      app_window.on_show_conference(contact);
    }

    private void on_show_peers() {
      logger.d("on_show_peers");
    }

    private void on_insert_smiley() {
      logger.d("on_insert_smiley");
      text_view.grab_focus();
      text_view.insert_emoji();
    }
  }

  public interface ConferenceWidgetListener : GLib.Object {
    public abstract void on_send_conference_message(IContact contact, string message) throws Error;
  }
}
