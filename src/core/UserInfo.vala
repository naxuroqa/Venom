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
    public abstract Avatar avatar { get; set; }
    public abstract bool custom_avatar { get; set; }
    public abstract UserStatus user_status { get; set; }
    public abstract bool is_connected { get; set; }
    public abstract string tox_id { get; set; }
  }

  public class Avatar : GLib.Object {
    public Gdk.Pixbuf pixbuf { get; set; }
    public GLib.Bytes hash { get; set; }

    construct {
      hash = new GLib.Bytes(new uint8[] {});
    }

    public void set_from_pixbuf(ILogger logger, Gdk.Pixbuf pixbuf) {
      this.hash = new GLib.Bytes(new uint8[] {});
      this.pixbuf = pixbuf;
    }

    public void set_from_data(ILogger logger, uint8[] data, Gdk.Pixbuf? pixbuf = null) throws Error {
      this.hash = new GLib.Bytes(ToxCore.Tox.hash(data));
      if (pixbuf != null) {
        this.pixbuf = pixbuf;
      } else {
        var loader = new Gdk.PixbufLoader();
        try {
          loader.write(data);
          loader.close();
        } catch (Error e) {
          logger.e("Can not load avatar from data: " + e.message);
        }
        unowned Gdk.Pixbuf tmp = loader.get_pixbuf();
        if (tmp != null) {
          this.pixbuf = tmp.scale_simple(120, 120, Gdk.InterpType.BILINEAR);
        }
      }
    }
  }

  public class UserInfoImpl : UserInfo, GLib.Object {
    public string name { get; set; }
    public string status_message { get; set; }
    public Avatar avatar { get; set; }
    public bool custom_avatar { get; set; }
    public UserStatus user_status { get; set; }
    public bool is_connected { get; set; }
    public string tox_id { get; set; }

    construct {
      name = R.strings.default_username();
      status_message = R.strings.default_statusmessage();
      avatar = new Avatar();
      custom_avatar = false;
      user_status = UserStatus.NONE;
      is_connected = false;
      tox_id = "";
    }
  }
}
