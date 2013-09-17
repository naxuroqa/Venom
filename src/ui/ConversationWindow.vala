/*
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
  public class ConversationWindow : Object {
    private Gtk.Window conversation_window;
    private Gtk.Label label_conversation_partner;
    private Gtk.Image image_conversation_partner;
    private ConversationTreeView conversation_tree_view;
    private unowned Contact conversation_contact;

    private signal void new_conversation_message(Message message);
    public signal void new_outgoing_message(string message, Contact receiver);

    public ConversationWindow(
        Contact c,
        Gtk.Window conversation_window,
        Gtk.ScrolledWindow scrolled_window,
        Gtk.Label label_conversation_partner,
        Gtk.Image image_conversation_partner) {
      this.conversation_contact = c;
      this.conversation_window = conversation_window;
      this.label_conversation_partner = label_conversation_partner;
      this.image_conversation_partner = image_conversation_partner;

      conversation_window.delete_event.connect(() => {conversation_window.hide(); return true;});

      label_conversation_partner.set_text("Conversation with %s".printf(c.name));

      conversation_tree_view = new ConversationTreeView();
      conversation_tree_view.show_all();
      scrolled_window.add(conversation_tree_view);
      //box.pack_start(conversation_tree_view);

      new_conversation_message.connect(conversation_tree_view.add_message);
    }

    public static ConversationWindow create( Contact c ) throws Error {
      Gtk.Builder builder = new Gtk.Builder();
      builder.add_from_file(Path.build_filename(Tools.find_data_dir(), "ui", "conversation_window.glade"));
      Gtk.Window window = builder.get_object("window") as Gtk.Window;
      Gtk.ScrolledWindow scrolledwindow = builder.get_object("scrolledwindow") as Gtk.ScrolledWindow;
      Gtk.Label label_conversation_partner = builder.get_object("label_conversation_partner") as Gtk.Label;
      Gtk.Image image_conversation_partner = builder.get_object("image_conversation_partner") as Gtk.Image;
      ConversationWindow conversation_window = new ConversationWindow(c, window, scrolledwindow, label_conversation_partner, image_conversation_partner);
      builder.connect_signals(conversation_window);
      return conversation_window;
    }

    public void on_incoming_message(Message message) {
      if(message.sender != conversation_contact)
        return;
      new_conversation_message(message);
    }

    public void show_all() {
      conversation_window.show_all();
    }

    [CCode (instance_pos = -1)]
    public void entry_activate(Gtk.Entry source) {
      string s = source.text;
      Message m = new Message(null, s);
      new_conversation_message(m);
      new_outgoing_message(s, conversation_contact);
      source.text = "";
    }
  }
}
