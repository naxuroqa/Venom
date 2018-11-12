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
  public interface ToxSessionThread : GLib.Object {
    public abstract void start();
    public abstract void stop();
  }

  public class ToxSessionThreadImpl : ToxSessionThread, Object {
    private unowned ToxSessionImpl session;
    private unowned Gee.Iterable<DhtNode> bootstrap_nodes;
    private Logger logger;
    private bool running;
    private bool bootstrapped;
    private Thread<int> session_thread = null;

    public ToxSessionThreadImpl(ToxSessionImpl session, Logger logger, Gee.Iterable<DhtNode> bootstrap_nodes) {
      this.session = session;
      this.logger = logger;
      this.bootstrap_nodes = bootstrap_nodes;
      this.running = false;
      this.bootstrapped = false;
      logger.d("ToxSessionThread created.");
    }

    ~ToxSessionThreadImpl() {
      stop();
      logger.d("ToxSessionThread destroyed.");
    }

    // Background thread main function
    private int run() {
      logger.i("Background thread started.");

      if (!bootstrapped) {
        logger.d("Connecting to DHT Nodes:");
        session.@lock();
        foreach (var dht_node in bootstrap_nodes) {
          if (dht_node.is_blocked) {
            continue;
          }
          logger.d("  %s".printf(dht_node.to_string()));
          var bootstrap_err = ToxCore.ErrBootstrap.OK;
          var ret = session.handle.bootstrap(dht_node.host, (uint16) dht_node.port, Tools.hexstring_to_bin(dht_node.pub_key), out bootstrap_err);
          if (bootstrap_err != ToxCore.ErrBootstrap.OK || !ret) {
            logger.i("Connecting to node %s failed: %s".printf(dht_node.to_string(), bootstrap_err.to_string()));
          }
        }
        session.unlock();
        bootstrapped = true;
      }

      var status = false;
      var newStatus = false;
      while (running) {
        session.@lock();
        newStatus = (session.handle.self_get_connection_status() != Connection.NONE);
        session.unlock();
        if (newStatus && !status) {
          logger.i("Connection to dht node established.");
        } else if (!newStatus && status) {
          logger.i("Connection to dht node lost.");
        }
        status = newStatus;

        session.@lock();
        session.handle.iterate(session);
        session.unlock();
        Thread.usleep(session.handle.iteration_interval() * 1000);
      }

      logger.i("Background thread stopped.");
      return 0;
    }

    // Start the background thread
    public void start() {
      if (running) {
        return;
      }
      running = true;
      session_thread = new Thread<int>("worker", run);
    }

    // Stop background thread
    public void stop() {
      running = false;
      join();
      session_thread = null;
    }

    // Wait for background thread to finish
    private void join() {
      if (session_thread != null) {
        session_thread.join();
      }
    }
  }
}
