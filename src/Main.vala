/*
 *    Main.vala
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
  int main (string[] args) {
    GLib.Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.GETTEXT_PATH);
    GLib.Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "utf-8");
    GLib.Intl.textdomain(Config.GETTEXT_PACKAGE);

    Gst.init(ref args);

    // So for some reason pipewire thinks it's hot shit, setting itself to
    // Gst.Rank.PRIMARY + 1 while at the same time crashing 60% of the time,
    // every time.
    {
      var provider_factory = Gst.DeviceProviderFactory.find("pipewiredeviceprovider");
      if (provider_factory != null) {
        provider_factory.set_rank(Gst.Rank.NONE);
      }
      var element_factory = Gst.ElementFactory.find("pipewiresrc");
      if (element_factory != null) {
        element_factory.set_rank(Gst.Rank.NONE);
      }
    }

    return new Application().run(args);
  }
}
