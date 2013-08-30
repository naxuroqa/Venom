/*
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
  public class ContactListCellRenderer : Gtk.CellRenderer {
    public Contact contact { get; set; }

    public ContactListCellRenderer() {
      GLib.Object();
    }
    
    public override void get_size(Gtk.Widget widget, Gdk.Rectangle? cell_area, out int x_offset, out int y_offset, out int width, out int height) {     
      x_offset = 0;
      y_offset = 0;
      width = 50;
      height = 50;
    }
    
    public override void render(Cairo.Context ctx, Gtk.Widget widget, Gdk.Rectangle background_area, Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
      //TODO
    }
  }
}
