/*
 *    R.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
  public sealed class R {
    private R() {}

    private static IconResource _icons;
    private static StringResource _strings;
    private static ConstantsResource _constants;

    public static IconResource icons {
      get {
        if (_icons == null) {
          _icons = new IconResource();
        }
        return _icons;
      }
    }

    public static StringResource strings {
      get {
        if (_strings == null) {
          _strings = new StringResource();
        }
        return _strings;
      }
    }

    public static ConstantsResource constants {
      get {
        if (_constants == null) {
          _constants = new ConstantsResource();
        }
        return _constants;
      }
    }

    public sealed class IconResource {
      public string app { get { return "venom-symbolic"; } }

      public string idle { get { return "idle-symbolic"; } }
      public string busy { get { return "busy-symbolic"; } }
      public string offline { get { return "offline-symbolic"; } }
      public string online { get { return "online-symbolic"; } }

      public string default_contact { get { return "friend-symbolic"; } }
      public string default_groupchat { get { return "conference-symbolic"; } }
    }

    public sealed class StringResource {
      public string default_username() { return _("Tox User"); }
      public string default_statusmessage() { return ""; }
      public string db_filename() { return "tox.db"; }
    }

    public sealed class ConstantsResource {
      public string icons_prefix() { return "/im/tox/venom/icons/scalable/status/"; }
      public string icons_suffix() { return ".svg"; }
      public string app_id() { return "im.tox.venom"; }
      public string tox_about() { return "https://tox.chat/about.html"; }
    }
  }
}
