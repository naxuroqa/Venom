/*
 *    ConversationWindow.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  [GtkTemplate(ui = "/im/tox/venom/ui/conversation_window.ui")]
  public class ConversationWindow : Gtk.Box {
    [GtkChild]
    private Gtk.Label user_name;
    [GtkChild]
    private Gtk.Label user_status;
    [GtkChild]
    private Gtk.Image user_image;
    [GtkChild]
    private Gtk.TextView text_view;
    [GtkChild]
    private Gtk.ListBox message_list;
    [GtkChild]
    private Gtk.ScrolledWindow scrolled_window;

    private const GLib.ActionEntry win_entries[] =
    {
      { "contact-info",  on_contact_info,  null, null, null },
      { "start-call",    on_start_call,    null, null, null },
      { "start-video",   on_start_video,   null, null, null },
      { "insert-file",   on_insert_file,   null, null, null },
      { "insert-smiley", on_insert_smiley, null, null, null }
    };

    private unowned ApplicationWindow app_window;
    private ILogger logger;
    private Conversation conversation;
    private ConversationWidgetListener listener;

    public ConversationWindow(ApplicationWindow app_window, ILogger logger, Conversation conversation, ConversationWidgetListener listener) {
      this.app_window = app_window;
      this.logger = logger;
      this.conversation = conversation;
      this.listener = listener;

      var contact = conversation.get_contact();
      user_name.label = contact.get_name_string();
      user_status.label = contact.get_status_string();

      var model = new ConversationModel(conversation);
      message_list.bind_model(model, create_entry);
      unmap.connect(() => { message_list.bind_model(null, null); });

      text_view.key_press_event.connect(on_keypress);
      app_window.add_action_entries(win_entries, this);

      // trigger autoscroll
      on_items_changed(0, 0, 1);

      model.items_changed.connect(on_items_changed);

      logger.d("ConversationWindow created.");
    }

    ~ConversationWindow() {
      logger.d("ConversationWindow destroyed.");
      foreach (var entry in win_entries) {
        app_window.remove_action(entry.name);
      }
      logger = null;
    }

    private void on_items_changed(uint pos, uint rem, uint add) {
      if (add - rem > 0) {
        GLib.Timeout.add(50, scroll_to_end);
      }
    }

    private bool scroll_to_end() {
      var adjustment = scrolled_window.vadjustment;
      adjustment.value = adjustment.upper - adjustment.page_size;
      return false;
    }

    private Gtk.Widget create_entry(GLib.Object object) {
      return new MessageWidget(logger, object as IMessage);
    }

    private void on_message(string message) {
      logger.d("on_message");

      try {
        listener.on_send_message(conversation.get_contact(), message);
      } catch (Error e) {
        logger.f("Could not send message: " + e.message);
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

    private void on_contact_info() {
      logger.d("on_contact_info");
      app_window.on_show_friend(conversation.get_contact());
    }

    private void on_start_call() {
      logger.d("on_start_call");
    }

    private void on_start_video() {
      logger.d("on_start_video");
    }

    private void on_insert_file() {
      logger.d("on_insert_file");
    }

    private void on_insert_smiley() {
      logger.d("on_insert_smiley");
      text_view.grab_focus();
      text_view.insert_emoji();
    }
  }

  public interface ConversationWidgetListener : GLib.Object {
    public abstract void on_send_message(IContact contact, string message) throws Error;
  }

  public class ConversationModel : GLib.Object, GLib.ListModel {
    private Conversation conversation;

    public ConversationModel(Conversation conversation) {
      this.conversation = conversation;
      conversation.message_added.connect(on_message_added);
      conversation.message_removed.connect(on_message_removed);
      conversation.message_changed.connect(on_message_changed);
    }

    private void on_message_added(GLib.Object sender, uint index) {
      items_changed(index, 0, 1);
    }

    private void on_message_removed(GLib.Object sender, uint index) {
      items_changed(index, 1, 0);
    }

    private void on_message_changed(GLib.Object sender, uint index) {
      items_changed(index, 1, 1);
    }

    public virtual GLib.Object ? get_item(uint position) {
      return conversation.get_item(position);
    }

    public virtual GLib.Type get_item_type() {
      return typeof (IMessage);
    }

    public virtual uint get_n_items() {
      return conversation.length();
    }

    public virtual GLib.Object ? get_object(uint position) {
      return get_item(position);
    }
  }
}
