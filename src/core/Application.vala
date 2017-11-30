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
  class Application : Gtk.Application {
    private const GLib.ActionEntry app_entries[] =
    {
      { "preferences", on_preferences, null, null, null },
      { "about", on_about, null, null, null },
      { "quit", on_quit, null, null, null }
    };

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
    }

    private ApplicationWindow getApplicationWindow() {
      if (applicationWindow == null) {
        applicationWindow = widget_factory.createApplicationWindow(this, nodeDatabase, settingsDatabase, contact_database);
      }
      return applicationWindow;
    }

    protected override void startup() {
      base.startup();

      widget_factory = new Factory.WidgetFactory();
      logger = widget_factory.createLogger();
      database_factory = widget_factory.createDatabaseFactory();

      try {
        database = database_factory.createDatabase("tox.db");
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

      add_action_entries(app_entries, this);
      var app_menu = builder.get_object("app_menu") as MenuModel;
      assert(app_menu != null);
      set_app_menu(app_menu);
    }

    protected override void activate() {
      hold();
      getApplicationWindow().present();
      release();
    }

    protected override void open(GLib.File[] files, string hint) {
      logger.f("not implemented.");
    }

    private void on_preferences() {
      getApplicationWindow().show_settings();
    }

    public void on_about() {
      var about_dialog = widget_factory.createAboutDialog();
      about_dialog.transient_for = getApplicationWindow();
      about_dialog.run();
      about_dialog.destroy();
    }

    private void on_quit() {
      if (applicationWindow != null) {
        applicationWindow.destroy();
      }
    }
  }
}
