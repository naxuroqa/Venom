/*
 *    CropWidget.vala
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
/* This file is partially adapted from um-crop-area.c in libcheese
 *
 * Copyright 2009  Red Hat, Inc,
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * Written by: Matthias Clasen <mclasen@redhat.com>
 */

namespace Venom {
  public class CropWidget : Gtk.DrawingArea {
    public Gdk.Pixbuf pixbuf { get; set; }

    private double x;
    private double y;
    private double width;
    private double height;

    private Gdk.CursorType cursor_type = Gdk.CursorType.LEFT_PTR;
    private Location active_location = Location.OUTSIDE;
    private double last_event_x = 0;
    private double last_event_y = 0;

    public CropWidget() {
      add_events(Gdk.EventMask.POINTER_MOTION_MASK
                 | Gdk.EventMask.BUTTON_PRESS_MASK
                 | Gdk.EventMask.BUTTON_RELEASE_MASK);
      notify["pixbuf"].connect(on_pixbuf_changed);
    }

    private void on_pixbuf_changed() {
      if (pixbuf != null) {
        var size = int.min(pixbuf.width, pixbuf.height);
        width = height = size;
        x = (pixbuf.width - size) / 2.0;
        y = (pixbuf.height - size) / 2.0;

        set_size_request(pixbuf.width, pixbuf.height);
      }
    }

    public override bool draw(Cairo.Context context) {
      if (pixbuf == null) {
        return false;
      }
      Gdk.cairo_set_source_pixbuf(context, pixbuf, 0, 0);
      context.paint();

      var mask = new Cairo.ImageSurface(Cairo.Format.A8, pixbuf.width, pixbuf.height);
      var mask_context = new Cairo.Context(mask);
      mask_context.set_source_rgb(0, 0, 0);
      mask_context.paint();
      mask_context.set_operator(Cairo.Operator.CLEAR);
      mask_context.rectangle(x, y, width, height);
      mask_context.fill();

      context.set_source_rgba(0, 0, 0, 0.3);
      context.mask_surface(mask, 0, 0);

      context.set_line_width(1);
      context.set_source_rgb(0, 0, 0);
      context.rectangle(x + 0.5, y + 0.5, width - 1, height - 1);
      context.stroke();

      context.set_line_width(2);
      context.set_source_rgb(1, 1, 1);
      context.rectangle(x + 2, y + 2, width - 4, height - 4);
      context.stroke();

      return false;
    }

    private enum Range {
      BELOW,
      LOWER,
      BETWEEN,
      UPPER,
      ABOVE
    }
    private enum Location {
      OUTSIDE,
      INSIDE,
      TOP,
      TOP_LEFT,
      TOP_RIGHT,
      BOTTOM,
      BOTTOM_LEFT,
      BOTTOM_RIGHT,
      LEFT,
      RIGHT
    }
    private Location[,] locations = new Location[5, 5] {
      { OUTSIDE, OUTSIDE,     OUTSIDE, OUTSIDE,      OUTSIDE },
      { OUTSIDE, TOP_LEFT,    TOP,     TOP_RIGHT,    OUTSIDE },
      { OUTSIDE, LEFT,        INSIDE,  RIGHT,        OUTSIDE },
      { OUTSIDE, BOTTOM_LEFT, BOTTOM,  BOTTOM_RIGHT, OUTSIDE },
      { OUTSIDE, OUTSIDE,     OUTSIDE, OUTSIDE,      OUTSIDE }
    };

    private Range find_range(int x, int min, int max) {
      var tolerance = 12;
      if (x < min - tolerance) {
        return Range.BELOW;
      } else if (x <= min + tolerance) {
        return Range.LOWER;
      } else if (x < max - tolerance) {
        return Range.BETWEEN;
      } else if (x <= max + tolerance) {
        return Range.UPPER;
      }
      return Range.ABOVE;
    }

    private Location find_location(int x, int y) {
      var x_range = find_range(x, (int) this.x, (int) (this.x + this.width));
      var y_range = find_range(y, (int) this.y, (int) (this.y + this.height));
      return locations[y_range, x_range];
    }

