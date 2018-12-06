/*
 *    Application.vala
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
  public class Application : Gtk.Application {
    private const GLib.ActionEntry app_entries[] = {
      { "preferences", on_show_preferences, null, null, null },
      { "about", on_show_about, null, null, null },
      { "quit", on_quit, null, null, null },
      { "logout", on_logout, null, null, null },
      { "show-filetransfers", on_show_filetransfers, null, null, null },
      { "show-conferences", on_show_conferences, null, null, null },
      { "show-add-contact", on_show_add_contact, null, null, null },
      { "show-contact", on_show_contact, "s", null, null },
      { "show-contact-info", on_show_contact_info, "s", null, null },
      { "mute-contact", on_mute_contact, "s", null, null },
      { "accept-call", on_accept_call, "s", null, null },
      { "reject-call", on_reject_call, "s", null, null }
    };

    private const OptionEntry[] option_entries = {
      { "loglevel", 'l', 0, OptionArg.INT, ref loglevel, N_("Set level of messages to log"), N_("<loglevel>") },
      { "version", 'V', 0, OptionArg.NONE, null, N_("Display version number"), null },
      { "preferences", 'p', 0, OptionArg.NONE, null, N_("Show preferences"), null },
      { null }
    };

    private static LogLevel loglevel = LogLevel.INFO;

    private Database database;
    private Logger logger;
    private ToxSession session;
    private DhtNodeRepository node_database;
    private ISettingsDatabase settings_database;
    private ContactRepository contact_repository;
    private FriendRequestRepository friend_request_repository;
    private NospamRepository nospam_repository;
    private MessageRepository message_repository;
    private Factory.WidgetFactory widget_factory;
    private DatabaseFactory database_factory;
    private GlobalSettings global_settings;

    public Application() {
      Object(
        application_id: R.constants.app_id(),
        flags: ApplicationFlags.HANDLES_OPEN | ApplicationFlags.HANDLES_COMMAND_LINE
        );
      add_main_option_entries(option_entries);
      add_action_entries(app_entries, this);
    }

    private Gtk.ApplicationWindow create_application_window(Profile profile) throws Error {
      return widget_factory.create_application_window(this, session, profile, nospam_repository, friend_request_repository, message_repository, node_database, settings_database, contact_repository);
    }

    private Gtk.ApplicationWindow create_error_window(string error_message) {
      var err_widget = new ErrorWidget(this, logger, error_message);
      err_widget.add_page(widget_factory.create_settings_widget(null, settings_database, node_database), "settings", _("Settings"));

      err_widget.on_retry.connect(() => {
        err_widget.destroy();
        settings_database.save();
        try_show_app_window();
      });
      return err_widget;
    }

    private static void create_path_for_filename(string filename) throws Error {
      var path = GLib.File.new_for_path(GLib.Path.get_dirname(filename));
      if (!path.query_exists()) {
        path.make_directory_with_parents();
      }
    }

    protected override void startup() {
      base.startup();

#if ENABLE_POSIX
      Posix.signal(Posix.Signal.INT, on_sig_int);
      Posix.signal(Posix.Signal.TERM, on_sig_int);
#endif

      CommandLineLogger.displayed_level = loglevel;
      widget_factory = new Factory.DefaultWidgetFactory();
      logger = widget_factory.create_logger();

      var screen = Gdk.Screen.get_default();
      var css_provider = new Gtk.CssProvider();
      css_provider.load_from_resource("/com/github/naxuroqa/venom/css/custom.css");
      Gtk.StyleContext.add_provider_for_screen(screen, css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

      load_global_settings();
    }

    protected override void shutdown() {
      var window = get_active_window();
      if (window != null) {
        window.destroy();
        window = null;
      }

      save_global_settings();

      widget_factory = null;

      if (settings_database != null) {
        settings_database.save();
      }

      settings_database = null;
      contact_repository = null;
      node_database = null;
      nospam_repository = null;
      friend_request_repository = null;
      message_repository = null;
      database = null;

      base.shutdown();
    }

    private void try_show_app_window() {
      var window = get_active_window() as Gtk.ApplicationWindow;
      if (window != null) {
        window.present();
        return;
      }

      if (global_settings.auto_login && global_settings.last_used_profile.length > 0) {
        var profile = new Profile(R.constants.default_profile_dir(), global_settings.last_used_profile);
        if (profile.is_sane() && !profile.test_is_encrypted()) {
          try_show_main_window(profile);
          return;
        } else {
          logger.i("Auto login set, but profile either does not exist or is encrypted");
        }
      }

      window = new LoginWidget(this, global_settings, logger);
      window.present();
    }

    public void try_show_main_window(Profile profile) {
      var window = get_active_window() as Gtk.ApplicationWindow;
      database_factory = widget_factory.create_database_factory();
      try {
        var db_file = profile.dbfile;
        create_path_for_filename(db_file);
        database = database_factory.create_database(db_file, profile.get_db_key());
        var statement_factory = database_factory.create_statement_factory(database);
        node_database = database_factory.create_node_repository(statement_factory, logger);
        contact_repository = database_factory.create_contact_repository(statement_factory, logger);
        friend_request_repository = database_factory.create_friend_request_repository(statement_factory, logger);
        nospam_repository = database_factory.create_nospam_repository(statement_factory, logger);
        message_repository = database_factory.create_message_repository(statement_factory, logger);
        settings_database = database_factory.create_settings_database(statement_factory, logger);
        settings_database.load();

        if (session == null) {
          session = new ToxSessionImpl(profile, node_database, settings_database, logger);
        }

        if (window != null) {
          window.destroy();
        }

        create_application_window(profile).present();
      } catch (Error e) {
        create_error_window(e.message).present();
      }
    }

    protected override void activate() {
      hold();
      try_show_app_window();
      release();
    }

    public override int command_line(GLib.ApplicationCommandLine command_line) {
      if (command_line.get_options_dict().contains("preferences")) {
        on_show_preferences();
        return 0;
      }

      activate();
      return 0;
    }

    protected override int handle_local_options(GLib.VariantDict options) {
      if (options.contains("version")) {
        stdout.printf("%s %s\n", Environment.get_application_name(), Config.VERSION);
        return 0;
      }

      return -1;
    }

    protected override void open(GLib.File[] files, string hint) {
      logger.f("not implemented.");
    }

    private void load_global_settings() {
      try {
        var settings_string = FileIO.load_contents_text(R.constants.default_global_settings());
        global_settings = GlobalSettings.deserialize(settings_string);
      } catch (Error e) {
        logger.i("Loading global settings failed: " + e.message);
        global_settings = new GlobalSettings();
      }
    }

    private void save_global_settings() {
      try {
        var settings_string = GlobalSettings.serialize(global_settings);
        var filename = R.constants.default_global_settings();
        create_path_for_filename(filename);
        FileIO.save_contents_text(filename, settings_string);
      } catch (Error e) {
        logger.e("Saving global settings failed: " + e.message);
      }
    }

    private delegate void AppWindowDelegate(ApplicationWindow win);

    private void on_active_window(AppWindowDelegate run) {
      var active_window = get_active_window() as ApplicationWindow;
      if (active_window != null) {
        run(active_window);
      }
    }

    private void on_show_preferences() {
      logger.d("on_show_preferences");
      activate();
      on_active_window((win) => win.show_settings());
    }

    private void on_logout() {
      logger.d("on_logout");
      global_settings.auto_login = false;
      var active_window = get_active_window() as ApplicationWindow;
      if (active_window != null) {
        active_window.destroy();
        active_window = null;

        widget_factory = new Factory.DefaultWidgetFactory();

        if (settings_database != null) {
          settings_database.save();
        }

        settings_database = null;
        contact_repository = null;
        node_database = null;
        nospam_repository = null;
        friend_request_repository = null;
        message_repository = null;
        database = null;
        session = null;

        Gtk.Settings.get_default().gtk_application_prefer_dark_theme = false;
        try_show_app_window();
      }
    }

    public void on_show_about() {
      logger.d("on_show_about");
      var about_dialog = widget_factory.create_about_dialog();
      about_dialog.transient_for = get_active_window() as ApplicationWindow;
      about_dialog.run();
      about_dialog.destroy();
    }

    public void on_show_contact(GLib.SimpleAction action, GLib.Variant? parameter) {
      logger.d("on_show_contact");
      activate();
      if (parameter == null || parameter.get_string() == "") {
        return;
      }
      on_active_window((win) => win.on_show_contact(parameter.get_string()));
    }

    public void on_mute_contact(GLib.SimpleAction action, GLib.Variant? parameter) {
      logger.d("on_mute_contact");
      if (parameter == null || parameter.get_string() == "") {
        return;
      }
      on_active_window((win) => win.on_mute_contact(parameter.get_string()));
    }

    public void on_show_contact_info(GLib.SimpleAction action, GLib.Variant? parameter) {
      logger.d("on_show_contact_info");
      activate();
      if (parameter == null || parameter.get_string() == "") {
        return;
      }
      on_active_window((win) => win.on_show_contact_info(parameter.get_string()));
    }

    public void on_accept_call(GLib.SimpleAction action, GLib.Variant? parameter) {
      logger.d("on_accept_call");
      activate();
      if (parameter == null || parameter.get_string() == "") {
        return;
      }
      on_active_window((win) => win.on_accept_call(parameter.get_string()));
    }

    public void on_reject_call(GLib.SimpleAction action, GLib.Variant? parameter) {
      logger.d("on_reject_call");
      activate();
      if (parameter == null || parameter.get_string() == "") {
        return;
      }
      on_active_window((win) => win.on_reject_call(parameter.get_string()));
    }

    public void on_show_filetransfers() {
      logger.d("on_show_filetransfers");
      activate();
      on_active_window((win) => win.on_filetransfer());
    }

    public void on_show_conferences() {
      logger.d("on_show_conferences");
      activate();
      on_active_window((win) => win.on_create_groupchat());
    }

    public void on_show_add_contact() {
      logger.d("on_show_add_contact");
      activate();
      on_active_window((win) => win.on_add_contact());
    }

    private static void on_sig_int(int sig) {
      Idle.add(() => {
        var application = GLib.Application.get_default();
        if (application != null) {
          application.quit();
        }
        return false;
      });
    }

    private void on_quit() {
      var active_window = get_active_window();
      if (active_window != null) {
        active_window.destroy();
      }
    }
  }
}
