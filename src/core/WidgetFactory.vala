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
  public interface WidgetFactory : Object {
    public abstract ApplicationWindow create_application_window(Gtk.Application application, ToxSession session, NospamRepository nospam_repository, FriendRequestRepository friend_request_repository, MessageRepository message_repository, DhtNodeRepository node_database, ISettingsDatabase settings_database, ContactRepository contact_repository);
    public abstract Logger create_logger();
    public abstract Gtk.Dialog create_about_dialog();
    public abstract DatabaseFactory create_database_factory();
    public abstract SettingsWidget create_settings_widget(ApplicationWindow? app_window, ISettingsDatabase database, DhtNodeRepository nodeRepository);
  }

  public class DefaultWidgetFactory : WidgetFactory, Object {
    private Logger logger;
    private Gtk.Dialog about_dialog;
    private ApplicationWindow app_window;

    public ApplicationWindow create_application_window(Gtk.Application application, ToxSession session, NospamRepository nospam_repository, FriendRequestRepository friend_request_repository, MessageRepository message_repository, DhtNodeRepository node_database, ISettingsDatabase settings_database, ContactRepository contact_repository) {
      if (app_window == null) {
        app_window = new ApplicationWindow(application, this, session, nospam_repository, friend_request_repository, message_repository, node_database, settings_database, contact_repository);
      }
      return app_window;
    }

    public Logger create_logger() {
      if (logger == null) {
        logger = new CommandLineLogger();
      }
      return logger;
    }

    public DatabaseFactory create_database_factory() {
      return new SqliteWrapperFactory();
    }

    public Gtk.Dialog create_about_dialog() {
      if (about_dialog == null) {
        about_dialog = new AboutDialog(logger);
        about_dialog.modal = true;
        about_dialog.destroy.connect(() => { about_dialog = null; });
      }
      return about_dialog;
    }

    public SettingsWidget create_settings_widget(ApplicationWindow? app_window, ISettingsDatabase settingsDatabase, DhtNodeRepository nodeRepository) {
      return new SettingsWidget(create_logger(), app_window, settingsDatabase, nodeRepository);
    }
  }

}
