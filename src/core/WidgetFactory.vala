/*
 *    WidgetFactory.vala
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

namespace Venom.Factory {
  public interface IWidgetFactory : Object {
    public abstract ApplicationWindow createApplicationWindow(Gtk.Application application, ToxSession session, INospamRepository nospam_repository, IFriendRequestRepository friend_request_repository, IDhtNodeRepository node_database, ISettingsDatabase settings_database, IContactRepository contact_repository);
    public abstract ILogger createLogger();
    public abstract Gtk.Dialog createAboutDialog();
    public abstract IDatabaseFactory createDatabaseFactory();
    public abstract SettingsWidget createSettingsWidget(ApplicationWindow? app_window, ISettingsDatabase database, IDhtNodeRepository nodeRepository);
  }

  public class WidgetFactory : IWidgetFactory, Object {
    private ILogger logger;
    private Gtk.Dialog about_dialog;
    private ApplicationWindow app_window;

    public ApplicationWindow createApplicationWindow(Gtk.Application application, ToxSession session, INospamRepository nospam_repository, IFriendRequestRepository friend_request_repository, IDhtNodeRepository node_database, ISettingsDatabase settings_database, IContactRepository contact_repository) {
      if (app_window == null) {
        app_window = new ApplicationWindow(application, this, session, nospam_repository, friend_request_repository, node_database, settings_database, contact_repository);
      }
      return app_window;
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
        about_dialog.destroy.connect(() => { about_dialog = null; });
      }
      return about_dialog;
    }

    public SettingsWidget createSettingsWidget(ApplicationWindow? app_window, ISettingsDatabase settingsDatabase, IDhtNodeRepository nodeRepository) {
      return new SettingsWidget(createLogger(), app_window, settingsDatabase, nodeRepository);
    }
  }

}
