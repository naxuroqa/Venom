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
  public class ConversationView : Gtk.EventBox {
    private static GLib.Regex regex_uri = null;
    private const int h_margin = 6;
    private const int v_margin = 6;
    private Gtk.Grid grid;
    private int bottom_row = 1;

    public ConversationView() {
      grid = new Gtk.Grid();
      grid.set_row_spacing(v_margin);
      grid.set_column_spacing(h_margin);
      this.add(grid);
    }

    private string markup_uris(string text) {
      string ret;
      try {
        if(regex_uri == null) {
          regex_uri = new GLib.Regex("(?<u>[a-z]\\S*://\\S*)");
        }
        ret = regex_uri.replace(text, -1, 0, "<a href=\"\\g<u>\">\\g<u></a>");
		  } catch (GLib.RegexError e) {
			  stderr.printf("Error when doing uri markup: %s", e.message);
			  return text;
		  }
		  return ret;
    }

    public void add_message(IMessage message) {
      Gtk.Label label_name = new Gtk.Label( null );
      Gtk.Label label_message = new Gtk.Label( null );
      Gtk.Label label_time = new Gtk.Label( null );

      label_name.set_markup(message.get_sender_markup());
      label_message.set_markup(markup_uris(message.get_message_markup()));
      label_time.set_markup(message.get_time_markup());

      label_name.xalign = 0;
      label_message.xalign = 0;
      label_time.xalign = 1;

      label_name.yalign = 0;
      label_message.yalign = 0;
      label_time.yalign = 0;

      label_name.margin_left = h_margin;
      label_time.margin_right = h_margin;

      label_message.selectable = true;
      label_message.set_ellipsize(Pango.EllipsizeMode.NONE);
      label_message.set_line_wrap(true);
      label_message.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);

      //FIXME have the same cursor for the whole ConversationView if possible
      label_message.hexpand = true;

      grid.attach(label_name, 0, bottom_row++, 1, 1);
      grid.attach_next_to(label_message, label_name, Gtk.PositionType.RIGHT, 1, 1);
      grid.attach_next_to(label_time, label_message, Gtk.PositionType.RIGHT, 1, 1);

      label_name.show();
      label_message.show();
      label_time.show();
    }
  }
}
