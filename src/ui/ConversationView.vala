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
    private int last_width;

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
        is_typing_label.set_markup(_("<i>%s</i>").printf(is_typing_string));
      });
      conversation_list.pack_end(is_typing_label, false, false);
    }

    public void add_filetransfer(FileTransferChatEntry entry) {
      entry.filetransfer_completed.connect((entry, ft) => {
        if(!ft.isfile) {
          try {
            Gdk.PixbufLoader loader = new Gdk.PixbufLoader();
            loader.write(ft.data);
            loader.close();

            int position;
            conversation_list.child_get(entry, "position", out position);

            Gtk.Image image = new Gtk.Image.from_pixbuf(loader.get_pixbuf());
            conversation_list.pack_start(image, false, false, 0);
            conversation_list.reorder_child(image, position + 1);
            image.set_alignment(0, 0);
            image.set_visible(true);

          } catch (Error error) {
            Logger.log(LogLevel.ERROR, "Adding filetransfer failed: " + error.message);
          }
        }
      });

      conversation_list.pack_start(entry, false, false, 0);
      entry.set_visible(true);

      last_message = null;
    }

    public void add_message(IMessage message) {
      bool same_sender = false;
      ChatMessage cm;

      if(last_message != null && last_message.compare_sender(message)) {
        same_sender = true;
      }

      cm = new ChatMessage(message, short_names, same_sender, last_width);

      conversation_list.pack_start(cm, false, false);
      cm.show_all();

      if(!same_sender) {
        last_width = cm.get_name_label_width();
      }
      last_message = message;
    }
    public void register_search_entry(Gtk.Entry entry) {
    }
  }
}
