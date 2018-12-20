/*
 *    AudioInPipeline.vala
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
  public class AudioInPipeline : BasePipeline {
    public double level {get; set;}

    private Gst.App.Sink app_sink;
    private Gst.Element tee;
    private uint watch_id = 0;
    private Gst.Element src;

    public AudioInPipeline() {
      base("Source/Audio");

      capsfilter = Gst.ElementFactory.make("capsfilter", null);
      capsfilter.@set("caps", Gst.Caps.from_string("audio/x-raw"));
      tee = Gst.ElementFactory.make("tee", null);
      var queue = Gst.ElementFactory.make("queue", null);
      var audioconvert = Gst.ElementFactory.make("audioconvert", null);
      var level = Gst.ElementFactory.make("level", null);
      var fakesink = Gst.ElementFactory.make("fakesink", null);
      level.@set("post-messages", true);
      var bus = pipeline.get_bus();
      watch_id = bus.add_watch(GLib.Priority.DEFAULT, message_handler);

      pipeline.add_many(capsfilter, tee, queue, audioconvert, level, fakesink);
      capsfilter.link_many(tee, queue, audioconvert, level, fakesink);
    }
    ~AudioInPipeline() {
      if (watch_id != 0) {
        GLib.Source.remove(watch_id);
      }
    }
    protected override Gst.Element create_default_element() {
      return Gst.ElementFactory.make("autoaudiosrc", null);
    }
    private bool message_handler (Gst.Bus bus, Gst.Message message) {
      if (message.type == Gst.MessageType.ELEMENT) {
        unowned Gst.Structure structure = message.get_structure();
        if (structure.get_name() == "level") {
          unowned GLib.Value level_value = structure.get_value("peak");
          unowned GLib.ValueArray value_array = (GLib.ValueArray) level_value.get_boxed();
          double level_sum = 0;
          foreach (var val in value_array) {
            level_sum += val.get_double();
          }
          level = Math.pow(10, (level_sum / value_array.n_values) / 20);
        }
      }
      return GLib.Source.CONTINUE;
    }
    public Gst.App.Sink create_app_sink() {
      if (app_sink == null) {
        var queue = Gst.ElementFactory.make("queue", null);
        var audioresample = Gst.ElementFactory.make("audioresample", null);
        var audioconvert = Gst.ElementFactory.make("audioconvert", null);
        app_sink = Gst.ElementFactory.make("appsink", null) as Gst.App.Sink;
        app_sink.@set("emit-signals", true);
        app_sink.@set("drop", true);
        app_sink.@set("caps", Gst.Caps.from_string("audio/x-raw,format=S16LE,rate=48000,channels=1"));
        pipeline.add_many(queue, audioresample, audioconvert, app_sink);
        tee.link_many(queue, audioresample, audioconvert, app_sink);
      }
      return app_sink;
    }
  }
}
