/*
 *    TextConversationView.vala
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
  public class TextConversationView : IConversationView, Gtk.EventBox {
    private Gtk.TextView   text_view;
    private Gtk.TextBuffer text_buffer;
    private Gtk.TextTag bold_tag;
    private Gtk.TextTag grey_tag;

    public TextConversationView() {
      text_view = new Gtk.TextView();
      text_view.set_wrap_mode(Gtk.WrapMode.WORD_CHAR);
      text_view.editable = false;
      text_buffer = text_view.buffer;

      this.add(text_view);
      
      bold_tag = text_buffer.create_tag(null, "weight", 600);
      grey_tag = text_buffer.create_tag(null, "foreground", "grey");
    }

    public void add_message(IMessage message) {
      Gtk.TextIter text_end;
      string text;
      text_buffer.get_end_iter(out text_end);
      text = "[%s] ".printf(
        message.get_time_plain()
      );
      text_buffer.insert_with_tags(text_end, text, text.length, grey_tag);

      text_buffer.get_end_iter(out text_end);
      text = "<%s> ".printf(
        message.get_sender_plain()
      );
      text_buffer.insert_with_tags(text_end, text, text.length, bold_tag);

      text_buffer.get_end_iter(out text_end);
      text = "%s ".printf(
        message.get_message_plain()
      );
      text_buffer.insert(ref text_end, text, text.length);

      text_buffer.get_end_iter(out text_end);
      text_buffer.insert(ref text_end, "\n", 1);
    }
  }
}
