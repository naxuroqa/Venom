/*
 *    Application.vala
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
  public class Application : Gtk.Application {
    private const GLib.ActionEntry app_entries[] = {
      { "preferences", on_show_preferences, null, null, null },
      { "about", on_show_about, null, null, null },
      { "quit", on_quit, null, null, null },
      { "show-filetransfers", on_show_filetransfers, null, null, null },
      { "show-contact", on_show_contact, "s", null, null }
    };

    private const OptionEntry[] option_entries = {
      { "loglevel", 'l', 0, OptionArg.INT, ref loglevel, N_("Set level of messages to log"), N_("<loglevel>") },
      { "version", 'V', 0, OptionArg.NONE, null, N_("Display version number"), null },
      { null }
    };

    private static LogLevel loglevel = LogLevel.INFO;

    private ApplicationWindow applicationWindow;
    private IDatabase database;
    private ILogger logger;
    private IDhtNodeDatabase nodeDatabase;
    private ISettingsDatabase settingsDatabase;
    private IContactDatabase contact_database;
    private Factory.IWidgetFactory widget_factory;
    private IDatabaseFactory database_factory;

    public Application() {
      Object(
        application_id: R.constants.app_id(),
        flags: ApplicationFlags.HANDLES_OPEN
        );
      add_main_option_entries(option_entries);
      add_action_entries(app_entries, this);
    }

    private ApplicationWindow getApplicationWindow() {
      if (applicationWindow == null) {
        applicationWindow = widget_factory.createApplicationWindow(this, nodeDatabase, settingsDatabase, contact_database);
      }
      return applicationWindow;
    }

    private static void create_path_for_filename(string filename) throws Error {
      var path = GLib.File.new_for_path(GLib.Path.get_dirname(filename));
      if (!path.query_exists()) {
        path.make_directory_with_parents();
      }
    }

    protected override void startup() {
      base.startup();

      Logger.displayed_level = loglevel;
      widget_factory = new Factory.WidgetFactory();
      logger = widget_factory.createLogger();
      database_factory = widget_factory.createDatabaseFactory();

      try {
        var db_file = R.constants.db_filename();
        create_path_for_filename(db_file);
        database = database_factory.createDatabase(db_file);
        var statementFactory = database_factory.createStatementFactory(database);
        nodeDatabase = database_factory.createNodeDatabase(statementFactory, logger);
        contact_database = database_factory.createContactDatabase(statementFactory, logger);
        settingsDatabase = database_factory.createSettingsDatabase(statementFactory, logger);
        settingsDatabase.load();

      } catch (Error e) {
        logger.f("Database creation failed: " + e.message);
        assert_not_reached();
      }

      var builder = new Gtk.Builder();
      try {
        builder.add_from_resource("/im/tox/venom/ui/app_menu.ui");
      } catch (Error e) {
        logger.f("Loading app menu failed: " + e.message);
        assert_not_reached();
      }

      var app_menu = builder.get_object("app_menu") as MenuModel;
      assert(app_menu != null);
      set_app_menu(app_menu);
    }

    protected override void activate() {
      hold();
      getApplicationWindow().present();
      release();
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

    private void on_show_preferences() {
      getApplicationWindow().show_settings();
    }

    public void on_show_about() {
      var about_dialog = widget_factory.createAboutDialog();
      about_dialog.transient_for = getApplicationWindow();
      about_dialog.run();
      about_dialog.destroy();
    }

    public void on_show_contact(GLib.SimpleAction action, GLib.Variant? parameter) {
      logger.i("on_show_contact");
      activate();
      if (parameter == null || parameter.get_string() == "") {
        return;
      }
      getApplicationWindow().on_show_contact(parameter.get_string());
    }

    public void on_show_filetransfers() {
      logger.i("on_show_filetransfers");
      activate();
      getApplicationWindow().on_filetransfer();
    }

    private void on_quit() {
      if (applicationWindow != null) {
        applicationWindow.destroy();
      }
    }
  }
}
