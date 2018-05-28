/*
 *    ContextStyleBinding.vala
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
  public class ContextStyleBinding : GLib.Object {
    private bool _enable;
    public bool enable {
      get { return _enable; }
      set {
        if (_enable == value) {
          return;
        }
        _enable = value;
        update_style();
      }
    }

    private unowned Gtk.Widget widget;
    private string styleclass;
    public ContextStyleBinding(Gtk.Widget widget, string styleclass) {
      this.widget = widget;
      this.styleclass = styleclass;
      _enable = false;
    }

    private void update_style() {
      var ctx = widget.get_style_context();
      if (_enable) {
        ctx.add_class(styleclass);
      } else {
        ctx.remove_class(styleclass);
      }
    }
  }
}
