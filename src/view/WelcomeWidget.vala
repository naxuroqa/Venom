/*
 *    WelcomeWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/welcome_widget.ui")]
  public class WelcomeWidget : Gtk.Box {
    private ILogger logger;

    [GtkChild]
    private Gtk.Button link_learn_more;

    [GtkChild]
    private Gtk.Button link_get_involved;

    public WelcomeWidget(ILogger logger) {
      logger.d("WelcomeWidget created.");
      this.logger = logger;

      link_learn_more.tooltip_text = R.constants.tox_about();
      link_learn_more.clicked.connect(on_learn_more_clicked);

      link_get_involved.tooltip_text = R.constants.tox_get_involved();
      link_get_involved.clicked.connect(on_get_involved_clicked);
    }

    private void try_show_uri(string uri) {
      try {
        Gtk.show_uri(null, uri, Gdk.CURRENT_TIME);
      } catch (Error e) {
        logger.d("Could not show uri: " + e.message);
      }
    }

    private void on_learn_more_clicked() {
      try_show_uri(R.constants.tox_about());
    }

    private void on_get_involved_clicked() {
      try_show_uri(R.constants.tox_get_involved());
    }

    ~WelcomeWidget() {
      logger.d("WelcomeWidget destroyed.");
    }
  }
}
