/*
 *    vpx.vapi
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

[CCode (cheader_filename = "vpx/vpx_image.h", cprefix = "")]
namespace Vpx {
  [CCode (cname = "vpx_img_fmt_t", cprefix = "VPX_IMG_FMT_", has_type_id = false)]
  public enum ImageFormat {
    NONE,
    RGB24,      // 24 bit per pixel packed RGB
    RGB32,      // 32 bit per pixel packed 0RGB
    RGB565,     // 16 bit per pixel, 565
    RGB555,     // 16 bit per pixel, 555
    UYVY,       // UYVY packed YUV
    YUY2,       // YUYV packed YUV
    YVYU,       // YVYU packed YUV
    BGR24,      // 24 bit per pixel packed BGR
    RGB32_LE,   // 32 bit packed BGR0
    ARGB,       // 32 bit packed ARGB, alpha=255
    ARGB_LE,    // 32 bit packed BGRA, alpha=255
    RGB565_LE,  // 16 bit per pixel, gggbbbbb rrrrrggg
    RGB555_LE,  // 16 bit per pixel, gggbbbbb 0rrrrrgg
    YV12,       // planar YVU
    VPXI420     // < planar 4:2:0 format with vpx color space
  }

  [CCode (cname = "vpx_image_t", free_function = "vpx_image_free", cprefix = "vpx_image_", has_type_id = false)]
  public class Image {
    [CCode (cname = "fmt")]
    public ImageFormat fmt;
    [CCode (cname = "w")]
    public uint w;
    [CCode (cname = "h")]
    public uint h;
    [CCode (cname = "d_w")]
    public uint d_w;
    [CCode (cname = "d_h")]
    public uint d_h;
    [CCode (cname = "x_chroma_shift")]
    public uint x_chroma_shift;
    [CCode (cname = "y_chroma_shift")]
    public uint y_chroma_shift;
    [CCode (cname = "planes", array_length=false)]
    public uint8** planes;
    [CCode (cname = "stride", array_length=false)]
    public int[] stride;
    [CCode (cname = "bps")]
    public int bps;

    [CCode (cname = "vpx_image_alloc")]
    public Image(ImageFormat fmt, uint d_w, uint d_h, uint align);

    public Image wrap(ImageFormat fmt, uint d_w, uint d_h, uint align, [CCode(array_length=false)] uint8[] img_data);

    public int set_rect(uint x, uint y, uint w, uint h);

    public void flip();
  }
}
