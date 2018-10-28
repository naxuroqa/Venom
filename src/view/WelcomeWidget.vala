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

    public WelcomeWidget(ILogger logger, ApplicationWindow app_window) {
      logger.d("WelcomeWidget created.");
      this.logger = logger;

      var provider = new OctoberWelcomeContentProvider(new DateTime.now_local(),
                     new DefaultWelcomeContentProvider(null));

      var titles = provider.append_titles(new Gee.ArrayList<string>());
      var contents = provider.append_contents(new Gee.ArrayList<string>());
      var images = provider.append_images(new Gee.ArrayList<string>());
      var style_classes = provider.append_style_classes(new Gee.ArrayList<string>());

      app_window.reset_header_bar();
      app_window.header_bar.title = "Venom";
      app_window.header_bar.subtitle = titles.@get(rand.int_range(0, titles.size));

      title.set_markup(pango_big(titles.@get(rand.int_range(0, titles.size))));
      content.set_markup(pango_small(contents.@get(rand.int_range(0, contents.size))));
      image.icon_name = images.@get(rand.int_range(0, images.size));
      image.get_style_context().add_class(style_classes.@get(rand.int_range(0, style_classes.size)));

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

  public abstract class WelcomeContentProvider {
    protected WelcomeContentProvider? successor;

    public virtual Gee.List<string> append_style_classes(Gee.List<string> content) {
      if (successor != null) {
        return successor.append_style_classes(content);
      }
      return content;
    }

    public virtual Gee.List<string> append_titles(Gee.List<string> content) {
      if (successor != null) {
        return successor.append_titles(content);
      }
      return content;
    }

    public virtual Gee.List<string> append_images(Gee.List<string> content) {
      if (successor != null) {
        return successor.append_images(content);
      }
      return content;
    }

    public virtual Gee.List<string> append_contents(Gee.List<string> content) {
      if (successor != null) {
        return successor.append_contents(content);
      }
      return content;
    }
  }

  public class DefaultWelcomeContentProvider : WelcomeContentProvider {
    private string[] style_classes = {
      "welcome-highlight"
    };

    private string[] titles = {
      _("A new kind of instant messaging")
    };

    private string[] images = {
      "venom-symbolic"
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

    public DefaultWelcomeContentProvider(WelcomeContentProvider? successor) {
      this.successor = successor;
    }

    public override Gee.List<string> append_style_classes(Gee.List<string> content) {
      content.add_all_array(style_classes);
      return base.append_style_classes(content);
    }

    public override Gee.List<string> append_titles(Gee.List<string> content) {
      content.add_all_array(titles);
      return base.append_titles(content);
    }

    public override Gee.List<string> append_images(Gee.List<string> content) {
      content.add_all_array(images);
      return base.append_images(content);
    }

    public override Gee.List<string> append_contents(Gee.List<string> content) {
      content.add_all_array(contents);
      return base.append_contents(content);
    }
  }

  public class OctoberWelcomeContentProvider : WelcomeContentProvider {
    private DateTime date;
    public OctoberWelcomeContentProvider(GLib.DateTime date, WelcomeContentProvider? successor) {
      this.date = date;
      this.successor = successor;
    }

    private string[] style_classes = {
      "welcome-hover",
      "welcome-drop-in"
    };

    private string[] images = {
      "pumpkin"
    };

    private string[] contents = {
      _("Drink your milk for extra strong bones.")
    };

    bool isOctober() {
      return date.get_month() == GLib.DateMonth.OCTOBER;
    }

    public override Gee.List<string> append_style_classes(Gee.List<string> content) {
      if (isOctober()) {
        content.add_all_array(style_classes);
      }
      return base.append_style_classes(content);
    }

    public override Gee.List<string> append_images(Gee.List<string> content) {
      if (isOctober()) {
        content.add_all_array(images);
      }
      return base.append_images(content);
    }

    public override Gee.List<string> append_contents(Gee.List<string> content) {
      if (isOctober()) {
        content.add_all_array(contents);
      }
      return base.append_contents(content);
    }
  }
}
