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
    public string is_typing_string {get; set; default = "";}

    private Gtk.TextTag bold_tag;
    private Gtk.TextTag grey_tag;
    private Gtk.TextTag important_tag;
    private Gtk.TextTag italic_tag;
    private Gtk.TextTag quotation_tag;

    private bool is_typing_status = false;
    private Gtk.TextIter typing_status_iter;

    public ConversationTextView() {
      this.get_style_context().add_class("conversation_view");
      set_wrap_mode(Gtk.WrapMode.WORD_CHAR);
      editable = false;

      bold_tag = buffer.create_tag(null, "weight", 600);
      grey_tag = buffer.create_tag(null, "foreground", "grey");
      important_tag = buffer.create_tag(null,
        "weight", 600,
        "foreground", "white",
        "background", "darkgrey"
      );
      italic_tag = buffer.create_tag(null, "style", Pango.Style.ITALIC);
      quotation_tag = buffer.create_tag(null, "foreground", "green");
      key_press_event.connect((e) => {
        switch(e.keyval) {
          case Gdk.Key.Return:
          case Gdk.Key.KP_Enter:
            Gtk.TextIter iter;
            buffer.get_iter_at_mark(out iter, buffer.get_insert());
            activate_uri_at_iter(iter);
            break;
          default:
            break;
        }
        return false;
      });
      event_after.connect((e) => {
        if(e.type != Gdk.EventType.BUTTON_RELEASE)
          return;
        Gtk.TextIter start, end, iter;

        // Don't activate on selection
        buffer.get_selection_bounds(out start, out end);
        if(start.get_offset() != end.get_offset())
          return;
        int x, y;
        window_to_buffer_coords(Gtk.TextWindowType.WIDGET, (int)e.button.x, (int)e.button.y, out x, out y);
        get_iter_at_location(out iter, x, y);
        activate_uri_at_iter(iter);
      });
      bool hovering = false;
      Gdk.Cursor hand_cursor = new Gdk.Cursor(Gdk.CursorType.HAND1);
      Gdk.Cursor regular_cursor = new Gdk.Cursor(Gdk.CursorType.XTERM);
      motion_notify_event.connect((e)=> {
        int x, y;
        window_to_buffer_coords(Gtk.TextWindowType.WIDGET, (int)e.x, (int)e.y, out x, out y);
        Gtk.TextIter iter;
        get_iter_at_location(out iter, x, y);
        if(get_uri_at_iter(iter) != null) {
          if(!hovering) {
            hovering = true;
            this.get_window(Gtk.TextWindowType.TEXT).set_cursor(hand_cursor);
          }
        } else {
          if(hovering) {
            hovering = false;
            this.get_window(Gtk.TextWindowType.TEXT).set_cursor(regular_cursor);
          }
        }
        return false;
      });
      this.notify["is-typing-string"].connect(() => {
        remove_typing_status();
        append_typing_status();
      });
    }

    public void on_typing_changed(bool status) {
      if(status && !is_typing_status) {
        is_typing_status = status;
        append_typing_status();
      } else if (!status && is_typing_status) {
        remove_typing_status();
        is_typing_status = status;
      }
    }

    private void remove_typing_status() {
      if(!is_typing_status) {
        return;
      }
      Gtk.TextIter text_end;
      buffer.get_end_iter(out text_end);
      buffer.delete(ref typing_status_iter, ref text_end);
    }

    private void append_typing_status() {
      if(!is_typing_status) {
        return;
      }
      buffer.get_end_iter(out typing_status_iter);
      buffer.insert_with_tags(typing_status_iter, is_typing_string, is_typing_string.length, italic_tag);
      buffer.get_end_iter(out typing_status_iter);
      typing_status_iter.backward_chars(is_typing_string.length);
    }

    public void add_message(IMessage message) {
      remove_typing_status();

      Gtk.TextIter text_end;
      string text;
      buffer.get_end_iter(out text_end);
      text = _("[%s] ").printf(
        message.get_time_plain()
      );
      buffer.insert_with_tags(text_end, text, text.length, grey_tag);

      buffer.get_end_iter(out text_end);
      if(short_names) {
        text = Tools.shorten_name(message.get_sender_plain());
      } else {
        text = message.get_sender_plain();
      }

      if(message.important) {
        buffer.insert_with_tags(text_end, text, text.length, important_tag);
      } else {
        buffer.insert_with_tags(text_end, text, text.length, bold_tag);
      }

      buffer.get_end_iter(out text_end);
      text = ": ";
      buffer.insert_with_tags(text_end, text, text.length, bold_tag);

      buffer.get_end_iter(out text_end);
      text = message.get_message_plain();
      if (text[0] == '>') {
        buffer.insert_with_tags(text_end, text, text.length, quotation_tag);
      } else {
        GLib.MatchInfo match_info;
        Tools.uri_regex.match(text, 0, out match_info);
        int start = 0, end = 0, offset = 0;
        while(match_info.matches() && match_info.fetch_pos(0, out start, out end)) {
          // Add preceding text
          if(start > offset) {
            buffer.insert(ref text_end, text[offset:start], offset - start);
          }
          // Add uri
          string uri = match_info.fetch(0);
          insert_uri(text_end, uri);

          buffer.get_end_iter(out text_end);
          offset = end;

          try {
            match_info.next();
          } catch (GLib.RegexError e) {
            Logger.log(LogLevel.ERROR, "Error matching uri regex: " + e.message);
            break;
          }
        }
        // Add trailing text
        if(text.length > offset) {
          string after = text.substring(offset);
          buffer.insert(ref text_end, after, -1);
        }
      }

      buffer.get_end_iter(out text_end);
      buffer.insert(ref text_end, "\n", 1);

      append_typing_status();
    }

    public void add_filetransfer(FileTransferChatEntry entry) {
      remove_typing_status();

      Gtk.TextIter iter;
      buffer.get_end_iter(out iter);
      Gtk.TextChildAnchor child_anchor = buffer.create_child_anchor(iter);
      add_child_at_anchor(entry, child_anchor);
      entry.show();

      buffer.get_end_iter(out iter);
      buffer.insert(ref iter, "\n", 1);

      append_typing_status();
    }

    private void insert_uri(Gtk.TextIter iter, string uri) {
      Gtk.TextTag uri_tag;
      uri_tag = buffer.create_tag(null,
          "underline", Pango.Underline.SINGLE,
          "foreground", "blue"
      );
      uri_tag.set_data<string>("uri", uri);
      buffer.insert_with_tags(iter, uri, uri.length, uri_tag);
    }

    private string? get_uri_at_iter(Gtk.TextIter iter) {
      GLib.SList<unowned Gtk.TextTag> tags = iter.get_tags();
      for(unowned GLib.SList<unowned Gtk.TextTag> tagp = tags; tagp != null; tagp = tagp.next) {
        var tag = tagp.data;
        string uri = tag.get_data<string>("uri");
        if(uri != null) {
          return uri;
        }
      }
      return null;
    }

    private void activate_uri_at_iter(Gtk.TextIter iter) {
      string uri = get_uri_at_iter(iter);
      if(uri == null)
        return;
      try {
        Gtk.show_uri(null, uri, 0);
      } catch (Error e) {
        Logger.log(LogLevel.ERROR, "Error when showing uri: " + e.message);
      }
    }

    private bool forward_search(Gtk.TextIter iter, string text, Gtk.TextIter? limit = null, bool match_case = false) {
      Gtk.TextIter match_start;
      Gtk.TextIter match_end;
      bool found = iter.forward_search(text, match_case ? 0 : Gtk.TextSearchFlags.CASE_INSENSITIVE , out match_start, out match_end, limit);
      if(found) {
        scroll_to_iter(match_start, 0, false, 0, 0);
        buffer.select_range(match_start, match_end);
      }
      return found;
    }

    private void search(string search_text, bool wrap_around = true, bool match_case = false) {
      Gtk.TextIter current_position_iter;
      buffer.get_iter_at_mark(out current_position_iter,  buffer.get_insert());
      if(!forward_search(current_position_iter, search_text, null) && wrap_around) {
        Gtk.TextIter start_iter;
        buffer.get_start_iter(out start_iter);
        forward_search(start_iter, search_text, current_position_iter);
      }
    }
    
    public void register_search_entry(Gtk.Entry entry) {
      key_press_event.connect((k) => {
        if(k.keyval == Gdk.Key.f && (k.state & Gdk.ModifierType.CONTROL_MASK) != 0) {
          entry.show();
          entry.grab_focus();
          return true;
        }
        return false;
      });

      entry.key_press_event.connect((k) => {
        if(k.keyval == Gdk.Key.Escape) {
          entry.hide();
          grab_focus();
          return true;
        }
        return false;
      });

      bool match_case = false;
      bool wrap_around = true;

      bool hold_searchbar = false;

      entry.icon_release.connect((p0, p1) => {
        if(p1.button.button == 3) {
          hold_searchbar = true;
          Gtk.Menu menu = new Gtk.Menu();

          Gtk.CheckMenuItem menu_item_case = new Gtk.CheckMenuItem.with_mnemonic("_Match case");
          menu_item_case.active = match_case;
          menu_item_case.toggled.connect(() => { match_case = menu_item_case.active; });
          menu.append(menu_item_case);

          Gtk.CheckMenuItem menu_item_wrap = new Gtk.CheckMenuItem.with_mnemonic("_Wrap around");
          menu_item_wrap.active = wrap_around;
          menu_item_wrap.toggled.connect(() => { wrap_around = menu_item_wrap.active; });
          menu.append(menu_item_wrap);

          menu.show_all();
          menu.attach_to_widget(entry, null);
          menu.hide.connect(() => {hold_searchbar = false; menu.detach();});
          menu.popup(null, null, null, 0, 0);
        }
      });

      entry.focus_out_event.connect(() => {
        if(!hold_searchbar)
          entry.hide();
        return false;
      });

      entry.insert_text.connect( (new_text, new_text_length, ref position) => {
        search(entry.text + new_text, wrap_around, match_case);
      });
    }
  }
}
