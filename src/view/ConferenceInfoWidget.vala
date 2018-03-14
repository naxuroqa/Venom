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
  [GtkTemplate(ui = "/im/tox/venom/ui/conference_info_widget.ui")]
  public class ConferenceInfoWidget : Gtk.Box {

    [GtkChild] private Gtk.Entry title;
    [GtkChild] private Gtk.ListBox peers;
    [GtkChild] private Gtk.Button apply;
    [GtkChild] private Gtk.Button leave;
    [GtkChild] private Gtk.Revealer title_error_content;
    [GtkChild] private Gtk.Label title_error;

    private ILogger logger;
    private ConferenceInfoViewModel view_model;
    private unowned ApplicationWindow app_window;

    public ConferenceInfoWidget(ILogger logger, ApplicationWindow app_window, ConferenceInfoWidgetListener listener, IContact contact) {
      logger.d("ConferenceInfoWidget created.");
      this.logger = logger;
      this.app_window = app_window;
      this.view_model = new ConferenceInfoViewModel(logger, listener, contact as GroupchatContact);

      view_model.bind_property("title", title, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("title-error", title_error, "label", BindingFlags.SYNC_CREATE);
      view_model.bind_property("title-error-visible", title_error_content, "reveal-child", BindingFlags.SYNC_CREATE);

      peers.bind_model(view_model.get_list_model(), on_create_peer_widget);
      unmap.connect(() => { peers.bind_model(null, null); });

      apply.clicked.connect(view_model.on_apply_clicked);
      leave.clicked.connect(view_model.on_leave_clicked);

      view_model.leave_view.connect(leave_view);
    }

    private void leave_view() {
      app_window.show_welcome();
    }

    private Gtk.Widget on_create_peer_widget(Object o) {
      return new PeerEntry(logger, o as GroupchatPeer);
    }

    ~ConferenceInfoWidget() {
      logger.d("ConferenceInfoWidget destroyed.");
    }
  }
}
