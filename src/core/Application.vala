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
      { "show-filetransfers", on_show_filetransfers, null, null, null },
      { "show-conferences", on_show_conferences, null, null, null },
      { "show-add-contact", on_show_add_contact, null, null, null },
      { "show-contact", on_show_contact, "s", null, null },
      { "show-contact-info", on_show_contact_info, "s", null, null },
      { "mute-contact", on_mute_contact, "s", null, null }
    };

    private const OptionEntry[] option_entries = {
      { "loglevel", 'l', 0, OptionArg.INT, ref loglevel, N_("Set level of messages to log"), N_("<loglevel>") },
      { "version", 'V', 0, OptionArg.NONE, null, N_("Display version number"), null },
      { "preferences", 'p', 0, OptionArg.NONE, null, N_("Show preferences"), null },
      { null }
    };

    private static LogLevel loglevel = LogLevel.INFO;

    private IDatabase database;
    private ILogger logger;
    private ToxSession session;
    private IDhtNodeDatabase node_database;
    private ISettingsDatabase settings_database;
    private IContactDatabase contact_database;
    private Factory.IWidgetFactory widget_factory;
    private IDatabaseFactory database_factory;

    public Application() {
      Object(
        application_id: R.constants.app_id(),
        flags: ApplicationFlags.HANDLES_OPEN | ApplicationFlags.HANDLES_COMMAND_LINE
        );
      add_main_option_entries(option_entries);
      add_action_entries(app_entries, this);
    }

    private Gtk.ApplicationWindow create_application_window() throws Error {
      return widget_factory.createApplicationWindow(this, session, node_database, settings_database, contact_database);
    }

    private Gtk.ApplicationWindow create_error_window(string error_message) {
      var window = new Gtk.ApplicationWindow(this);
      window.set_default_size(800, 600);
      var err_widget = new ErrorWidget(window, error_message);
      err_widget.add_page(widget_factory.createSettingsWidget(null, settings_database, node_database), "settings", _("Settings"));
      var log_view = new Gtk.TextView();
      log_view.editable = false;
      log_view.monospace = true;
      Gtk.TextIter iter;
      log_view.buffer.get_start_iter(out iter);
      log_view.buffer.insert_markup(ref iter, logger.get_log(), -1);
      err_widget.add_page(log_view, "log", _("Log"));
      err_widget.on_retry.connect(() => {
        window.destroy();
        try_show_app_window();
      });
      window.add(err_widget);
      window.show_all();
      return window;
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

      Gtk.AccelMap.load(R.constants.accels_filename());

      Logger.displayed_level = loglevel;
      widget_factory = new Factory.WidgetFactory();
      logger = widget_factory.createLogger();
      database_factory = widget_factory.createDatabaseFactory();

      try {
        var db_file = R.constants.db_filename();
        create_path_for_filename(db_file);
        database = database_factory.createDatabase(db_file);
        var statementFactory = database_factory.createStatementFactory(database);
        node_database = database_factory.createNodeDatabase(statementFactory, logger);
        contact_database = database_factory.createContactDatabase(statementFactory, logger);
        settings_database = database_factory.createSettingsDatabase(statementFactory, logger);
        settings_database.load();

      } catch (Error e) {
        logger.f("Database creation failed: " + e.message);
        assert_not_reached();
      }

      var builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/com/github/naxuroqa/venom/ui/app_menu.ui");
      } catch (Error e) {
        logger.f("Loading app menu failed: " + e.message);
        assert_not_reached();
      }

      var app_menu = builder.get_object("app_menu") as MenuModel;
      assert(app_menu != null);
      set_app_menu(app_menu);
    }

    protected override void shutdown() {
      settings_database.save();

      settings_database = null;
      contact_database = null;
      node_database = null;
      database = null;

      Gtk.AccelMap.save(R.constants.accels_filename());
      base.shutdown();
    }

    private void try_show_app_window() {
      var window = get_active_window() as Gtk.ApplicationWindow;
      if (window != null) {
        window.present();
        return;
      }

      try {
        if (session == null) {
          var session_io = new ToxSessionIOImpl(logger);
          session = new ToxSessionImpl(session_io, node_database, settings_database, logger);
        }
        create_application_window().present();
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

    private delegate void AppWindowDelegate(ApplicationWindow win);

    private void on_active_window(AppWindowDelegate run) {
      var active_window = get_active_window() as ApplicationWindow;
      if (active_window != null) {
        run(active_window);
      }
    }

    private void on_show_preferences() {
      activate();
      on_active_window((win) => win.show_settings());
    }

    public void on_show_about() {
      var about_dialog = widget_factory.createAboutDialog();
      about_dialog.transient_for = get_active_window();
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
