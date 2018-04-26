/*
 *    ToxAdapterSelfListener.vala
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
  public class ToxAdapterSelfListenerImpl : ToxAdapterSelfListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private UserInfo user_info;

    public ToxAdapterSelfListenerImpl(ILogger logger, UserInfo user_info) {
      logger.d("ToxAdapterSelfListenerImpl created.");
      this.logger = logger;
      this.user_info = user_info;

      user_info.info_changed.connect(on_user_info_changed);
    }

    ~ToxAdapterSelfListenerImpl() {
      logger.d("ToxAdapterSelfListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_session_listener(this);

      user_info.tox_id = Tools.bin_to_hexstring(session.self_get_address());
      get_user_info();
      user_info.info_changed(this);
    }

    private void get_user_info() {
      user_info.name = session.self_get_name();
      user_info.status_message = session.self_get_status_message();
      user_info.user_status = session.self_get_user_status();
    }

    private void on_user_info_changed(GLib.Object sender) {
      if (sender == this) {
        return;
      }

      logger.d("on_user_info_changed.");
      session.self_set_user_name(user_info.name);
      session.self_set_status_message(user_info.status_message);
    }

    public void on_self_connection_status_changed(bool is_connected) {
      user_info.is_connected = is_connected;
      user_info.info_changed(this);
    }

    public void self_set_user_status(UserStatus status) {
      session.self_set_user_status(status);
      user_info.user_status = status;
      user_info.info_changed(this);
    }
  }
}
