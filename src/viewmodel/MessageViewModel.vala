/*
 *    MessageViewModel.vala
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
  public class MessageViewModel : GLib.Object {
    public bool additional_info_visible { get; set; }
    public string sender { get; set; }
    public bool sender_sensitive { get; set; }
    public Gdk.Pixbuf sender_image { get; set; }
    public string timestamp { get; set; }
    public string message { get; set; }
    public bool sent_visible { get; set; }
    public bool received_visible { get; set; }

    private ILogger logger;
    private IMessage message_content;

    public MessageViewModel(ILogger logger, IMessage message_content) {
      logger.d("MessageViewModel created.");
      this.logger = logger;
      this.message_content = message_content;

      message_content.message_changed.connect(on_message_changed);
      on_message_changed();
    }

    public void on_state_flags_changed(Gtk.StateFlags flag) {
      additional_info_visible = Gtk.StateFlags.PRELIGHT in flag || Gtk.StateFlags.SELECTED in flag;
    }

    private void on_message_changed() {
      if (message_content.message_direction == MessageDirection.OUTGOING) {
        received_visible = message_content.received;
        sent_visible = !message_content.received;

        sender = _("me");
        sender_sensitive = false;
      } else {
        sender = message_content.get_sender_plain();
      }

      message = message_content.get_message_plain();
      sender_image = message_content.get_sender_image();
      timestamp = message_content.get_time_plain();
    }

    ~MessageViewModel() {
      logger.d("MessageViewModel destroyed.");
    }
  }
}
