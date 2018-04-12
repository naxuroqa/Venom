/*
 *    Contact.vala
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

namespace Venom {
  public interface IContact : Object {
    public signal void changed();

    public abstract string get_id();
    public abstract string get_name_string();
    public abstract string get_status_string();
    public abstract UserStatus get_status();
    public abstract bool is_connected();
    public abstract Gdk.Pixbuf get_image();
    public abstract bool get_requires_attention();
    public abstract void clear_attention();
  }
}
