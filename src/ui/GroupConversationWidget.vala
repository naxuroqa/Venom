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
    private EditableLabel label_groupchat_name;
    private Gtk.Label label_groupchat_statusmessage;
    private Gtk.Image image_groupchat_image;

    private MessageTextView message_textview;

    private IConversationView conversation_view;
    private IGroupConversationSidebar group_conversation_sidebar;

    private unowned GroupChat groupchat {get; private set;}

    public signal void new_outgoing_message(GroupMessage message);
    public signal void new_outgoing_action(GroupActionMessage action);
    public signal void groupchat_changed(GroupChat g);

    public GroupConversationWidget( GroupChat groupchat ) {
      this.groupchat = groupchat;
      init_widgets();
      update_groupchat_info();
    }

    public void update_groupchat_info() {
      // update groupchat name
      label_groupchat_name.label.label = "<b>%s</b>".printf(groupchat.get_name_string_with_hyperlinks());

      // update groupchat status message
      label_groupchat_statusmessage.label = groupchat.get_status_string_with_hyperlinks();

      // update groupchat image
      image_groupchat_image.set_from_pixbuf(groupchat.image != null ? groupchat.image : ResourceFactory.instance.default_groupchat);
    }

    public void update_contact(int peernumber, Tox.ChatChange change) {
      if(change == Tox.ChatChange.PEER_ADD || change == Tox.ChatChange.PEER_DEL) {
        update_groupchat_info();
      }
      // update sidebar
      group_conversation_sidebar.update_contact(peernumber, change);
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
      label_groupchat_statusmessage = builder.get_object("label_contact_statusmessage") as Gtk.Label;
      image_groupchat_image = builder.get_object("image_contact_image") as Gtk.Image;

      Gtk.Image image_send = builder.get_object("image_send") as Gtk.Image;
      Gtk.Image image_call = builder.get_object("image_call") as Gtk.Image;
      Gtk.Image image_call_video = builder.get_object("image_call_video") as Gtk.Image;
      Gtk.Image image_send_file = builder.get_object("image_send_file") as Gtk.Image;
      Gtk.Image image_insert_smiley = builder.get_object("image_insert_smiley") as Gtk.Image;

      Gtk.Label label_groupchat_name_ = builder.get_object("label_contact_name") as Gtk.Label;
      Gtk.Box box_user_info = builder.get_object("box_user_info") as Gtk.Box;
      box_user_info.remove(label_groupchat_name_);
      label_groupchat_name = new EditableLabel.with_label(label_groupchat_name_);
      box_user_info.pack_start(label_groupchat_name, false);
      label_groupchat_name.button_cancel.get_style_context().add_class("callbutton");
      label_groupchat_name.button_ok.get_style_context().add_class("callbutton");
      label_groupchat_name.show_all();
      label_groupchat_name.show_entry.connect_after(() => {
        label_groupchat_name.entry.text = groupchat.local_name;
      });
      label_groupchat_name.label_changed.connect((new_name) => {
        groupchat.local_name = new_name;
        groupchat_changed(groupchat);
      });

      //TODO
      //Gtk.Button button_call = builder.get_object("button_call") as Gtk.Button;
      //Gtk.Button button_call_video = builder.get_object("button_call_video") as Gtk.Button;
      Gtk.Button button_send = builder.get_object("button_send") as Gtk.Button;
      //Gtk.Button button_send_file = builder.get_object("button_send_file") as Gtk.Button;

      //button_send_file.clicked.connect(button_send_file_clicked);

      Gtk.Paned paned_sidebar = builder.get_object("paned_sidebar") as Gtk.Paned;
      Gtk.ScrolledWindow sidebar_scrolled_window = new Gtk.ScrolledWindow(null, null);
      group_conversation_sidebar = new GroupConversationSidebar(groupchat);
      sidebar_scrolled_window.add(group_conversation_sidebar);
      sidebar_scrolled_window.show_all();
      paned_sidebar.pack2(sidebar_scrolled_window, false, true);

      Gtk.ScrolledWindow scrolled_window_message = builder.get_object("scrolled_window_message") as Gtk.ScrolledWindow;
      message_textview = new MessageTextView();
      message_textview.border_width = 6;
      message_textview.wrap_mode = Gtk.WrapMode.WORD_CHAR;
      message_textview.textview_activate.connect(textview_activate);
      message_textview.completion_column = GroupConversationSidebar.TreeModelColumn.NAME;
      message_textview.completion_model = group_conversation_sidebar.model;
      scrolled_window_message.add(message_textview);

      button_send.clicked.connect(textview_activate);

      image_send.set_from_pixbuf(ResourceFactory.instance.send);
      image_call.set_from_pixbuf(ResourceFactory.instance.call);
      image_call_video.set_from_pixbuf(ResourceFactory.instance.call_video);
      image_send_file.set_from_pixbuf(ResourceFactory.instance.send_file);
      image_insert_smiley.set_from_pixbuf(ResourceFactory.instance.smiley);

      Gtk.ScrolledWindow scrolled_window = builder.get_object("scrolled_window") as Gtk.ScrolledWindow;

      if( ResourceFactory.instance.textview_mode ) {
        conversation_view = new ConversationTextView();
        scrolled_window.add(conversation_view);
      } else {
        conversation_view = new ConversationView();
        scrolled_window.add_with_viewport(conversation_view);
      }
      conversation_view.get_style_context().add_class("chat_list");
      conversation_view.short_names = false;

      Gtk.Overlay overlay = builder.get_object("overlay") as Gtk.Overlay;
      Gtk.Entry entry_search = new SearchEntry();
      entry_search.halign = Gtk.Align.END;
      entry_search.valign = Gtk.Align.START;
      entry_search.no_show_all = true;
      conversation_view.register_search_entry(entry_search);
      overlay.add_overlay(entry_search);

      Gtk.Adjustment vadjustment = scrolled_window.get_vadjustment();
      bool scroll_to_bottom = true;
      conversation_view.size_allocate.connect( () => {
        if(scroll_to_bottom) {
          vadjustment.value = vadjustment.upper - vadjustment.page_size;
        }
      });
      vadjustment.value_changed.connect( () => {
        scroll_to_bottom = (vadjustment.value == vadjustment.upper - vadjustment.page_size);
      });

      delete_event.connect(hide_on_delete);
    }

    public void on_incoming_message(GroupMessage message) {
      if(message.from != groupchat)
        return;

      conversation_view.add_message(message);
    }

    public void textview_activate() {
      string s = message_textview.buffer.text;
      if(s == "" || message_textview.placeholder_visible)
        return;
      GLib.MatchInfo info = null;
      if(Tools.action_regex.match(s, 0, out info) && info.fetch_named("action_name") == "me") {
        string action_string = info.fetch_named("action_string");
        if(action_string == null) {
          action_string = "";
        }
        GroupActionMessage a = new GroupActionMessage.outgoing(groupchat, action_string);
        new_outgoing_action(a);
      } else {
        GroupMessage m = new GroupMessage.outgoing(groupchat, s);
        new_outgoing_message(m);
      }
      message_textview.buffer.text = "";
    }
  }
}
