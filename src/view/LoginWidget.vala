/*
 *    LoginWidget.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/login_widget.ui")]
  public class LoginWidget : Gtk.ApplicationWindow {
    private Logger logger;
    private ContextStyleBinding accounts_arrow_binding;
    private Profile selected_profile;

    [GtkChild] private Gtk.Widget login_page;
    [GtkChild] private Gtk.Button login_button;
    [GtkChild] private Gtk.Entry login_password_entry;
    [GtkChild] private Gtk.ToggleButton accounts_toggle;
    [GtkChild] private Gtk.Revealer accounts_revealer;
    [GtkChild] private Gtk.Image accounts_arrow;
    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.ListBox profiles_listbox;

    [GtkChild] private Gtk.Label selected_profile_label;
    [GtkChild] private Gtk.Stack login_password_stack;

    [GtkChild] private Gtk.Entry create_username;
    [GtkChild] private Gtk.Revealer create_username_revealer;
    [GtkChild] private Gtk.Label create_username_error;

    [GtkChild] private Gtk.Entry create_password;
    [GtkChild] private Gtk.Revealer create_password_revealer;
    [GtkChild] private Gtk.Label create_password_error;

    [GtkChild] private Gtk.Entry create_password_repeat;
    [GtkChild] private Gtk.Revealer create_password_repeat_revealer;
    [GtkChild] private Gtk.Label create_password_repeat_error;

    [GtkChild] private Gtk.Widget create_page;
    [GtkChild] private Gtk.Button create_button;

    public LoginWidget(Gtk.Application application, Logger logger) {
      Object(application: application);
      logger.d("LoginWidget created.");
      this.logger = logger;

      var path = R.constants.default_profile_dir();
      var profiles = Profile.scan_profiles(logger, path);
      update_profiles_list(profiles);
      var it = profiles.iterator();
      if (it.next()) {
        set_selected_profile(it.@get());
      } else {
        login_page.visible = false;
      }

      accounts_toggle.bind_property("active", accounts_revealer, "reveal_child", GLib.BindingFlags.SYNC_CREATE);
      accounts_arrow_binding = new ContextStyleBinding(accounts_arrow, "flip");
      accounts_toggle.bind_property("active", accounts_arrow_binding, "enable", GLib.BindingFlags.SYNC_CREATE);

      stack.set_focus_child.connect(on_set_focus_child);
      login_button.clicked.connect(login);
      create_button.clicked.connect(create);

      create_username.notify["is-focus"].connect(() => {
        if (!create_username.is_focus) {
          is_create_username_valid();
        }
      });
      create_password.notify["is-focus"].connect(() => {
        if (!create_password.is_focus) {
          is_create_password_valid();
        }
      });
      create_password_repeat.notify["is-focus"].connect(() => {
        if (!create_password_repeat.is_focus) {
          is_create_password_repeat_valid();
        }
      });

      profiles_listbox.row_selected.connect(on_login_row_selected);
    }

    private void on_login_row_selected(Gtk.ListBoxRow? row) {
      logger.d("on_login_row_selected");
      if (row != null) {
        var entry = (ProfileEntry) row;
        set_selected_profile(entry.profile);
      }
    }

    private void set_selected_profile(Profile profile) {
      selected_profile = profile;
      selected_profile_label.label = profile.name;
      if (profile.is_encrypted) {
        login_password_stack.visible_child_name = "pass";
      } else {
        login_password_stack.visible_child_name = "auto";
      }
    }

    private void update_profiles_list(Gee.Iterable<Profile> profiles) {
      profiles_listbox.foreach ((element) => profiles_listbox.remove(element));
      var first = true;
      foreach (var profile in profiles) {
        var row = new ProfileEntry(logger, profile);
        profiles_listbox.add(row);
        if (first) {
          first = false;
          profiles_listbox.select_row(row);
        }
      }
    }

    private void on_set_focus_child(Gtk.Widget? child) {
      if (child == login_page) {
        login_button.grab_default();
      } else if (child == create_page) {
        create_button.grab_default();
      }
    }

    private void login() {
      logger.d("login clicked");

      try {
        if (selected_profile.is_encrypted) {
          selected_profile.load(login_password_entry.text);
        }

        var app = GLib.Application.get_default() as Application;
        app.try_show_main_window(selected_profile);
      } catch (Error e) {
        logger.e("Cannot load profile: " + e.message);
        login_password_entry.secondary_icon_name = "dialog-error-symbolic";
        login_password_entry.secondary_icon_tooltip_text = _("Wrong password");
      }
    }

    private bool is_create_username_valid() {
      if (create_username.text == "") {
        create_username_error.label = _("Username can not be empty");
      } else if (!Profile.is_username_available(R.constants.default_profile_dir(), create_username.text)) {
        create_username_error.label = _("Username is already taken");
      } else {
        create_username_revealer.reveal_child = false;
        create_username.secondary_icon_name = "emblem-ok-symbolic";
        return true;
      }

      create_username.secondary_icon_name = "";
      create_username_revealer.reveal_child = true;
      return false;
    }

    private bool is_create_password_valid() {
      if (create_password.text.length > 0 && create_password.text.length < 6) {
        create_password_error.label = _("Password must be at least 6 characters long");
        create_password_revealer.reveal_child = true;
        create_password.secondary_icon_name = "";
        return false;
      }

      create_password.secondary_icon_name = "emblem-ok-symbolic";
      create_password_revealer.reveal_child = false;
      return true;
    }

    private bool is_create_password_repeat_valid() {
      if (create_password.text != create_password_repeat.text) {
        create_password_repeat_error.label = _("Passwords must match");
        create_password_repeat_revealer.reveal_child = true;
        create_password_repeat.secondary_icon_name = "";
        return false;
      }

      create_password_repeat.secondary_icon_name = "emblem-ok-symbolic";
      create_password_repeat_revealer.reveal_child = false;
      return true;
    }

    private void create() {
      logger.d("create clicked");

      if (is_create_username_valid() && is_create_password_valid() && is_create_password_repeat_valid()) {
        try {
          var profile = Profile.create(R.constants.default_profile_dir(), create_username.text, create_password.text);

          var app = GLib.Application.get_default() as Application;
          app.try_show_main_window(profile);
        } catch (Error e) {
          create_username_error.label = _("Creating profile failed: ") + e.message;
          create_username_revealer.reveal_child = true;
        }
      }
    }

    ~LoginWidget() {
      logger.d("LoginWidget destroyed.");
    }

    private class ProfileEntry : Gtk.ListBoxRow {
      private Logger logger;
      public Profile profile;

      public ProfileEntry(Logger logger, Profile profile) {
        this.logger = logger;
        this.profile = profile;

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 6);
        box.pack_start(new Gtk.Image.from_icon_name("avatar-default-symbolic", Gtk.IconSize.BUTTON), false, false);
        box.pack_start(new Gtk.Label(profile.name), false, false);
        if (profile.is_encrypted) {
          var image = new Gtk.Image.from_icon_name("security-high-symbolic", Gtk.IconSize.BUTTON);
          image.tooltip_text = _("Profile is encrypted");
          box.pack_end(image, false, false);
        }
        box.border_width = 6;
        add(box);
        show_all();
      }
    }
  }
}
