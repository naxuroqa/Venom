/*
 *    UserInfo.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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
    public signal void info_changed(GLib.Object sender);

    public abstract string get_name();
    public abstract void set_name(string name);
    public abstract string get_status_message();
    public abstract void set_status_message(string status);
    public abstract Gdk.Pixbuf get_image();
    public abstract void set_image(Gdk.Pixbuf image);
    public abstract UserStatus get_user_status();
    public abstract void set_user_status(UserStatus status);
    public abstract string get_tox_id();
    public abstract void set_tox_id(string id);
  }

  public class UserInfoImpl : UserInfo, GLib.Object {
    public UserInfoImpl() {
      name = R.strings.default_username();
      status_message = R.strings.default_statusmessage();
      image = UITools.pixbuf_from_resource(R.icons.default_contact);
      user_status = UserStatus.OFFLINE;
    }

    private string name;
    private string status_message;
    private Gdk.Pixbuf image;
    private UserStatus user_status;
    private string tox_id;

    public virtual string get_name() {
      return name;
    }
    public virtual void set_name(string name) {
      this.name = name;
    }
    public virtual string get_status_message() {
      return status_message;
    }
    public virtual void set_status_message(string status_message) {
      this.status_message = status_message;
    }
    public virtual Gdk.Pixbuf get_image() {
      return image;
    }
    public virtual void set_image(Gdk.Pixbuf image) {
      this.image = image;
    }
    public virtual UserStatus get_user_status() {
      return user_status;
    }
    public virtual void set_user_status(UserStatus user_status) {
      this.user_status = user_status;
    }
    public virtual string get_tox_id() {
      return tox_id;
    }
    public virtual void set_tox_id(string id) {
      tox_id = id;
    }
  }
}
