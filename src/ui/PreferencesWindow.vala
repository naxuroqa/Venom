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

namespace Venom {
  public class PreferencesWindow : Gtk.Dialog {

    public PreferencesWindow() {
      init_widgets();
    }

    private void init_widgets() {
      Gtk.Notebook notebook = new Gtk.Notebook();
      notebook.tab_pos = Gtk.PositionType.LEFT;
      this.get_content_area().add(notebook);

      foreach(SettingsProvider sp in ResourceFactory.instance.settings_providers) {
        sp.reset();
        notebook.append_page(sp.get_content(), sp.get_label());
      }

      this.add_buttons("_Cancel", Gtk.ResponseType.CANCEL, "_Apply", Gtk.ResponseType.APPLY, null);
      this.set_default_response(Gtk.ResponseType.APPLY);
      show_all();
    }
  }
}
