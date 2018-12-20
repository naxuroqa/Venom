/*
 *    Pipeline.vala
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
  public interface Pipeline : GLib.Object {
    public abstract void start();
    public abstract void stop();
  }

  public abstract class BasePipeline : GLib.Object, Pipeline {
    public string device_name { get; set; default = "default"; }

    protected Gst.Pipeline pipeline = new Gst.Pipeline(null);
    protected Gst.Element src;
    protected Gst.Element capsfilter;
    protected Gst.DeviceMonitor device_monitor;
    protected bool playing;

    protected BasePipeline(string device_filter) {
      device_monitor = new Gst.DeviceMonitor();
      device_monitor.add_filter(device_filter, null);
    }

    ~BasePipeline() {
    }

    protected GLib.List<Gst.Device>? get_devices() {
      // FIXME
      // Starting the device monitor at startup leads to a race condition
      // and crashes, that's why it's only ever used if needed.
      device_monitor.start();
      var devices = device_monitor.get_devices();
      device_monitor.stop();
      return devices;
    }

    protected Gst.Device? find_device(string device_name) {
      var devices = get_devices();
      foreach (var device in devices) {
        if (device.name == device_name) {
          device_monitor.stop();
          return device;
        }
      }
      return null;
    }

    protected abstract Gst.Element create_default_element();

    protected virtual void reconfigure_device() {
      var was_playing = playing;
      if (playing) {
        stop();
      }

      if (src != null) {
        pipeline.remove(src);
        src = null;
      }

      if (device_name == "default") {
        src = create_default_element();
      } else {
        var device = find_device(device_name);
        if (device != null) {
          src = device.create_element(null);
          src.@ref();
        }
      }

      if (src == null) {
        //FIXME could not configure device
      } else {
        pipeline.add(src);
        src.link(capsfilter);
      }

      if (was_playing) {
        start();
      }
    }

    public virtual void start() {
      if (src == null) {
        reconfigure_device();
      }
      playing = true;
      pipeline.set_state(Gst.State.PLAYING);
    }
    public virtual void stop() {
      playing = false;
      pipeline.set_state(Gst.State.NULL);
    }
  }
}