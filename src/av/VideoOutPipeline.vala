/*
 *    VideoOutPipeline.vala
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
  public class VideoOutPipeline : Pipeline, GLib.Object {
    private Gst.Pipeline pipeline = new Gst.Pipeline(null);
    private Gst.App.Src app_src;
    private Gst.Element gtk_sink;
    private bool playing;

    public VideoOutPipeline() {
      app_src = (Gst.App.Src) Gst.ElementFactory.make("appsrc", null);
      var videoconvert = Gst.ElementFactory.make("videoconvert", null);
      gtk_sink = Gst.ElementFactory.make("gtksink", null);

      pipeline.add_many(app_src, videoconvert, gtk_sink);
      app_src.link_many(videoconvert, gtk_sink);
    }
    public void start() {
      playing = true;
      pipeline.set_state(Gst.State.PLAYING);
    }
    public void stop() {
      playing = false;
      pipeline.set_state(Gst.State.NULL);
    }
    public void push_sample(Gst.Sample sample) {
      app_src.push_sample(sample);
    }
    public Gtk.Widget create_gtk_widget() {
      Gtk.Widget widget;
      gtk_sink.@get("widget", out widget);
      return widget;
    }
  }
}
