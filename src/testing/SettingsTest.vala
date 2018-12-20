/*
 *    SettingsTest.vala
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

public static int main (string[] args) {
  Gst.init(ref args);
  Gtk.init(ref args);

  try_set_device_provider_rank("pipewiredeviceprovider", Gst.Rank.SECONDARY);

  var logger = new Venom.CommandLineLogger();
  var settings_database = new Mock.MockSettingsDatabase();
  var node_repository = new Mock.MockDhtNodeRepository();

  Venom.CommandLineLogger.displayed_level = Venom.LogLevel.DEBUG;

  settings_database.custom_proxy_host = "localhost";

  var window = new Gtk.Window();
  window.title = "Settings test window";
  window.set_default_size(1024, 768);
  window.add(new Venom.SettingsWidget(logger, null, settings_database, node_repository));
  window.show_all();
  window.destroy.connect(Gtk.main_quit);

  Gtk.main();

  return 0;
}

public static void try_set_device_provider_rank(string device_provider, Gst.Rank rank) {
  var factory = Gst.DeviceProviderFactory.find(device_provider);
  if (factory != null) {
    factory.set_rank(rank);
  }
}
