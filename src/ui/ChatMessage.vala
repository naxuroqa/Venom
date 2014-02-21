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
    public Message message;
    public GroupMessage groupmessage;

    private Gtk.Label name_label;
    private Gtk.Label message_label;
    private Gtk.Label date_label;
    private Gtk.Frame frame;

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/chat_message.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading message widget failed!\n");
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

    public ChatMessage.private(Message message, bool following = false){
      this.message = message;
      init_widgets();

      if(!following) {
        frame.get_style_context().add_class("first");
        if(message.from.public_key == null) {
          name_label.get_style_context().add_class("own_name");
        }
        name_label.set_text( Tools.shorten_name( message.from.name ) );
      } else {
        name_label.set_text("");
      }
      message_label.set_text( message.message );
      date_label.set_text( message.timestamp.format("%R") );
    }
    
    public ChatMessage.own(Message message, string own_name, bool following = false){
      this.message = message;

      init_widgets();
      if(!following) {
        frame.get_style_context().add_class("first");
        if(message.from == null) {
          name_label.get_style_context().add_class("own_name");
        }
        name_label.set_text( Tools.shorten_name( own_name ) );
      } else {
        name_label.set_text("");
      }

      message_label.set_text( message.message );
      date_label.set_text( message.timestamp.format("%R") );
    }

    public ChatMessage.group(GroupMessage message, bool following = false){
      this.groupmessage = message;
    
      init_widgets();
      if(!following) {
        frame.get_style_context().add_class("first");
        if(message.from.public_key == null) {
          name_label.get_style_context().add_class("own_name");
        }
        name_label.set_text( Tools.shorten_name( message.from_name ) );
      } else {
        name_label.set_text("");
      }
    
      message_label.set_text( message.message );
      date_label.set_text( message.timestamp.format("%R") );
    }
  }
}
