/*
 *    Copyright (C) 2013 Venom authors and contributors
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
  public class ChatMessage : Gtk.EventBox {
    private Gtk.Label name_label;
    private Gtk.Label message_label;
    private Gtk.Label date_label;
    private Gtk.Frame frame;
    private static GLib.Regex regex_uri = null;

    public ChatMessage(IMessage message, bool short_names, bool following){
      init_widgets();

      if(!following) {
        frame.get_style_context().add_class("first");
        if(message.message_direction == MessageDirection.OUTGOING) {
          name_label.get_style_context().add_class("own_name");
        }
        if(short_names) {
          name_label.set_text( Tools.shorten_name( message.get_sender_plain() ) );
        } else {
          name_label.set_text( message.get_sender_plain() );
        }
      } else {
        name_label.set_text("");
      }
      string markup_message_text = markup_uris(Markup.escape_text(message.get_message_plain()));
      message_label.set_markup( markup_message_text );
      date_label.set_text( message.timestamp.format("%R") );
    }

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/chat_message.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading message widget failed: %s\n", e.message);
      }
      this.get_style_context().add_class("message_entry");

      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      frame = new Gtk.Frame(null);
      frame.get_style_context().add_class("message_frame");
      frame.set_visible(true);
      frame.add(box);
      this.add(frame);
      name_label = builder.get_object("name_label") as Gtk.Label;
      name_label.get_style_context().add_class("name_label");
      message_label = builder.get_object("message_label") as Gtk.Label;
      message_label.set_line_wrap(true);
      date_label = builder.get_object("date_label") as Gtk.Label;      
      this.set_visible(true);

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

  }
}
