/*
 *    UserInfoViewModel.vala
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
  public class UserInfoViewModel : GLib.Object {
    public string username { get; set; }
    public string statusmessage { get; set; }
    public Gdk.Pixbuf userimage { get; set; }
    public string tox_id { get; set; }
    public Gdk.Pixbuf tox_qr_code { get; set; }
    public string filename { get; set; }

    private ILogger logger;
    private UserInfo user_info;

    public UserInfoViewModel(ILogger logger, UserInfo user_info) {
      logger.d("UserInfoViewModel created.");
      this.logger = logger;
      this.user_info = user_info;

      username = user_info.name;
      statusmessage = user_info.status_message;
      userimage = user_info.image;
      tox_id = user_info.tox_id;
      filename = "";
    }

    public void on_apply_clicked() {
      logger.d("on_apply_clicked.");
      user_info.name = username;
      user_info.status_message = statusmessage;
      user_info.image = userimage;
      user_info.info_changed(this);
    }

    public void on_file_selected() {
      logger.d("on_file_selected.");
      try {
        userimage = new Gdk.Pixbuf.from_file_at_scale(filename, 100, 100, true);
      } catch (Error e) {
        logger.e("Could not read file: " + e.message);
      }
    }

    ~UserInfoViewModel() {
      logger.d("UserInfoViewModel destroyed.");
    }
  }
}
