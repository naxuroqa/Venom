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
    public signal void typing_status(bool typing);

    public string placeholder_text { get; set; default = "Type your message here..."; }
    public Gtk.TextTag placeholder_tag { get; set; }

    private Gtk.TreeModel _completion_model;
    public Gtk.TreeModel completion_model {
      get {
        return _completion_model;
      } set {
        _completion_model = value;
        completion_filtered = new Gtk.TreeModelFilter(_completion_model, null);
        completion_filtered.set_visible_func(visible_function);
      }
    }
    public int completion_column { get; set; }

    private bool is_typing = false;
    private bool placeholder_visible = true;
    private Gtk.TreeModelFilter completion_filtered;
    private string filter_string;

    public MessageTextView() {
      /** Placeholder **/
      placeholder_tag = buffer.create_tag(null, "foreground", "grey");
      append_tagged_text(placeholder_text, placeholder_tag);

      /** Events **/
      key_press_event.connect(on_key_press);

      focus_in_event.connect(() => {
        if(placeholder_visible) {
          placeholder_visible = false;
          buffer.text = "";
        }
        return false;
      });

      focus_out_event.connect(() => {
        if(buffer.text == "") {
          placeholder_visible = true;
          append_tagged_text(placeholder_text, placeholder_tag);
        } else {
          placeholder_visible = false;
        }
        return false;
      });

      buffer.changed.connect( () => {
        if(placeholder_visible || buffer.text == "") {
          if(is_typing) {
            is_typing = false;
            typing_status(is_typing);
          }
        } else {
          if(!is_typing) {
            is_typing = true;
            typing_status(is_typing);
          }
        }
      });
    }

    private bool visible_function(Gtk.TreeModel model, Gtk.TreeIter iter) {
      string str;
      model.get(iter, completion_column, out str, -1);
      return (str != null && filter_string != null && str.has_prefix(filter_string));
    }

    private bool on_key_press(Gdk.EventKey event) {
      // only catch return if shift or control keys are not pressed
      if(event.keyval == Gdk.Key.Return && (event.state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK)) == 0) {
        textview_activate();
        return true;
      } else if(event.keyval == Gdk.Key.Tab) {
        if(completion_model == null) {
          // behave as the default textview
          return false;
        }

        Gtk.TextMark ohaimark = buffer.get_insert();
        Gtk.TextIter iter_end;
        buffer.get_iter_at_mark(out iter_end, ohaimark);

        if(!iter_end.ends_word()) {
          return true;
        }

        Gtk.TextIter iter_start = iter_end;
        iter_start.backward_word_start();

        filter_string = iter_start.get_text(iter_end);
        completion_filtered.refilter();

        Gtk.TreeIter filter_iter;
        if( completion_filtered.get_iter_first(out filter_iter) ) {
          string completed_string;
          completion_filtered.get(filter_iter, completion_column, out completed_string, -1);
          buffer.delete(ref iter_start, ref iter_end);
          buffer.insert(ref iter_start, completed_string, completed_string.length);
        }
        return true;
      }
      return false;
    }

    private void append_tagged_text(string text, Gtk.TextTag tag) {
      Gtk.TextIter text_end;
      buffer.get_end_iter(out text_end);
      buffer.insert_with_tags(text_end, text, text.length, tag);
    }
  }
}
