/*
 *    GetPinDialog.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
  public class PinDialog : Gtk.Dialog {
    private Gtk.Entry pin_entry = new Gtk.Entry();
    public string pin {
      get { return pin_entry.text;  }
      set { pin_entry.text = value; }
    }
    public PinDialog() {
      add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Ok", Gtk.ResponseType.OK, null);
      title = "Please insert pin...";
      set_default_response(Gtk.ResponseType.OK);
      
      get_content_area().add(pin_entry);
    }
  }
}
