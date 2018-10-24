/*
 *    ConferenceInfoWidget.vala
 *
 *    Copyright (C) 2018 Venom authors and contributors
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/conference_info_widget.ui")]
  public class ConferenceInfoWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry title;
    [GtkChild] private Gtk.ListBox peers;
    [GtkChild] private Gtk.Button apply;
    [GtkChild] private Gtk.Button leave;
    [GtkChild] private Gtk.Revealer title_error_content;
    [GtkChild] private Gtk.Label title_error;
    [GtkChild] private Gtk.Switch show_notifications;
    [GtkChild] private Gtk.Box notifications_box;
    [GtkChild] private Gtk.Revealer notifications_notice;

    private ILogger logger;
    private ConferenceInfoViewModel view_model;
    private unowned ApplicationWindow app_window;

    public ConferenceInfoWidget(ILogger logger, ApplicationWindow app_window, ConferenceInfoWidgetListener listener, IContact contact, ISettingsDatabase settings_database) {
      logger.d("ConferenceInfoWidget created.");
      this.logger = logger;
      this.app_window = app_window;
      this.view_model = new ConferenceInfoViewModel(logger, listener, contact as Conference);

      app_window.reset_header_bar();
      view_model.bind_property("title", app_window.header_bar, "title", BindingFlags.SYNC_CREATE);

      view_model.bind_property("title", title, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("title-error", title_error, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("title-error-visible", title_error_content, "reveal-child", BindingFlags.SYNC_CREATE);
      view_model.bind_property("show-notifications", show_notifications, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settings_database.bind_property("enable-urgency-notification", notifications_box, "sensitive", BindingFlags.SYNC_CREATE);
      settings_database.bind_property("enable-urgency-notification", notifications_notice, "reveal-child", BindingFlags.SYNC_CREATE | BindingFlags.INVERT_BOOLEAN);

      var creator = new ConferencePeerWidgetCreator(logger);
      peers.bind_model(view_model.get_list_model(), creator.create_peer_widget);

      apply.clicked.connect(view_model.on_apply_clicked);
      leave.clicked.connect(view_model.on_leave_clicked);

      view_model.leave_view.connect(leave_view);
    }

    private void leave_view() {
      app_window.show_welcome();
    }

    ~ConferenceInfoWidget() {
      logger.d("ConferenceInfoWidget destroyed.");
    }

    private class ConferencePeerWidgetCreator {
      private unowned ILogger logger;
      public ConferencePeerWidgetCreator(ILogger logger) {
        this.logger = logger;
      }
      public Gtk.Widget create_peer_widget(Object o) {
        return new PeerEntry(logger, o as ConferencePeer);
      }
    }
  }
}
