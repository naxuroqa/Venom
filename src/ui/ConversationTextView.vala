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
    private Gtk.TextTag quotation_tag;
    private Gtk.TextTag uri_tag;

    public ConversationTextView() {
      set_wrap_mode(Gtk.WrapMode.WORD_CHAR);
      editable = false;

      bold_tag = buffer.create_tag(null, "weight", 600);
      grey_tag = buffer.create_tag(null, "foreground", "grey");
      quotation_tag = buffer.create_tag(null, "foreground", "green");
      uri_tag = buffer.create_tag(null,
          "underline", Pango.Underline.SINGLE,
          "foreground", "blue"
      );
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
      text = message.get_message_plain();
      if (text[0] == '>') {
        buffer.insert_with_tags(text_end, text, text.length, quotation_tag);
      } else {
        GLib.MatchInfo match_info;
        Tools.uri_regex.match(text, 0, out match_info);
        int offset = 0;
        int start = 0, end = 0;
        while(match_info.matches() && match_info.fetch_pos(0, out start, out end)) {
          string before = text.substring(offset, start);
          string uri = match_info.fetch(0);
          buffer.insert(ref text_end, before, before.length);
          buffer.insert_with_tags(text_end, uri, uri.length, uri_tag);
          buffer.get_end_iter(out text_end);
          offset = end;

          try {
            match_info.next();
          } catch (GLib.RegexError e) {
            stderr.printf("Error matching uri regex: %s\n", e.message);
            break;
          }
        }
        string after = text.substring(offset);
        buffer.insert(ref text_end, after, after.length);
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
    private bool forward_search(Gtk.TextIter iter, string text, Gtk.TextIter? limit = null, bool match_case = false) {
      Gtk.TextIter match_start;
      Gtk.TextIter match_end;
      bool found = iter.forward_search(text, match_case ? Gtk.TextSearchFlags.CASE_INSENSITIVE : 0 , out match_start, out match_end, limit);
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
