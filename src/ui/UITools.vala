/*
 *    UITools.vala
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
  public class UITools : GLib.Object {
    public static void ErrorDialog(string message, string? secondary_text = null, Gtk.Window? parent = null) {
      Gtk.MessageDialog dialog = new Gtk.MessageDialog(
        parent,
        Gtk.DialogFlags.MODAL,
        Gtk.MessageType.ERROR,
        Gtk.ButtonsType.CLOSE,
        message
      );
      if(secondary_text != null)
        dialog.secondary_text = secondary_text;
      dialog.run();
      dialog.destroy();
    }
    public static string format_filesize(uint64 size) {
      if(Settings.instance.dec_binary_prefix) {
        uint64 kibibyte = 1024;
        uint64 mebibyte = kibibyte * 1024;
        uint64 gibibyte = mebibyte * 1024;
        uint64 tebibyte = gibibyte * 1024;
        uint64 pebibyte = tebibyte * 1024;

        if(size < kibibyte) return "%llu bytes".printf(size);
        if(size < mebibyte) return "%.2lf KiB".printf( (double) size / kibibyte );
        if(size < gibibyte) return "%.2lf MiB".printf( (double) size / mebibyte );
        if(size < tebibyte) return "%.2lf GiB".printf( (double) size / gibibyte );
        if(size < pebibyte) return "%.2lf TiB".printf( (double) size / tebibyte );
        return "really big file";
      } else {
        uint64 kilobyte = 1000;
        uint64 megabyte = kilobyte * 1000;
        uint64 gigabyte = megabyte * 1000;
        uint64 terabyte = gigabyte * 1000;
        uint64 petabyte = terabyte * 1000;

        if(size < kilobyte) return "%llu bytes".printf(size);
        if(size < megabyte) return "%.2lf kB".printf( (double) size / kilobyte );
        if(size < gigabyte) return "%.2lf MB".printf( (double) size / megabyte );
        if(size < terabyte) return "%.2lf GB".printf( (double) size / gigabyte );
        if(size < petabyte) return "%.2lf TB".printf( (double) size / terabyte );
        return "really big file";
      }
    }
#if ENABLE_QR_ENCODE
    public static Gdk.Pixbuf? qr_encode(string content) {
      QR.Code code = QR.Code.encode_string(content, 0, QR.ECLevel.M, QR.Mode.EIGHT_BIT, false);
      if(code == null) {
        return null;
      }
      Gdk.Pixbuf pb = new Gdk.Pixbuf(Gdk.Colorspace.RGB, false, 8, code.width, code.width);
      unowned uint8[] buf = pb.get_pixels();
      for(int y = 0; y < code.width; y++) {
        for(int x = 0; x < code.width; x++) {
          buf[y * pb.rowstride + x * pb.n_channels + 0] = code.get(x, y) ? 0 : 255;
          buf[y * pb.rowstride + x * pb.n_channels + 1] = code.get(x, y) ? 0 : 255;
          buf[y * pb.rowstride + x * pb.n_channels + 2] = code.get(x, y) ? 0 : 255;
        }
      }
      return pb.scale_simple(code.width * 4, code.width * 4, Gdk.InterpType.NEAREST);
    }
#endif
  }
}
