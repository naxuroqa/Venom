/*
 *    ConversationTextView.vala
 *
 *    Copyright (C) 2014  Venom authors and contributors
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
  public class ConversationTextView : IConversationView, Gtk.TextView {
    public bool short_names {get; set; default = false;}
    private Gtk.TextTag bold_tag;
    private Gtk.TextTag grey_tag;
    private Gtk.TextTag implication_tag;

    public ConversationTextView() {
      set_wrap_mode(Gtk.WrapMode.WORD_CHAR);
      editable = false;

      bold_tag = buffer.create_tag(null, "weight", 600);
      grey_tag = buffer.create_tag(null, "foreground", "grey");
      implication_tag = buffer.create_tag(null, "foreground", "green");
    }

    public void add_message(IMessage message) {
      Gtk.TextIter text_end;
      string text;
      buffer.get_end_iter(out text_end);
      text = "[%s] ".printf(
        message.get_time_plain()
      );
      buffer.insert_with_tags(text_end, text, text.length, grey_tag);

      buffer.get_end_iter(out text_end);
      text = "%s: ".printf(
        short_names ? Tools.shorten_name(message.get_sender_plain()) : message.get_sender_plain()
      );
      buffer.insert_with_tags(text_end, text, text.length, bold_tag);

      buffer.get_end_iter(out text_end);
      text = "%s".printf(
        message.get_message_plain()
      );
      if (text[0] == '>') {
        buffer.insert_with_tags(text_end, text, text.length, implication_tag);
      } else {
        buffer.insert(ref text_end, text, text.length);
      }

      buffer.get_end_iter(out text_end);
      buffer.insert(ref text_end, "\n", 1);
    }
    public void add_filetransfer(FileTransferChatEntry entry) {
      Gtk.TextIter iter;
      buffer.get_end_iter(out iter);
      Gtk.TextChildAnchor child_anchor = buffer.create_child_anchor(iter);
      add_child_at_anchor(entry, child_anchor);
      entry.show();

      buffer.get_end_iter(out iter);
      buffer.insert(ref iter, "\n", 1);
    }
  }
}
