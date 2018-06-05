/*
 *    Identicon.vala
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
  public class Identicon : GLib.Object {
    private uint8[] hash;
    private int width;
    private int height;

    private Cairo.Context ctx;
    private Cairo.Surface surface;

    public static Gdk.Pixbuf generate_pixbuf(uint8[] public_key) {
      var identicon = new Identicon(public_key);
      identicon.draw();
      return identicon.get_pixbuf();
    }

    public Identicon(uint8[] public_key) {
      this.hash = generate_hash(public_key);
      this.width = 120;
      this.height = 120;
      this.surface = new Cairo.ImageSurface(Cairo.Format.RGB24, width, height);
      this.ctx = new Cairo.Context(surface);
    }

    public void draw() {
      var rgb1 = hsl_to_rgb(hue_color(hue_uint(hash, 26)));
      var rgb2 = hsl_to_rgb(hue_color(hue_uint(hash, 20)), 0.5f, 0.8f);

      ctx.scale(width / 5f, height / 5f);

      for (var row = 0; row < 5; row++) {
        for (var col = 0; col < 5; col++) {
          var col_idx = (((col * 2) - 4) / 2).abs();
          var pos = row * 3 + col_idx;
          if (hash[pos] % 2 == 0) {
            ctx.set_source_rgb(rgb1[0] / 255f, rgb1[1] / 255f, rgb1[2] / 255f);
          } else {
            ctx.set_source_rgb(rgb2[0] / 255f, rgb2[1] / 255f, rgb2[2] / 255f);
          }
          ctx.rectangle(col, row, 1, 1);
          ctx.fill();
        }
      }
    }

    public void write_to_png(string filename) {
      surface.write_to_png(filename);
    }

    public Gdk.Pixbuf get_pixbuf() {
      return Gdk.pixbuf_get_from_surface(surface, 0, 0, width, height);
    }

    public uint8[] generate_hash(uint8[] public_key) {
      return Tools.hexstring_to_bin(Checksum.compute_for_data(ChecksumType.SHA256, public_key));
    }

    public uint64 hue_uint(uint8[] hash, uint offset) {
      unowned uint8[] hashpart_1 = hash[offset : offset + 6];
      uint64 hue = hashpart_1[0];
      hue = (hue << 8) + (hashpart_1[1] & 0xff);
      hue = (hue << 8) + (hashpart_1[2] & 0xff);
      hue = (hue << 8) + (hashpart_1[3] & 0xff);
      hue = (hue << 8) + (hashpart_1[4] & 0xff);
      hue = (hue << 8) + (hashpart_1[5] & 0xff);
      return hue;
    }

    public float hue_color(uint64 hue_uint) {
      return hue_uint / 281474976710655.0f;
    }

    private float hue_to_rgb(float p, float q, float t) {
      if (t < 0) {
        t += 1;
      }
      if (t > 1) {
        t -= 1;
      }
      if (t < 1 / 6f) {
        return p + (q - p) * 6 * t;
      }
      if (t < 1 / 2f) {
        return q;
      }
      if (t < 2 / 3f) {
        return p + (q - p) * (2 / 3f - t) * 6;
      }
      return p;
    }

    public uint8[] hsl_to_rgb(float h, float s = 0.5f, float l = 0.3f) {
      float r, g, b;
      if (s == 0) {
        r = g = b = l;
      } else {
        var q = l < 0.5f ? l * (1 + s) : l + s - l * s;
        var p = 2 * l - q;
        r = hue_to_rgb(p, q, h + 1 / 3f);
        g = hue_to_rgb(p, q, h);
        b = hue_to_rgb(p, q, h - 1 / 3f);
      }
      return { (uint8) (r * 255), (uint8) (g * 255), (uint8) (b * 255) };
    }
  }
}
