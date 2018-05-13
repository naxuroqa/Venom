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
  public class ToxAdapterSelfListenerImpl : ToxAdapterSelfListener, UserInfoViewListener, GLib.Object {
    private unowned ToxSession session;
    private ILogger logger;
    private UserInfo user_info;
    private GLib.File avatar_file;
    private GLib.Cancellable avatar_cancellable;

    public ToxAdapterSelfListenerImpl(ILogger logger, UserInfo user_info) {
      logger.d("ToxAdapterSelfListenerImpl created.");
      this.logger = logger;
      this.user_info = user_info;
      this.avatar_cancellable = new Cancellable();
    }

    ~ToxAdapterSelfListenerImpl() {
      logger.d("ToxAdapterSelfListenerImpl destroyed.");
    }

    public virtual void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_session_listener(this);

      user_info.tox_id = Tools.bin_to_hexstring(session.self_get_address());

      var public_key = Tools.bin_to_hexstring(session.self_get_public_key());
      var avatar_file_path = GLib.Path.build_filename(R.constants.avatars_folder(), public_key + ".png");
      avatar_file = GLib.File.new_for_path(avatar_file_path);

      get_user_info();
    }

    public virtual void set_self_name(string name) throws GLib.Error {
      session.self_set_user_name(name);
      user_info.name = name;
      user_info.info_changed();
    }

    public virtual void set_self_status_message(string status_message) throws GLib.Error {
      session.self_set_status_message(status_message);
      user_info.status_message = status_message;
      user_info.info_changed();
    }

    public virtual void set_self_avatar(Gdk.Pixbuf pixbuf) throws GLib.Error {
      logger.d("ToxAdapterSelfListenerImpl set_self_avatar");
      avatar_cancellable.cancel();
      avatar_cancellable.reset();
      uint8[] buf;
      pixbuf.save_to_buffer(out buf, "png");
      //var hash = session.hash(buf);
      var bytes = new Bytes(buf);
      avatar_file.replace_contents_bytes_async.begin(bytes, null, false, GLib.FileCreateFlags.REPLACE_DESTINATION, avatar_cancellable);

      user_info.avatar = pixbuf;
      user_info.custom_avatar = true;
      user_info.info_changed();
    }

    public virtual void reset_self_avatar() throws GLib.Error {
      logger.d("ToxAdapterSelfListenerImpl reset_self_avatar");
      avatar_cancellable.cancel();
      avatar_cancellable.reset();
      if (user_info.custom_avatar) {
        if (avatar_file.query_exists()) {
          avatar_file.delete_async.begin(GLib.Priority.DEFAULT, avatar_cancellable);
        }

        user_info.avatar = pixbuf_from_resource(R.icons.default_contact, 128);
        user_info.custom_avatar = false;
        user_info.info_changed();
      }
    }

    private async void load_avatar(Cancellable? cancellable = null) {
      try {
        var stream = avatar_file.read(cancellable);
        user_info.avatar = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, 128, 128, true, cancellable);
        user_info.custom_avatar = true;
        user_info.info_changed();
      } catch (GLib.Error e) {
        logger.e("Can not load avatar: " + e.message);
      }
    }

    private void get_user_info() {
      user_info.name = session.self_get_name();
      user_info.status_message = session.self_get_status_message();
      user_info.user_status = session.self_get_user_status();
      if (avatar_file.query_exists()) {
        load_avatar.begin(avatar_cancellable);
      } else {
        user_info.info_changed();
      }
    }

    public void on_self_connection_status_changed(bool is_connected) {
      user_info.is_connected = is_connected;
      user_info.info_changed();
    }

    public void self_set_user_status(UserStatus status) {
      session.self_set_user_status(status);
      user_info.user_status = status;
      user_info.info_changed();
    }
  }
}
