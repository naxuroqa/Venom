/*
 *    AddContactWidget.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  [GtkTemplate(ui = "/im/tox/venom/ui/add_contact_widget.ui")]
  public class AddContactWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry contact_id;
    [GtkChild] private Gtk.TextView contact_message;
    [GtkChild] private Gtk.Button send;
    [GtkChild] private Gtk.Label contact_id_error;
    [GtkChild] private Gtk.Revealer contact_id_error_content;

    private ILogger logger;
    private AddContactWidgetListener listener;
    private AddContactViewModel view_model;

    public AddContactWidget(ILogger logger, AddContactWidgetListener listener) {
      logger.d("AddContactWidget created.");
      this.logger = logger;
      view_model = new AddContactViewModel(logger, listener);

      contact_id.bind_property("text", view_model, "contact-id", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      contact_message.buffer.bind_property("text", view_model, "contact-message", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("contact-id-error-message", contact_id_error, "label" , BindingFlags.SYNC_CREATE);
      view_model.bind_property("contact-id-error-visible", contact_id_error_content, "reveal-child", BindingFlags.SYNC_CREATE);

      contact_id.icon_release.connect(view_model.on_paste_clipboard);
      send.clicked.connect(view_model.on_send);
    }

    ~AddContactWidget() {
      logger.d("AddContactWidget destroyed.");
    }
  }
}