    private Gdk.CursorType get_cursor_for_location(Location location) {
      switch (location) {
        case Location.INSIDE:
          return Gdk.CursorType.FLEUR;
        case Location.TOP:
          return Gdk.CursorType.TOP_SIDE;
        case Location.TOP_LEFT:
          return Gdk.CursorType.TOP_LEFT_CORNER;
        case Location.TOP_RIGHT:
          return Gdk.CursorType.TOP_RIGHT_CORNER;
        case Location.BOTTOM:
          return Gdk.CursorType.BOTTOM_SIDE;
        case Location.BOTTOM_LEFT:
          return Gdk.CursorType.BOTTOM_LEFT_CORNER;
        case Location.BOTTOM_RIGHT:
          return Gdk.CursorType.BOTTOM_RIGHT_CORNER;
        case Location.LEFT:
          return Gdk.CursorType.LEFT_SIDE;
        case Location.RIGHT:
          return Gdk.CursorType.RIGHT_SIDE;
      }
      return Gdk.CursorType.LEFT_PTR;
    }

    private void update_cursor(Location location) {
      var current_cursor_type = get_cursor_for_location(location);
      if (current_cursor_type != cursor_type) {
        cursor_type = current_cursor_type;
        var cursor = new Gdk.Cursor.for_display(get_display(), cursor_type);
        get_window().set_cursor(cursor);
      }
    }

    private void update_rectangle(Location location, Gdk.EventMotion event) {
      var delta_x = event.x - last_event_x;
      var delta_y = event.y - last_event_y;
      last_event_x = event.x;
      last_event_y = event.y;

      var pixbuf_width = pixbuf.width;
      var pixbuf_height = pixbuf.height;
      var max_size = int.min(pixbuf.width, pixbuf_height);

      var right = x + width;
      var bottom = y + height;
      var left = x;
      var top = y;

      var min_size = 10;

      switch (active_location) {
        case Location.INSIDE:
          x = double.min(double.max(delta_x + x, 0), pixbuf_width - width);
          y = double.min(double.max(delta_y + y, 0), pixbuf_height - height);
          break;
        case Location.TOP_LEFT:
        case Location.TOP_RIGHT:
        case Location.TOP:
          top = double.max(top + delta_y, 0);
          top = double.min(top, bottom - min_size);
          top = double.max(top, bottom - max_size);
          top = double.max(top, bottom - (pixbuf_width - x));
          y = top;
          height = bottom - top;
          width = height;
          break;
        case Location.BOTTOM:
          height = double.max(height + delta_y, 0);
          height = double.max(height, min_size);
          height = double.min(height, max_size);
          height = double.min(height, pixbuf_width - x);
          height = double.min(height, pixbuf_height - y);
          width = height;
          break;
        case Location.BOTTOM_LEFT:
        case Location.LEFT:
          left = double.max(left + delta_x, 0);
          left = double.max(left, right - max_size);
          left = double.min(left, right - min_size);
          left = double.max(left, right - (pixbuf_height - y));
          x = left;
          width = right - left;
          height = width;
          break;
        case Location.BOTTOM_RIGHT:
        case Location.RIGHT:
          width = double.max(width + delta_x, 0);
          width = double.max(width, min_size);
          width = double.min(width, max_size);
          width = double.min(width, pixbuf_width - x);
          width = double.min(width, pixbuf_height - y);
          height = width;
          break;
      }
    }

    public override bool motion_notify_event(Gdk.EventMotion event) {
      if (pixbuf == null) {
        return false;
      }
      var location = find_location((int) event.x, (int) event.y);
      update_cursor(location);

      if (active_location == Location.OUTSIDE) {
        return false;
      }

      queue_draw_area((int) x - 2, (int) y - 2, (int) width + 4, (int) height + 4);
      update_rectangle(location, event);
      queue_draw_area((int) x - 2, (int) y - 2, (int) width + 4, (int) height + 4);
      return false;
    }

    public override bool button_press_event(Gdk.EventButton event) {
      if (pixbuf == null) {
        return false;
      }
      active_location = find_location((int) event.x, (int) event.y);

      last_event_x = event.x;
      last_event_y = event.y;
      return false;
    }

    public override bool button_release_event(Gdk.EventButton event) {
      if (pixbuf == null) {
        return false;
      }
      active_location = Location.OUTSIDE;
      return false;
    }

    ~CropWidget() {
    }

    public Gdk.Pixbuf? get_cropped_picture() {
      if (pixbuf == null || width <= 0 || height <= 0) {
        return null;
      }
      var surface = new Cairo.ImageSurface(Cairo.Format.RGB24, (int) width, (int) height);
      var context = new Cairo.Context(surface);
      Gdk.cairo_set_source_pixbuf(context, pixbuf, -x, -y);
      context.paint();
      return Gdk.pixbuf_get_from_surface(surface, 0, 0, (int) width, (int) height);
    }
  }
}
