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
    public abstract void add_message(IMessage message);
    public abstract void add_filetransfer(FileTransferChatEntry entry);
  }

  public class ConversationView : IConversationView, Gtk.EventBox {
    public bool short_names {get; set; default = false;}
    private Gtk.Box conversation_list;
    private IMessage last_message = null;

    public ConversationView() {
      conversation_list = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
      this.add(conversation_list);
    }

    public void add_filetransfer(FileTransferChatEntry entry) {
      conversation_list.pack_start(entry,false,false,0);
      entry.set_visible(true);
    }

    public void add_message(IMessage message) {
      ChatMessage cm;
      if(last_message != null && last_message.compare_sender(message)) {
        cm = new ChatMessage(message, short_names, true);
      } else {
        cm = new ChatMessage(message, short_names, false);
      }
      conversation_list.pack_start(cm,false,false,0);
      last_message = message;
    }
  }
}
