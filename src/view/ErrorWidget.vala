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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/error_widget.ui")]
  public class ErrorWidget : Gtk.ApplicationWindow {
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.Label message;
    [GtkChild] private Gtk.Button retry;
    [GtkChild] private Gtk.TextView log_view;

    public signal void on_retry();

    private Logger logger;

    public ErrorWidget(Gtk.Application application, Logger logger, string error_message) {
      Object(application: application);

      this.logger = logger;
      message.label = error_message;
      retry.clicked.connect(() => { on_retry(); });

      Gtk.TextIter iter;
      log_view.buffer.get_start_iter(out iter);
      log_view.buffer.insert_markup(ref iter, logger.get_log(), -1);
    }

    public void add_page(Gtk.Widget widget, string name, string title) {
      var scrolled_window = new Gtk.ScrolledWindow(null, null);
      scrolled_window.get_style_context().add_class("frame");
      scrolled_window.add(widget);
      stack.add_titled(scrolled_window, name, title);
      scrolled_window.show_all();
    }
  }
}
