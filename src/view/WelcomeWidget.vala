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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/welcome_widget.ui")]
  public class WelcomeWidget : Gtk.Box {
    private ILogger logger;
    private GLib.Rand rand = new GLib.Rand();

    [GtkChild] private Gtk.Button link_learn_more;
    [GtkChild] private Gtk.Button link_get_involved;
    [GtkChild] private Gtk.Image image;
    [GtkChild] private Gtk.Label title;
    [GtkChild] private Gtk.Label content;

    private string[] titles = {
      _("A new kind of instant messaging")
    };

    private string[] contents = {
      _("Chat with your friends and family without anyone else listening in."),
      _("Now with 50% less bugs."),
      _("Generating witty dialog…"),
      _("Thank you for using Venom."),
      _("Always think positive."),
      _("Have a good day and stay safe."),
      _("You can do it. ― Coffee"),
      _("Life moves pretty fast. If you don’t stop and look around once in a while, you could miss it. ― Ferris Bueller")
    };

    public WelcomeWidget(ILogger logger, ApplicationWindow app_window) {
      logger.d("WelcomeWidget created.");
      this.logger = logger;

      app_window.reset_header_bar();
      app_window.header_bar.title = "Venom";
      app_window.header_bar.subtitle = titles[rand.int_range(0, titles.length)];

      title.set_markup(pango_big(titles[rand.int_range(0, titles.length)]));
      content.set_markup(pango_small(contents[rand.int_range(0, contents.length)]));

      link_learn_more.tooltip_text = R.constants.tox_about();
      link_get_involved.tooltip_text = R.constants.tox_get_involved();

      link_learn_more.clicked.connect(on_learn_more_clicked);
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

    private string pango_big(string text) {
      return @"<big>$text</big>";
    }

    private string pango_small(string text) {
      return @"<small>$text</small>";
    }

    ~WelcomeWidget() {
      logger.d("WelcomeWidget destroyed.");
    }
  }
}
