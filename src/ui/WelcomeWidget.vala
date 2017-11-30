/*
 *    WelcomeWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/welcome_widget.ui")]
  public class WelcomeWidget : Gtk.Box {
    private ILogger logger;

    [GtkChild]
    private Gtk.Button link;

    public WelcomeWidget(ILogger logger) {
      logger.d("WelcomeWidget created.");
      this.logger = logger;

      link.tooltip_text = R.constants.tox_about();
      link.clicked.connect(on_link_clicked);
    }

    private void on_link_clicked() {
      Gtk.show_uri(null, R.constants.tox_about(), Gdk.CURRENT_TIME);
    }

    ~WelcomeWidget() {
      logger.d("WelcomeWidget destroyed.");
    }
  }
}
