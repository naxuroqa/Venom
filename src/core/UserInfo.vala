/*
 *    UserInfo.vala
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

namespace Venom {
  public interface UserInfo : GLib.Object {
    public signal void info_changed();

    public abstract string name { get; set; }
    public abstract string status_message { get; set; }
    public abstract Gdk.Pixbuf avatar { get; set; }
    public abstract bool custom_avatar { get; set; }
    public abstract UserStatus user_status { get; set; }
    public abstract bool is_connected { get; set; }
    public abstract string tox_id { get; set; }
  }

  public class UserInfoImpl : UserInfo, GLib.Object {
    public string name { get; set; }
    public string status_message { get; set; }
    public Gdk.Pixbuf avatar { get; set; }
    public bool custom_avatar { get; set; }
    public UserStatus user_status { get; set; }
    public bool is_connected { get; set; }
    public string tox_id { get; set; }

    construct {
      name = R.strings.default_username();
      status_message = R.strings.default_statusmessage();
      avatar = pixbuf_from_resource(R.icons.default_contact, 128);
      custom_avatar = false;
      user_status = UserStatus.NONE;
      is_connected = false;
      tox_id = "";
    }
  }
}
