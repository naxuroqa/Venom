/*
 *    PhotoboothTest.vala
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

  var booth = new Venom.PhotoboothWindow();
  booth.title = "Photobooth test window";
  booth.show_all();
  booth.timeout = 0;
  booth.new_photo.connect((pixbuf) => {
    var timestamp = new GLib.DateTime.now_local();
    pixbuf.save("%s.png".printf(timestamp.format("%c")), "png");
    booth.destroy();
    booth = null;
  });
  booth.destroy.connect(Gtk.main_quit);

  Gtk.main();

  return 0;
}
