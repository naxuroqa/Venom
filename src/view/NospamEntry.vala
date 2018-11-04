/*
 *    NospamEntry.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/nospam_entry.ui")]
  public class NospamEntry : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label nospam;
    [GtkChild] private Gtk.Label timestamp;
    [GtkChild] private Gtk.Button remove;

    public signal void remove_clicked(Nospam item);
    public signal void row_activated(Nospam item);

    private Logger logger;
    private Nospam item;

    public NospamEntry(Logger logger, Nospam item) {
      this.logger = logger;
      this.item = item;

      nospam.label = "0x%.8X".printf(item.nospam);
      timestamp.label = item.timestamp.format("%c");

      remove.clicked.connect(on_remove_clicked);
      logger.d("NospamEntry created.");
    }

    public void on_row_clicked() {
      row_activated(item);
    }

    private void on_remove_clicked() {
      remove_clicked(item);
    }

    ~NospamEntry() {
      logger.d("NospamEntry destroyed.");
    }
  }
}
