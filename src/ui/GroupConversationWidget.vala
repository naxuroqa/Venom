/*
 *    GroupConversationWidget.vala
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
  public class GroupConversationWidget : Gtk.EventBox {
    private Gtk.Label label_groupchat_name;
    private Gtk.Label label_groupchat_statusmessage;
    private Gtk.Image image_groupchat_image;

    private IConversationView conversation_view;
    private unowned GroupChat groupchat {get; private set;}

    public signal void new_outgoing_message(GroupMessage message);
    public signal void new_outgoing_action(GroupActionMessage action);

    public GroupConversationWidget( GroupChat groupchat ) {
      this.groupchat = groupchat;
      init_widgets();
      update_contact();
    }

    public void update_contact() {
      // update groupchat name
      label_groupchat_name.set_text("Groupchat #%i".printf(groupchat.group_id));

      // update groupchat status message
      label_groupchat_statusmessage.set_text("%i persons connected".printf(groupchat.peer_count));

      // update groupchat image
      image_groupchat_image.set_from_pixbuf(groupchat.image != null ? groupchat.image : ResourceFactory.instance.default_groupchat);
    }

    private void init_widgets() {
      Gtk.Builder builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/org/gtk/venom/conversation_window.ui");
      } catch (GLib.Error e) {
        stderr.printf("Loading conversation window failed!\n");
      }
      Gtk.Box box = builder.get_object("box") as Gtk.Box;
      this.add(box);
      this.get_style_context().add_class("conversation_widget");

      label_groupchat_name = builder.get_object("label_contact_name") as Gtk.Label;
      label_groupchat_statusmessage = builder.get_object("label_contact_statusmessage") as Gtk.Label;
      image_groupchat_image = builder.get_object("image_contact_image") as Gtk.Image;

      Gtk.Button button_call = builder.get_object("button_call") as Gtk.Button;
      Gtk.Button button_call_video = builder.get_object("button_call_video") as Gtk.Button;
      Gtk.Button button_send_file = builder.get_object("button_send_file") as Gtk.Button;

      button_call.destroy();
      button_call_video.destroy();
      button_send_file.destroy();

      Gtk.Entry entry_message = builder.get_object("entry_message") as Gtk.Entry;
      entry_message.activate.connect(entry_activate);

      Gtk.ScrolledWindow scrolled_window = builder.get_object("scrolled_window") as Gtk.ScrolledWindow;

      if( ResourceFactory.instance.textview_mode ) {
        conversation_view = new TextConversationView();
      } else {
        conversation_view = new ConversationView();
      }
      conversation_view.show_all();
      scrolled_window.add(conversation_view);

      //TODO: move to bottom only when wanted
      conversation_view.size_allocate.connect( () => {
        Gtk.Adjustment adjustment = scrolled_window.get_vadjustment();
        adjustment.set_value(adjustment.upper - adjustment.page_size);
      });

      delete_event.connect(() => {hide(); return true;});
    }
/*
    //history
    public void load_history(GLib.List<Message> messages) {
      messages.foreach((message) => {
        conversation_view.add_message(message);
        });
    }*/

    public void on_incoming_message(GroupMessage message) {
      if(message.from != groupchat)
        return;

      conversation_view.add_message(message);
    }

    public void entry_activate(Gtk.Entry source) {
      string s = source.text;
      if(s == "")
        return;
      GLib.MatchInfo info = null;
      if(Tools.action_regex.match(s, 0, out info)) {
        string action_string = info.fetch_named("action_string");
        GroupActionMessage a = new GroupActionMessage.outgoing(groupchat, action_string);
        new_outgoing_action(a);
      } else {
        GroupMessage m = new GroupMessage.outgoing(groupchat, s);
        new_outgoing_message(m);
      }
      source.text = "";
    }
  }
}
