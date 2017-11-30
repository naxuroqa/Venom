/*
 *    UserInfoWidget.vala
 *
 *    Copyright (C) 2013-2017  Venom authors and contributors
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
  [GtkTemplate(ui = "/im/tox/venom/ui/user_info_widget.ui")]
  public class UserInfoWidget : Gtk.Box {

    [GtkChild]
    private Gtk.Entry entry_username;

    [GtkChild]
    private Gtk.Entry entry_statusmessage;

    [GtkChild]
    private Gtk.Image image_userimage;

    [GtkChild]
    private Gtk.Label label_id;

    [GtkChild]
    private Gtk.Image image_qr_code;

    [GtkChild]
    private Gtk.FileChooserButton filechooser;

    [GtkChild]
    private Gtk.Button apply;

    private ILogger logger;
    private UserInfo user_info;

    public UserInfoWidget(ILogger logger, UserInfo user_info) {
      logger.d("UserInfoWidget created.");
      this.logger = logger;
      this.user_info = user_info;

      entry_username.text = user_info.get_name();
      entry_statusmessage.text = user_info.get_status_message();
      image_userimage.set_from_pixbuf(user_info.get_image());
      label_id.label = user_info.get_tox_id();

      filechooser.file_set.connect(on_file_selected);
      apply.clicked.connect(on_apply_clicked);
    }

    private void on_apply_clicked() {
      logger.d("on_apply_clicked.");
      user_info.set_name(entry_username.text);
      user_info.set_status_message(entry_statusmessage.text);
      user_info.set_image(image_userimage.pixbuf);
      user_info.info_changed(this);
    }

    private void on_file_selected() {
      logger.d("on_file_selected.");
      try {
        var pixbuf = new Gdk.Pixbuf.from_file_at_scale(filechooser.get_filename(), 100, 100, true);
        image_userimage.set_from_pixbuf(pixbuf);
      } catch (Error e) {
        logger.e("Could not read file: " + e.message);
      }
    }

    ~UserInfoWidget() {
      logger.d("UserInfoWidget destroyed.");
    }
  }
}
