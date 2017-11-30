/*
 *    DownloadsWidget.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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
  [GtkTemplate(ui = "/im/tox/venom/ui/downloads_widget.ui")]
  public class DownloadsWidget : Gtk.Box {
    private ILogger logger;

    public DownloadsWidget(ILogger logger) {
      logger.d("DownloadsWidget created.");
      this.logger = logger;

      // contact_list.bind_model(new ContactListModel(contacts), create_entry);
      // contact_list.row_activated.connect(on_row_activated);
    }

    // private Gtk.Widget create_entry(GLib.Object object) {
    //   return new ContactListEntry(logger, object as IContact);
    // }

    ~DownloadsWidget() {
      logger.d("DownloadsWidget destroyed.");
    }
  }

  public interface IDownload : GLib.Object {

  }
}
