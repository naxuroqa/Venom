/*
 *    WidgetFactory.vala
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

namespace Venom.Factory {
  public interface IWidgetFactory : Object {
    public abstract ApplicationWindow createApplicationWindow(Gtk.Application application,
                                                              IDhtNodeDatabase node_database, ISettingsDatabase settings_database, IContactDatabase contact_database);
    public abstract ILogger createLogger();
    public abstract Gtk.Dialog createAboutDialog();
    public abstract IDatabaseFactory createDatabaseFactory();
    public abstract Gtk.Widget createSettingsWidget(ISettingsDatabase database, IDhtNodeDatabase nodeDatabase);
  }

  public class WidgetFactory : IWidgetFactory, Object {
    private ILogger logger;
    private Gtk.Dialog about_dialog;

    public ApplicationWindow createApplicationWindow(Gtk.Application application,
                                                     IDhtNodeDatabase node_database, ISettingsDatabase settings_database, IContactDatabase contact_database) {
      return new ApplicationWindow(application, this, node_database, settings_database, contact_database);
    }

    public ILogger createLogger() {
      if (logger == null) {
        logger = new Logger();
      }
      return logger;
    }

    public IDatabaseFactory createDatabaseFactory() {
      return new SqliteWrapperFactory();
    }

    public Gtk.Dialog createAboutDialog() {
      if (about_dialog == null) {
        about_dialog = new AboutDialog(logger);
        about_dialog.modal = true;
        about_dialog.unmap.connect(() => { about_dialog = null; });
      }
      return about_dialog;
    }

    public Gtk.Widget createSettingsWidget(ISettingsDatabase settingsDatabase, IDhtNodeDatabase nodeDatabase) {
      return new SettingsWidget(settingsDatabase, nodeDatabase, createLogger());
    }
  }

}
