/*
 *    VideoInPipeline.vala
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
  public class VideoInPipeline : BasePipeline {
    Gst.App.Sink app_sink;
    Gst.Element gtk_sink;
    Gst.Element tee;

    int framerate;
    int width;
    int height;

    public VideoInPipeline() {
      base("Source/Video");
      capsfilter = Gst.ElementFactory.make("capsfilter", null);
      capsfilter.@set("caps", Gst.Caps.from_string("video/x-raw,framerate=30/1"));
      tee = Gst.ElementFactory.make("tee", null);

      pipeline.add_many(capsfilter, tee);
      capsfilter.link(tee);
    }

    public Gtk.Widget create_gtk_widget() {
      if (gtk_sink == null) {
        var queue = Gst.ElementFactory.make("queue", null);
        var cvt = Gst.ElementFactory.make("videoconvert", null);
        gtk_sink = Gst.ElementFactory.make("gtksink", null);
        gtk_sink.@set("sync", false);
        pipeline.add_many(queue, cvt, gtk_sink);
        tee.link_many(queue, cvt, gtk_sink);
      }

      Gtk.Widget widget;
      gtk_sink.@get("widget", out widget);
      return widget;
    }

    public Gst.App.Sink create_app_sink() {
      if (app_sink == null) {
        var queue = Gst.ElementFactory.make("queue", null);
        var cvt = Gst.ElementFactory.make("videoconvert", null);
        app_sink = Gst.ElementFactory.make("appsink", null) as Gst.App.Sink;
        app_sink.@set("emit-signals", true);
        app_sink.@set("drop", true);
        app_sink.@set("caps", Gst.Caps.from_string("video/x-raw,format=I420"));
        pipeline.add_many(queue, cvt, app_sink);
        tee.link_many(queue, cvt, app_sink);
      }
      return app_sink;
    }

    protected override Gst.Element create_default_element() {
      return Gst.ElementFactory.make("autovideosrc", null);
    }
  }
}
