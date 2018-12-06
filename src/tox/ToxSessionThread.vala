/*
 *    ToxSessionThread.vala
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
  public interface ToxThread : GLib.Object {
    public abstract void start();
    public abstract void stop();
  }
  public abstract class ToxBaseThread : ToxThread, GLib.Object {
    protected string name = "ToxThread";
    // Thread gets freed twice (join + unref) if using reference counting
    // Hopefully this gets fixed in the future
    // For now we have to do resource management manually
    private GLib.Thread<int>* thread = null;
    protected bool running;
    protected Logger logger;

    protected GLib.MainContext worker_context;
    protected GLib.MainLoop worker_loop;

    public ToxBaseThread(string name, Logger logger) {
      this.name = name;
      this.logger = logger;
    }

    protected virtual void start_loop() {}
    protected virtual void stop_loop() {}

    public void start() {
      logger.d(name + " start");
      if (running) {
        return;
      }
      running = true;
      thread = new GLib.Thread<int>(null, thread_func);
    }

    private int thread_func() {
      logger.d(name + " thread_func start");
      worker_context = new GLib.MainContext();
      worker_loop = new GLib.MainLoop(worker_context);

      start_loop();

      worker_loop.run();
      logger.d(name + " thread_func end");
      return 0;
    }

    public void stop() {
      logger.d(name + " stop");
      running = false;
      stop_loop();
      if (thread != null) {
        thread->join();
        logger.d(name + " joined");
        thread = null;
      }
    }
  }

  public class ToxSessionThreadImpl : ToxBaseThread {
    private unowned ToxSessionImpl session;
    private Gee.Iterable<DhtNode> bootstrap_nodes;
    private Gee.Iterator<DhtNode> it;
    private GLib.Source main_source;
    private GLib.Source bootstrap_source;

    public ToxSessionThreadImpl(ToxSessionImpl session, Logger logger, Gee.Iterable<DhtNode> bootstrap_nodes) {
      base("ToxSessionThread", logger);
      this.session = session;
      this.it = bootstrap_nodes.iterator();
      logger.d("ToxSessionThread created.");
    }

    ~ToxSessionThreadImpl() {
      logger.d("ToxSessionThread destroyed.");
    }

    private bool do_loop() {
      if (running) {
        session.handle.iterate(session);
        main_source = new GLib.TimeoutSource(session.handle.iteration_interval());
        main_source.set_callback(do_loop);
        main_source.attach(worker_context);
      } else {
        main_source = null;
      }
      return GLib.Source.REMOVE;
    }

    private bool do_bootstrap_loop() {
      if (running) {
        if (it != null && it.next()) {
          var node = it.@get();
          if (!node.is_blocked) {
            logger.d("DHT node %s".printf(node.to_string()));
            var bootstrap_err = ToxCore.ErrBootstrap.OK;
            var ret = session.handle.bootstrap(node.host, (uint16) node.port, Tools.hexstring_to_bin(node.pub_key), out bootstrap_err);
            if (bootstrap_err != ToxCore.ErrBootstrap.OK || !ret) {
              logger.i("Connecting to node %s failed: %s".printf(node.to_string(), bootstrap_err.to_string()));
            }
          }
          bootstrap_source = new GLib.IdleSource();
          bootstrap_source.set_callback(do_bootstrap_loop);
          bootstrap_source.attach(worker_context);
        } else {
          logger.d("Finished bootstrapping.");
          it = null;
          bootstrap_source = null;
        }
      } else {
        bootstrap_source = null;
      }
      return GLib.Source.REMOVE;
    }

    protected override void start_loop() {
      do_loop();

      bootstrap_source = new GLib.TimeoutSource(1000);
      bootstrap_source.set_callback(do_bootstrap_loop);
      bootstrap_source.attach(worker_context);
    }

    protected override void stop_loop() {
      var source = new GLib.IdleSource();
      source.set_callback(() => {
        if (main_source != null) {
          main_source.destroy();
          main_source = null;
        }
        if (bootstrap_source != null) {
          bootstrap_source.destroy();
          bootstrap_source = null;
        }
        worker_loop.quit();
        return GLib.Source.REMOVE;
      });
      source.attach(worker_context);
    }
  }
}
