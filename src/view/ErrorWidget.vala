/*
 *    ErrorWidget.vala
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/error_widget.ui")]
  public class ErrorWidget : Gtk.Box {
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Label message;
    [GtkChild] private Gtk.Button retry;

    public signal void on_retry();

    public ErrorWidget(Gtk.ApplicationWindow application_window, string error_message) {
      message.label = error_message;
      retry.clicked.connect(() => { on_retry(); });
    }

    public void add_page(Gtk.Widget widget, string name, string title) {
      var scrolled_window = new Gtk.ScrolledWindow(null, null);
      scrolled_window.add(widget);
      stack.add_titled(scrolled_window, name, title);
    }
  }
}
