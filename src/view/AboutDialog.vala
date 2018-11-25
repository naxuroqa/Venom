/*
 *    AboutDialog.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  public class AboutDialog : Gtk.AboutDialog {
    private Logger logger;
    private Gtk.Box content_box;

    private Gtk.Stack stack;
    private Gtk.ToggleButton system_toggle;
    private Gtk.ToggleButton credits_toggle;

    public AboutDialog(Logger logger) {
      this.logger = logger;
      logger.d("AboutDialog created.");

      artists = {
        "ItsDuke <anondelivers.org@gmail.com>"
      };
      authors = {
        "naxuroqa <naxuroqa@gmail.com>",
        "John Poulakos <jhn1291@gmail.com>",
        "Denys Han <h.denys@gmail.com>",
        "Andrii Titov <concuror@gmail.com>",
        "notsecure <notsecure@marek.ca>",
        "Fukukami",
        "Mario Daniel Ruiz Saavedra <desiderantes@rocketmail.com>",
        "fshp <franchesko.salias.hudro.pedros@gmail.com>",
        "Bahkuh <philip_hq@hotmail.com>",
        "Joel Leclerc <lkjoel@ubuntu.com>",
        "infirit <infirit@gmail.com>",
        "Maxim Golubev <3demax@gmail.com>"
      };
      var packagers = new string[] {
        "Sean <sean@tox.im>"
      };
      add_credit_section(_("Packagers"), packagers);
      comments = _("A modern Tox client for the Linux desktop");
      copyright = _("Copyright © 2013-2018 Venom authors and contributors");
      license_type = Gtk.License.GPL_3_0;
      logo_icon_name = "venom-symbolic";
      program_name = "Venom";
      translator_credits = _("translator-credits");
      version = Config.VERSION;
      website = "https://github.com/naxuroqa/Venom";

      content_box = get_child_with_name(this, "dialog-vbox1") as Gtk.Box;
      var box = get_child_with_name(content_box, "box") as Gtk.Box;
      stack = get_child_with_name(box, "stack") as Gtk.Stack;
      var logo = get_child_with_name(box, "logo_image") as Gtk.Image;

      logo.get_style_context().add_class("welcome-highlight");

      var textview = new Gtk.TextView();
      textview.editable = false;
      textview.top_margin = textview.bottom_margin = textview.left_margin = textview.right_margin = 6;

      var buffer = textview.buffer;
      var builder = new TextBufferBuilder(buffer);
      var info = new SystemInformation();
      builder.append(info.to_string());

      Gtk.TextIter start, end;
      buffer.create_tag("small", "scale", Pango.Scale.SMALL);
      buffer.get_bounds(out start, out end);
      buffer.apply_tag_by_name("small", start, end);

      var scrolled_window = new Gtk.ScrolledWindow(null, null);
      scrolled_window.add(textview);
      scrolled_window.get_style_context().add_class("frame");
      scrolled_window.show_all();

      if (use_header_bar != (int) true) {
        var action_box = get_child_with_name(content_box, "action_box") as Gtk.Box;
        var action_area = get_child_with_name(action_box, "action_area") as Gtk.ButtonBox;
        system_toggle = new Gtk.ToggleButton.with_label(_("System"));

        foreach (var w in action_area.get_children()) {
          bool secondary;
          action_area.child_get(w, "secondary", out secondary);
          if (secondary && w is Gtk.ToggleButton) {
            credits_toggle = (Gtk.ToggleButton) w;
            break;
          }
        }
        var id = GLib.Signal.lookup("toggled", typeof(Gtk.ToggleButton));
        GLib.SignalHandler.disconnect_matched(credits_toggle, GLib.SignalMatchType.ID | GLib.SignalMatchType.DATA, id, 0, null, null, this);

        system_toggle.toggled.connect(toggle_system);
        credits_toggle.toggled.connect(toggle_credits);

        system_toggle.show_all();
        action_area.add(system_toggle);
        action_area.child_set(system_toggle, "secondary", true);
        stack.notify["visible-child-name"].connect(update_buttons);
      }

      stack.add_titled(scrolled_window, "system", _("System"));
    }

    private void update_buttons() {
      system_toggle.active = stack.visible_child_name == "system";
      credits_toggle.active = stack.visible_child_name == "credits";
    }
    private void toggle_credits() {
      if (credits_toggle.active) {
        stack.visible_child_name = "credits";
      } else if (system_toggle.active) {
        stack.visible_child_name = "system";
      } else {
        stack.visible_child_name = "main";
      }
    }

    private void toggle_system() {
      if (system_toggle.active) {
        stack.visible_child_name = "system";
      } else if (credits_toggle.active) {
        stack.visible_child_name = "credits";
      } else {
        stack.visible_child_name = "main";
      }
    }

    private unowned Gtk.Widget? get_child_with_name(unowned Gtk.Widget parent, string name) {
      var parent_container = parent as Gtk.Container;
      if (parent_container != null) {
        var children = parent_container.get_children();
        foreach (var w in children) {
          if (w.get_name() == name) {
            return w;
          }
        }
      }
      return null;
    }

    ~AboutDialog() {
      logger.d("AboutDialog destroyed.");
    }
    private class TextBufferBuilder {
      private Gtk.TextBuffer buffer;
      private Gtk.TextIter iter;
      public TextBufferBuilder(Gtk.TextBuffer buffer) {
        this.buffer = buffer;
        buffer.get_end_iter(out iter);
      }
      public void append(string str) {
        buffer.insert(ref iter, str, -1);
      }
    }
  }

  public class SystemInformation : GLib.Object {
    public string desktop_environment { get; set; }
    public string language { get; set; }
    public string os_name { get; set; }
    public string os_arch { get; set; }
    public string build_version_venom { get; set; }
    public string build_version_glib { get; set; }
    public string build_version_gtk { get; set; }
    public string build_version_canberra { get; set; }
    public string build_version_tox { get; set; }
    public string runtime_version_glib { get; set; }
    public string runtime_version_gtk { get; set; }
    public string runtime_version_tox { get; set; }

    public SystemInformation() {
      desktop_environment = GLib.Environment.get_variable("XDG_CURRENT_DESKTOP");
      language = GLib.Environment.get_variable("LANG");
      string? buf;
      try {
        GLib.FileUtils.get_contents("/etc/os-release", out buf, null);
        os_name = string_between(buf, "PRETTY_NAME=\"", "\"");
      } catch (Error e) {
        info("Could not read /etc/os-release: " + e.message);
        os_name = _("Unknown");
      }
      os_arch = sizeof(void*) == 8 ? "64-bit" : "32-bit";
      build_version_venom = Config.VERSION;
      build_version_glib = @"$(GLib.Version.MAJOR).$(GLib.Version.MINOR).$(GLib.Version.MICRO)";
      build_version_gtk = @"$(Gtk.MAJOR_VERSION).$(Gtk.MINOR_VERSION).$(Gtk.MICRO_VERSION)";
      build_version_canberra = @"$(Canberra.MAJOR).$(Canberra.MINOR)";
      build_version_tox = @"$(ToxCore.Version.MAJOR).$(ToxCore.Version.MINOR).$(ToxCore.Version.PATCH)";
      runtime_version_glib = @"$(GLib.Version.major).$(GLib.Version.minor).$(GLib.Version.micro)";
      runtime_version_gtk = @"$(Gtk.get_major_version()).$(Gtk.get_minor_version()).$(Gtk.get_micro_version())";
      runtime_version_tox = @"$(ToxCore.Version.major()).$(ToxCore.Version.minor()).$(ToxCore.Version.patch())";
    }

    private string? string_between(string haystack, string needle1, string needle2) {
      var start = haystack.index_of(needle1);
      if (start == -1) {
        return null;
      }
      start += needle1.length;
      var end = haystack.index_of(needle2, start);
      if (end == -1) {
        return null;
      }
      return haystack.substring(start, end - start);
    }

    public string to_string() {
      var builder = new StringBuilder();
      if (desktop_environment != null) {
        builder.append(_("Desktop Environment: ") + desktop_environment + "\n");
      }
      if (os_name != null) {
        builder.append(_("Operating System: ") + os_name + "\n");
      }
      if (os_arch != null) {
        builder.append(_("Architecture: " + os_arch + "\n"));
      }
      if (language != null) {
        builder.append(_("Language: ") + language + "\n");
      }
      builder.append("\n" + _("Build information:") + "\n");
      builder.append("Venom:\t\t" + build_version_venom + "\n");
      builder.append("GLib:\t\t" + build_version_glib + "\n");
      builder.append("GTK+:\t\t" + build_version_gtk + "\n");
      builder.append("libcanberra:\t" + build_version_canberra + "\n");
      builder.append("libtoxcore:\t" + build_version_tox + "\n");

      builder.append("\n" + _("Runtime information:") + "\n");
      builder.append("GLib:\t\t" + runtime_version_glib + "\n");
      builder.append("GTK+:\t\t" + runtime_version_gtk + "\n");
      builder.append("libtoxcore:\t" + runtime_version_tox);
      return builder.str;
    }
  }
}
