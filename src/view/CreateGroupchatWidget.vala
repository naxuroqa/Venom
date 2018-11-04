/*
 *    CreateGroupchatWidget.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/create_groupchat_widget.ui")]
  public class CreateGroupchatWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry title;
    [GtkChild] private Gtk.Button create;
    [GtkChild] private Gtk.Revealer title_error_content;
    [GtkChild] private Gtk.Label title_error;

    [GtkChild] private Gtk.ListBox conference_invites;
    [GtkChild] private Gtk.Box conference_invite_item;
    [GtkChild] private Gtk.Box placeholder;
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Widget custom_title;

    [GtkChild] private Gtk.Button accept_all;
    [GtkChild] private Gtk.Button reject_all;

    private Logger logger;
    private CreateGroupchatViewModel view_model;
    private ContainerChildBooleanBinding stack_binding;

    public CreateGroupchatWidget(Logger logger, ApplicationWindow app_window, ObservableList conference_invites_model, CreateGroupchatWidgetListener listener, ConferenceInviteEntryListener entry_listener) {
      logger.d("CreateGroupChatWidget created.");
      this.logger = logger;
      this.view_model = new CreateGroupchatViewModel(logger, conference_invites_model, listener, entry_listener);
      this.stack_binding = new ContainerChildBooleanBinding(stack, conference_invite_item, "needs-attention");

      app_window.reset_header_bar();
      app_window.header_bar.custom_title = custom_title;

      var conference_type_action = new GLib.SimpleAction.stateful("conference-type", view_model.conference_type.get_type(), view_model.conference_type);
      var action_group = new SimpleActionGroup();
      action_group.add_action(conference_type_action);
      insert_action_group("widget", action_group);

      title.bind_property("text", view_model, "title", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("title-error", title_error, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("title-error-visible", title_error_content, "reveal-child", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("new-conference-invite", stack_binding, "active", BindingFlags.SYNC_CREATE);
      view_model.bind_property("conference-type", conference_type_action, "state", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("accept-all-sensitive", reject_all, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("reject-all-sensitive", accept_all, "sensitive", GLib.BindingFlags.SYNC_CREATE);

      create.clicked.connect(view_model.on_create);
      accept_all.clicked.connect(view_model.on_accept_all);
      reject_all.clicked.connect(view_model.on_reject_all);

      if (view_model.new_conference_invite) {
        stack.set_visible_child(conference_invite_item);
      }

      var creator = new ConferenceInviteEntryCreator(logger, entry_listener);
      conference_invites.bind_model(view_model.get_list_model(), creator.create);
      conference_invites.set_placeholder(placeholder);
    }

    ~CreateGroupchatWidget() {
      logger.d("CreateGroupChatWidget destroyed.");
    }

    private class ConferenceInviteEntryCreator {
      private Logger logger;
      private ConferenceInviteEntryListener listener;
      public ConferenceInviteEntryCreator(Logger logger, ConferenceInviteEntryListener listener) {
        this.logger = logger;
        this.listener = listener;
      }

      public Gtk.Widget create(GLib.Object o) {
        return new ConferenceInviteEntry(logger, o as ConferenceInvite, listener);
      }
    }
  }
}
