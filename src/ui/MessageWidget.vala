/*
 *    MessageWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/message_widget.ui")]
  public class MessageWidget : Gtk.ListBoxRow {
    [GtkChild]
    private Gtk.Label sender;
    [GtkChild]
    private Gtk.Image sender_image;
    [GtkChild]
    private Gtk.Label timestamp;
    [GtkChild]
    private Gtk.Label message;
    [GtkChild]
    private Gtk.Image sent;
    [GtkChild]
    private Gtk.Image received;
    [GtkChild]
    private Gtk.Box additional_info;

    private IMessage message_content;
    private ILogger logger;

    public MessageWidget(ILogger logger, IMessage message_content) {
      this.logger = logger;
      this.message_content = message_content;

      if (message_content.message_direction == MessageDirection.OUTGOING) {
        //TODO move this
        sender.label = "me";
        sender.sensitive = false;
        message_content.message_changed.connect(on_message_changed);
      } else {
        sender.label = message_content.get_sender_plain();
      }
      on_message_changed();

      sender_image.set_from_pixbuf(message_content.get_sender_image());
      timestamp.label = message_content.get_time_plain();
      message.label = message_content.get_message_plain();
      sender.activate_link.connect(on_activate_sender_link);

      state_flags_changed.connect(on_state_flags_changed);

      logger.d("MessageWidget created.");
    }

    private void on_state_flags_changed() {
      var flag = get_state_flags();
      additional_info.visible = Gtk.StateFlags.PRELIGHT in flag || Gtk.StateFlags.SELECTED in flag;
    }

    private void on_message_changed() {
      if (message_content.message_direction == MessageDirection.OUTGOING) {
        received.visible = message_content.received;
        sent.visible = !message_content.received;
      }
    }

    private bool on_activate_sender_link() {
      logger.d("on_activate_sender_link");
      return true;
    }

    ~MessageWidget() {
      logger.d("MessageWidget destroyed.");
    }
  }
}
