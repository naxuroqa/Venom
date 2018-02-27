/*
 *    ToxAdapterListener.vala
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
  public class ToxAdapterListenerImpl : ToxAdapterListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private UserInfo user_info;

    public ToxAdapterListenerImpl(ILogger logger, UserInfo user_info) {
      logger.d("ToxAdapterListenerImpl created.");
      this.logger = logger;
      this.user_info = user_info;

      user_info.info_changed.connect(on_user_info_changed);
    }

    ~ToxAdapterListenerImpl() {
      logger.d("ToxAdapterListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_session_listener(this);

      user_info.set_tox_id(Tools.bin_to_hexstring(session.self_get_address()));
      get_user_info();
      user_info.info_changed(this);
    }

    private void get_user_info() {
      user_info.set_name(session.self_get_name());
      user_info.set_status_message(session.self_get_status_message());
    }

    private void on_user_info_changed(GLib.Object sender) {
      if (sender == this) {
        return;
      }

      logger.d("on_user_info_changed.");
      session.self_set_user_name(user_info.get_name());
      session.self_set_status_message(user_info.get_status_message());
    }

    public virtual void on_self_status_changed(UserStatus status) {
      user_info.set_user_status(status);
      user_info.info_changed(this);
    }

    private void set_self_status(UserStatus status) {
      user_info.set_user_status(status);
      user_info.info_changed(this);
    }
  }

  public errordomain LookupError {
    GENERIC
  }
}
