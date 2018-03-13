/*
 *    AddContactViewModel.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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
  public class AddContactViewModel : GLib.Object {
    public string contact_id { get; set; }
    public string contact_message { get; set; }
    public bool contact_id_error_visible { get; set; }
    public string contact_id_error_message { get; set; }

    private ILogger logger;
    private AddContactWidgetListener listener;

    public AddContactViewModel(ILogger logger, AddContactWidgetListener listener) {
      logger.d("AddContactViewModel created.");
      this.logger = logger;
      this.listener = listener;

      this.notify["contact-id"].connect(() => { contact_id_error_visible = false; });
    }

    public void on_send() {
      try {
        listener.on_send_friend_request(contact_id, contact_message);
      } catch (Error e) {
        contact_id_error_message = "Could not add contact: " + e.message;
        contact_id_error_visible = true;
        logger.e(contact_id_error_message);
        return;
      }
    }

    public void on_paste_clipboard() {
      var clipboard = Gtk.Clipboard.@get(Gdk.SELECTION_CLIPBOARD);
      contact_id = clipboard.wait_for_text() ?? "";
    }

    ~AddContactViewModel() {
      logger.d("AddContactViewModel destroyed.");
    }
  }

  public interface AddContactWidgetListener : GLib.Object {
    public abstract void on_send_friend_request(string id, string message) throws Error;
  }
}
