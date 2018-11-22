/*
 *    Photobooth.vala
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
  public class Photobooth : Gtk.Box {
    public int timeout { get; set; default = 3; }
    public signal void new_photo(Gdk.Pixbuf pixbuf);

#if ENABLE_GSTREAMER
    private Gst.Pipeline pipeline;
    private Gtk.Widget video_area;
    private Gtk.Label counter;
    private Gtk.Box counter_box;
    private Gtk.Overlay overlay;
    private uint timeout_id = 0;
    private int time_left;
    private Gst.Element sink;

    public Photobooth() {
      setup_gtk_widgets();
    }

    public override void realize() {
      base.realize();
      if (sink == null) {
        setup_gst_pipeline();
        overlay.add(video_area);
        overlay.show_all();

        start();
      }
    }

    public void start() {
      pipeline.set_state(Gst.State.PLAYING);
    }

    public void stop() {
      pipeline.set_state(Gst.State.NULL);
    }

    ~Photobooth() {
      if (pipeline != null) {
        pipeline.set_state(Gst.State.NULL);
        pipeline = null;
      }
      if (timeout_id > 0) {
        GLib.Source.remove(timeout_id);
      }
    }

    private void setup_gtk_widgets() {
      overlay = new Gtk.Overlay();

      counter = new Gtk.Label(null);
      counter.margin = 6;

      counter_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
      counter_box.get_style_context().add_class("osd");
      counter_box.valign = counter_box.halign = Gtk.Align.CENTER;
      counter_box.no_show_all = true;
      counter_box.visible = false;
      counter_box.pack_start(counter, false, false);

      var picture_button = new Gtk.Button.with_label(_("Take picture"));
      picture_button.halign = Gtk.Align.CENTER;
      picture_button.valign = Gtk.Align.END;
      picture_button.get_style_context().add_class("osd");
      picture_button.border_width = 24;
      picture_button.clicked.connect(take_picture_with_timeout);

      overlay.add_overlay(picture_button);
      overlay.add_overlay(counter_box);
      pack_start(overlay);
    }

    private void setup_gst_pipeline () {
      pipeline = new Gst.Pipeline(null);

      var src = Gst.ElementFactory.make("v4l2src", null);
      var cvt = Gst.ElementFactory.make("videoconvert", null);
      sink = Gst.ElementFactory.make("gtksink", null);

      pipeline.add_many(src, cvt, sink);

      src.link(cvt);
      cvt.link(sink);

      sink.@get("widget", out video_area);
    }

    private Gdk.Pixbuf sample_to_pixbuf(Gst.Sample sample) {
      var caps = sample.get_caps();
      unowned Gst.Structure structure = caps.get_structure(0);
      int width, height;
      structure.get_int("width", out width);
      structure.get_int("height", out height);
      var buffer = sample.get_buffer();
      Gst.MapInfo info;
      buffer.map(out info, Gst.MapFlags.READ);
      var surface = new Cairo.ImageSurface.for_data(info.data, Cairo.Format.ARGB32, width, height, width * 4);
      return Gdk.pixbuf_get_from_surface(surface, 0, 0, width, height);
    }

    private void take_picture() {
      Gst.Sample sample;
      sink.@get("last-sample", out sample);
      var pixbuf = sample_to_pixbuf(sample);
      new_photo(pixbuf);
    }

    private bool timeout_function() {
      time_left--;
      counter.label = @"$time_left";
      if (time_left <= 0) {
        timeout_id = 0;
        counter_box.visible = false;
        take_picture();
        return false;
      }
      return true;
    }

    private void take_picture_with_timeout() {
      if (timeout <= 0) {
        take_picture();
        return;
      }
      if (timeout_id == 0) {
        time_left = timeout;
        counter_box.no_show_all = false;
        counter_box.show_all();
        counter.label = @"$time_left";

        timeout_id = GLib.Timeout.add(1000, timeout_function);
      }
    }
#else
    public void start() {}
    public void stop() {}
#endif
  }
}
