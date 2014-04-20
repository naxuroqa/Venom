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
  public class ChatMessage : Gtk.Box {
    private Gtk.Label name_label;
    private Gtk.Label message_label;
    private Gtk.Label date_label;

    public ChatMessage(IMessage message, bool short_names, bool following){
      init_widgets();

      if( message.is_action ) {
        name_label.set_text( message.get_sender_plain() );
      } else if(!following) {
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
      string markup_message_text = Tools.markup_uris(message.get_message_plain());
      message_label.set_markup( markup_message_text );
      date_label.set_text( message.get_time_plain() );
    }

    private void init_widgets() {
      this.get_style_context().add_class("message_entry");
      this.spacing = 12;
      this.margin_left = 12;
      this.margin_right = 12;
      name_label = new Gtk.Label(null);
      name_label.set_alignment(1,0);
      message_label = new Gtk.Label(null);
      message_label.wrap_mode = Pango.WrapMode.WORD_CHAR;
      message_label.wrap = true;
      message_label.selectable = true;
      message_label.set_alignment(0,0);
      date_label = new Gtk.Label(null);
      date_label.get_style_context().add_class("date_label");
      date_label.set_alignment(0,0);
      this.pack_start(name_label, false);
      this.pack_start(message_label, false);
      this.pack_end(date_label, false);
    }
  }
}
