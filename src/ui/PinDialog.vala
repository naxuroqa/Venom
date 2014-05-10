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
    private Gtk.Entry pin_entry;
    public string pin {
      get { return pin_entry.text;  }
      set { pin_entry.text = value; }
    }
    public PinDialog( string username ) {

      Gtk.Box content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
      content_box.spacing = 6;
      content_box.margin_left = 5;
      content_box.margin_right = 5;
      content_box.margin_top = 5;

      Gtk.Label label_pin = new Gtk.Label("Please insert PIN for \n<b>%s</b>".printf(Markup.escape_text( username )));
      label_pin.use_markup = true;
      content_box.pack_start(label_pin, false, false, 0);

      pin_entry = new Gtk.Entry();
      pin_entry.activates_default = true;
      pin_entry.xalign = 0.5f;
      content_box.pack_start(pin_entry, false, false, 0);

      get_content_area().add(content_box);

      add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Ok", Gtk.ResponseType.OK, null);
      title = "Please insert PIN...";
      pin = "000000";

      set_default_response(Gtk.ResponseType.OK);
    }
  }
}
