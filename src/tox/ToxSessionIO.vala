/*
 *    ToxSessionIO.vala
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

  public interface ToxSessionIO : GLib.Object {
    public abstract uint8[] ? load_sessiondata();
    public abstract void save_sessiondata(uint8[] sessiondata);
  }

  public class ToxSessionIOImpl : ToxSessionIO, GLib.Object {
    private ILogger logger;

    public ToxSessionIOImpl(ILogger logger) {
      this.logger = logger;
    }

    public virtual uint8[] ? load_sessiondata() {
      var file = File.new_for_path(R.constants.tox_data_filename());
      uint8[] contents;
      string etag_out;
      try {
        file.load_contents(null, out contents, out etag_out);
      } catch (Error e) {
        logger.i("could not read tox savefile: " + e.message);
        return null;
      }
      return contents;
    }

    public virtual void save_sessiondata(uint8[] sessiondata) {
      var file = File.new_for_path(R.constants.tox_data_filename());
      try {
        file.replace_contents(sessiondata, null, false, FileCreateFlags.NONE, null, null);
      } catch (Error e) {
        logger.f("Saving tox session data failed: " + e.message);
      }
    }
  }
}
