/*
 *    AudioOutPipeline.vala
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
  public class AudioOutPipeline : BasePipeline {
    public double level {get; set;}

    private Gst.App.Src app_src;
    private Gst.Element sink;

    public AudioOutPipeline() {
      base("Sink/Audio");

      app_src = Gst.ElementFactory.make("appsrc", null) as Gst.App.Src;
      var audioresample = Gst.ElementFactory.make("audioresample", null);
      var audioconvert = Gst.ElementFactory.make("audioconvert", null);
      capsfilter = Gst.ElementFactory.make("capsfilter", null);
      capsfilter.@set("caps", Gst.Caps.from_string("audio/x-raw"));

      pipeline.add_many(app_src, audioresample, audioconvert, capsfilter);
      app_src.link_many(audioresample, audioconvert, capsfilter);
    }
    protected override Gst.Element create_default_element() {
      return Gst.ElementFactory.make("autoaudiosink", null);
    }
    protected override void reconfigure_device() {
      var was_playing = playing;
      if (playing) {
        stop();
      }

      if (sink != null) {
        pipeline.remove(sink);
        sink = null;
      }

      if (device_name == "default") {
        sink = create_default_element();
      } else {
        var device = find_device(device_name);
        if (device != null) {
          sink = device.create_element(null);
          sink.@ref();
        }
      }

      if (sink == null) {
        //FIXME could not configure device
      } else {
        pipeline.add(sink);
        capsfilter.link(sink);
      }

      if (was_playing) {
        start();
      }
    }

    public override void start() {
      if (sink == null) {
        reconfigure_device();
      }
      playing = true;
      pipeline.set_state(Gst.State.PLAYING);
    }

    public void push_sample(Gst.Sample sample) {
      app_src.push_sample(sample);
    }
  }
}
