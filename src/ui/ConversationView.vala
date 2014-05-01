/*
 *    ConversationView.vala
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
  public interface IConversationView : Gtk.Widget {
    public abstract bool short_names {get; set;}
    public abstract string is_typing_string {get; set;}
    public abstract void add_message(IMessage message);
    public abstract void add_filetransfer(FileTransferChatEntry entry);
    public abstract void register_search_entry(Gtk.Entry entry);
    public abstract void on_typing_changed(bool status);
  }

  public class ConversationView : IConversationView, Gtk.EventBox {
    public bool short_names {get; set; default = false;}
    public string is_typing_string {get; set; default = "";}
    private Gtk.Box conversation_list;
    private Gtk.Label is_typing_label;
    private IMessage last_message = null;

    public void on_typing_changed(bool status) {
      is_typing_label.visible = status;
    }

    public ConversationView() {
      conversation_list = new Gtk.Box(Gtk.Orientation.VERTICAL, 3);
      this.get_style_context().add_class("conversation_view");
      this.add(conversation_list);

      is_typing_label = new Gtk.Label(is_typing_string);
      is_typing_label.xalign = 0;
      is_typing_label.no_show_all = true;
      is_typing_label.visible = false;
      is_typing_label.set_use_markup(true);
      this.notify["is-typing-string"].connect(() => {
        is_typing_label.set_markup("<i>" + is_typing_string + "</i>");
      });
      conversation_list.pack_end(is_typing_label, false, false);
    }

    public void add_filetransfer(FileTransferChatEntry entry) {
      conversation_list.pack_start(entry, false, false, 0);
      entry.set_visible(true);
    }

    public void add_message(IMessage message) {
      ChatMessage cm;
      if(last_message != null && last_message.compare_sender(message)) {
        cm = new ChatMessage(message, short_names, true);
      } else {
        var sep = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
        conversation_list.pack_start(sep, false, false);
        sep.show_all();
        cm = new ChatMessage(message, short_names, false);
      }
      conversation_list.pack_start(cm, false, false);
      cm.show_all();
      last_message = message;
    }
    public void register_search_entry(Gtk.Entry entry) {
    }
  }
}
