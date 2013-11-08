/*
 *    Copyright (C) 2013 Venom authors and contributors
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

public class Avatar {
  uint8[] hash;
  int size;
  Gdk.Pixbuf pixbuf;
  public Avatar(uint8[] hash, int size) {
    this.hash = hash;
    this.size = size;
    pixbuf = null;
  }
  
  public Gdk.Pixbuf get_pixbuf() {
    if(pixbuf == null)
      update_pixbuf();
    return pixbuf;
  }

  public void update_pixbuf() {
  
    Cairo.ImageSurface surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, size, size);
    Gdk.Pixmap
    Cairo.Context cr = new Cairo.Context(surface);
    
    cr.save();
    cr.rectangle(0.0, 0.0, size, size);
    cr.set_source_rgb(1.0, 1.0, 1.0);
    cr.fill();
    cr.restore();
    
    cr.scale(size/200.0, size/200.0);
    
    Shape[] shapes = {};
    for(int i=0; i < svg_shapes.length; ++i) {
      shapes += new Shape();
    }
    
    for(int i=0; i < shapes.length; ++i) {
      cr.save();
      shapes[i].draw(cr);
      cr.restore();
    }
    
    cr.get
  }
}

public static void main() {
}
