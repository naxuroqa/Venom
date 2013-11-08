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
  public class ConversationWindow : Gtk.Window {
    private Gtk.Label label_contact_name;
    private Gtk.Label label_contact_statusmessage;
    private Gtk.Image image_contact_image;
    
    private Gtk.Image image_call;
    private Gtk.Image image_call_video;
    
    private Gtk.Button button_call;
    private Gtk.Button button_call_video;
    
    private Gtk.Entry entry_message;
    private Gtk.ScrolledWindow scrolled_window;
    
    private ConversationTreeView conversation_tree_view;
    public unowned Contact contact {get; private set;}

    private signal void new_conversation_message(Message message);
    public signal void new_outgoing_message(string message, Contact receiver);

    public ConversationWindow( Contact contact ) {
      this.contact = contact;
      init_widgets();

      delete_event.connect(() => {hide(); return true;});
      
      update_contact();
      
      image_contact_image.set_from_pixbuf(contact.image != null ? contact.image : ResourceFactory.instance.default_contact);
      image_call.set_from_pixbuf(ResourceFactory.instance.call);
      image_call_video.set_from_pixbuf(ResourceFactory.instance.call_video);

      new_conversation_message.connect(conversation_tree_view.add_message);
      
      set_default_size(600, 500);
      update_title();
    }
    
    private void update_title() {
      this.set_title("Conversation with %s".printf(
        (contact.name != null && contact.name != "") ? 
          contact.name : 
          "unnamed contact"));
    }
    
    public void update_contact() {
      if(contact.name == null || contact.name == "")
        label_contact_name.set_text(Tools.bin_to_hexstring(contact.public_key));
      else
        label_contact_name.set_text(contact.name);
      label_contact_statusmessage.set_text(contact.status_message);
      update_title();
    }
    
    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "conversation_window.glade"));
      } catch (GLib.Error e) {
        stderr.printf("Loading conversation window failed!\n");
      }
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.add(box);

      label_contact_name = builder.get_object("label_contact_name") as Gtk.Label;
      label_contact_statusmessage = builder.get_object("label_contact_statusmessage") as Gtk.Label;
      image_contact_image = builder.get_object("image_contact_image") as Gtk.Image;
      
      image_call = builder.get_object("image_call") as Gtk.Image;
      image_call_video = builder.get_object("image_call_video") as Gtk.Image;
      
      button_call = builder.get_object("button_call") as Gtk.Button;
      button_call_video = builder.get_object("button_call_video") as Gtk.Button;
      
      entry_message = builder.get_object("entry_message") as Gtk.Entry;
      entry_message.activate.connect(entry_activate);

      scrolled_window = builder.get_object("scrolled_window") as Gtk.ScrolledWindow;
      
      conversation_tree_view = new ConversationTreeView();
      conversation_tree_view.show_all();
      scrolled_window.add(conversation_tree_view);

      //TODO: move to bottom only when wanted
      conversation_tree_view.size_allocate.connect( () => {
        Gtk.Adjustment adjustment = scrolled_window.get_vadjustment();
        adjustment.set_value(adjustment.upper - adjustment.page_size);
      });
      
      set_property("name", "conversation");
    }

    public void on_incoming_message(Message message) {
      if(message.sender != contact)
        return;

      new_conversation_message(message);
    }

    public void entry_activate(Gtk.Entry source) {
      string s = source.text;
      Message m = new Message(null, s);
      new_conversation_message(m);
      new_outgoing_message(s, contact);
      source.text = "";
    }
  }
}
