/*
 *    ToxAVThread.vala
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

using ToxCore;

namespace Venom {
  public class DefaultToxAVThread : ToxBaseThread {
    unowned ToxAV.ToxAV tox_av;
    GLib.Source main_source;

    public DefaultToxAVThread(Logger logger, ToxAV.ToxAV tox_av) {
      base("DefaultToxAVThread", logger);
      this.tox_av = tox_av;
      logger.d("DefaultToxAVThread created.");
    }

    ~DefaultToxAVThread() {
      logger.d("DefaultToxAVThread destroyed.");
    }

    protected override void start_loop() {
      do_loop();
    }

    protected override void stop_loop() {
      var source = new GLib.IdleSource();
      source.set_callback(() => {
        if (main_source != null) {
          main_source.destroy();
          main_source = null;
        }
        worker_loop.quit();
        return GLib.Source.REMOVE;
      });
      source.attach(worker_context);
    }

    private bool do_loop() {
      if (running) {
        tox_av.iterate();

        main_source = new GLib.TimeoutSource(tox_av.iteration_interval());
        main_source.set_callback(do_loop);
        main_source.attach(worker_context);
      }
      return GLib.Source.REMOVE;
    }
  }
}
