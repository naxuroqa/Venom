/*
 *    AddContactWidget.vala
 *
 *    Copyright (C) 2013-2017  Venom authors and contributors
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
    [GtkChild]
    private Gtk.Entry contact_id;
    [GtkChild]
    private Gtk.TextView contact_message;
    [GtkChild]
    private Gtk.Button send;

    private ILogger logger;
    private AddContactWidgetListener listener;

    public AddContactWidget(ILogger logger, AddContactWidgetListener listener) {
      logger.d("AddContactWidget created.");
      this.logger = logger;
      this.listener = listener;

      contact_id.icon_release.connect(on_paste_clipboard);
      send.clicked.connect(on_send);
    }

    private void on_send() {
      logger.d("on_send");
      if (listener == null) {
        return;
      }
      try {
        listener.on_send_friend_request(contact_id.text, contact_message.buffer.text);
      } catch (Error e) {
        logger.e("Could not add contact: " + e.message);
        return;
      }
      logger.d("on_send_successful");
    }

    ~AddContactWidget() {
      logger.d("AddContactWidget destroyed.");
    }

    private void on_paste_clipboard() {
      var clipboard = Gtk.Clipboard.@get(Gdk.SELECTION_CLIPBOARD);
      var text = clipboard.wait_for_text();
      if (text == null) {
        logger.d("clipboard.wait_for_text returned null, probably empty.");
        return;
      }
      contact_id.set_text(text);
    }
  }

  public interface AddContactWidgetListener : GLib.Object {
    public abstract void on_send_friend_request(string id, string message) throws Error;
  }
}
