/*
 *    MessageTextView.vala
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
  public class MessageTextView : Gtk.TextView {
    public signal void textview_activate();

    public string placeholder_text { get; set; default = "Type your message here..."; }
    public Gtk.TextTag placeholder_tag { get; set; }

    private bool show_placeholder = true;

    public MessageTextView() {
      placeholder_tag = buffer.create_tag(null, "foreground", "grey");
      append_tagged_text(placeholder_text, placeholder_tag);

      key_press_event.connect((k) => {
        // only catch return if shift or control keys are not pressed
        if(k.keyval == Gdk.Key.Return && (k.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) == 0) {
          textview_activate();
          return true;
        }
        return false;
      });

      focus_in_event.connect(() => {
        if(show_placeholder) {
          buffer.text = "";
        }
        return false;
      });

      focus_out_event.connect(() => {
        if(buffer.text == "") {
          append_tagged_text(placeholder_text, placeholder_tag);
          show_placeholder = true;
        } else {
          show_placeholder = false;
        }
        return false;
      });
    }

    private void append_tagged_text(string text, Gtk.TextTag tag) {
      Gtk.TextIter text_end;
      buffer.get_end_iter(out text_end);
      buffer.insert_with_tags(text_end, text, text.length, tag);
    }
  }
}
