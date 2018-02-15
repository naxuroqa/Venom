/*
 *    ConferenceInfoWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/conference_info_widget.ui")]
  public class ConferenceInfoWidget : Gtk.Box {

    [GtkChild]
    private Gtk.Label title;

    [GtkChild]
    private Gtk.ListBox peers;

    [GtkChild]
    private Gtk.Button leave;

    private ILogger logger;
    private GroupchatContact contact;
    private unowned ApplicationWindow app_window;
    private ConferenceInfoWidgetListener listener;

    public ConferenceInfoWidget(ILogger logger, ApplicationWindow app_window, ConferenceInfoWidgetListener listener, IContact contact) {
      logger.d("ConferenceInfoWidget created.");
      this.logger = logger;
      this.contact = contact as GroupchatContact;
      this.app_window = app_window;
      this.listener = listener;

      set_info();

      leave.clicked.connect(on_leave_clicked);
    }

    private void set_info() {
      title.label = contact.title;
    }

    private void on_leave_clicked() {
      try {
        listener.on_remove_conference(contact);
      } catch (Error e) {
        logger.e("Could not remove conference: " + e.message);
        return;
      }
      app_window.show_welcome();
    }

    ~ConferenceInfoWidget() {
      logger.d("ConferenceInfoWidget destroyed.");
    }
  }

  public interface ConferenceInfoWidgetListener : GLib.Object {
    public abstract void on_remove_conference(IContact contact) throws Error;
  }
}
