/*
 *    TimeStamp.vala
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

namespace Venom.TimeStamp {
  public static string get_pretty_timestamp(GLib.DateTime timestamp, GLib.DateTime now = new GLib.DateTime.now_local()) {
    var just_now = now.add_minutes(-1);
    if (timestamp.compare(just_now) > 0) {
      return _("Just now");
    }
    var minutes_ago = now.add_minutes(-59);
    if (timestamp.compare(minutes_ago) > 0) {
      var minutes = (uint) (now.difference(timestamp) / GLib.TimeSpan.MINUTE);
      return ngettext("%u minute ago", "%u minutes ago", minutes).printf(minutes);
    }
    var hours_ago = now.add_hours(-6);
    if (timestamp.compare(hours_ago) > 0) {
      var hours = (uint) (now.difference(timestamp) / GLib.TimeSpan.HOUR);
      return ngettext("%u hour ago", "%u hours ago", hours).printf(hours);
    }
    var midnight = new GLib.DateTime.local(now.get_year(), now.get_month(), now.get_day_of_month(), 0, 0, 0);
    if (timestamp.compare(midnight) > 0) {
      return _("Today at %s").printf(timestamp.format("%X"));
    }
    var yesterday = midnight.add_days(-1);
    if (timestamp.compare(yesterday) > 0) {
      return _("Yesterday at %s").printf(timestamp.format("%X"));
    }
    return timestamp.format("%c");
  }
}
