/*
 *    MockSettingsDatabase.vala
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

using Venom;
using Mock;
using Testing;

namespace Mock {
  public class MockSettingsDatabase : ISettingsDatabase, GLib.Object {
    public bool   enable_dark_theme           { get; set; }
    public bool   enable_animations           { get; set; }
    public bool   enable_logging              { get; set; }
    public bool   enable_urgency_notification { get; set; }
    public bool   enable_tray                 { get; set; }
    public bool   enable_tray_minimize        { get; set; }
    public bool   enable_notify               { get; set; }
    public bool   enable_send_typing          { get; set; }
    public bool   enable_proxy                { get; set; }
    public bool   enable_custom_proxy         { get; set; }
    public string custom_proxy_host           { get; set; }
    public int    custom_proxy_port           { get; set; }
    public bool   enable_udp                  { get; set; }
    public bool   enable_ipv6                 { get; set; }
    public bool   enable_local_discovery      { get; set; }
    public bool   enable_hole_punching        { get; set; }
    public bool   enable_compact_contacts     { get; set; }
    public bool   enable_notification_sounds  { get; set; }
    public bool   enable_notification_busy    { get; set; }
    public bool   enable_spelling             { get; set; }

    public void load() {
      mock().actual_call(this, "load");
    }
    public void save() {
      mock().actual_call(this, "save");
    }
  }
}
