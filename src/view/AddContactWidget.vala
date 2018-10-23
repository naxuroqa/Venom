/*
 *    AddContactWidget.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/add_contact_widget.ui")]
  public class AddContactWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry contact_id;
    [GtkChild] private Gtk.TextView contact_message;
    [GtkChild] private Gtk.Button send;
    [GtkChild] private Gtk.Label contact_id_error;
    [GtkChild] private Gtk.Revealer contact_id_error_content;
    [GtkChild] private Gtk.Stack contact_image_stack;
    [GtkChild] private Gtk.Image contact_image;
    [GtkChild] private Gtk.Box placeholder;
    [GtkChild] private Gtk.ListBox friend_requests;

    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Box friend_request_item;
    [GtkChild] private Gtk.Widget custom_title;

    private ILogger logger;
    private AddContactViewModel view_model;
    private ContainerChildBooleanBinding stack_binding;
    private StackIndexTransform contact_image_stack_transform;

    public AddContactWidget(ILogger logger, ApplicationWindow app_window, ObservableList friend_requests_model, AddContactWidgetListener listener, FriendRequestWidgetListener friend_request_listener) {
      logger.d("AddContactWidget created.");
      this.logger = logger;
      view_model = new AddContactViewModel(logger, friend_requests_model, listener);
      stack_binding = new ContainerChildBooleanBinding(stack, friend_request_item, "needs-attention");
      contact_image_stack_transform = new StackIndexTransform(contact_image_stack);

      app_window.reset_header_bar();
      app_window.header_bar.custom_title = custom_title;

      contact_id.bind_property("text", view_model, "contact-id", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      contact_message.buffer.bind_property("text", view_model, "contact-message", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("contact-id-error-message", contact_id_error, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-id-error-visible", contact_id_error_content, "reveal-child", BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-image-visible", contact_image_stack, "visible-child-name", BindingFlags.SYNC_CREATE,
                               contact_image_stack_transform.transform_boolean);
      view_model.bind_property("contact-image", contact_image, "pixbuf", BindingFlags.SYNC_CREATE);
      view_model.bind_property("new-friend-request", stack_binding, "active", BindingFlags.SYNC_CREATE);

      friend_requests.set_placeholder(placeholder);
      var creator = new FriendRequestWidgetCreator(logger, friend_request_listener);
      friend_requests.bind_model(view_model.get_list_model(), creator.create);

      contact_id.icon_release.connect(view_model.on_paste_clipboard);
      send.clicked.connect(view_model.on_send);

      if (view_model.new_friend_request) {
        stack.set_visible_child(friend_request_item);
      }
    }

    ~AddContactWidget() {
      logger.d("AddContactWidget destroyed.");
    }

    public class FriendRequestWidgetCreator {
      private unowned ILogger logger;
      private FriendRequestWidgetListener listener;
      public FriendRequestWidgetCreator(ILogger logger, FriendRequestWidgetListener listener) {
        this.logger = logger;
        this.listener = listener;
      }

      public Gtk.Widget create(GLib.Object o) {
        return new FriendRequestWidget(logger, o as FriendRequest, listener);
      }
    }
  }
}
