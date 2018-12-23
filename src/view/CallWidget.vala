/*
 *    CallWidget.vala
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
 *    Venom is distributed in the hope that it will be useful
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Venom.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Venom {
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/call_widget.ui")]
  public class CallWidget : Gtk.Window, MediaReceiver {
    [GtkChild] private Gtk.Button hang_up;
    [GtkChild] private Gtk.ToggleButton video_toggle;
    [GtkChild] private Gtk.ToggleButton audio_toggle;
    [GtkChild] private Gtk.Box remote_box;
    [GtkChild] private Gtk.Box local_box;
    [GtkChild] private Gtk.Label timer_label;

    private GLib.Timer timer;
    private uint timer_source;
    private Logger logger;
    private IContact contact;
    private CallState call_state;
    private CallWidgetListener listener;

    private VideoInPipeline video_in_pipeline;
    private VideoOutPipeline video_out_pipeline;
    private AudioInPipeline audio_in_pipeline;
    private AudioOutPipeline audio_out_pipeline;

    private Gst.App.Sink audio_app_sink;
    private Gst.App.Sink video_app_sink;

    public CallWidget(Logger logger, IContact contact, CallWidgetListener listener) {
      logger.d("CallWidget created.");
      this.logger = logger;
      this.contact = contact;
      this.listener = listener;
      this.call_state = listener.get_call_state(contact);

      video_in_pipeline = new VideoInPipeline();
      video_out_pipeline = new VideoOutPipeline();
      audio_in_pipeline = new AudioInPipeline();
      audio_out_pipeline = new AudioOutPipeline();

      audio_app_sink = audio_in_pipeline.create_app_sink();
      audio_app_sink.new_sample.connect(on_new_audio_sample);

      video_app_sink = video_in_pipeline.create_app_sink();
      video_app_sink.new_sample.connect(on_new_video_sample);

      var remote = video_out_pipeline.create_gtk_widget();
      remote_box.pack_start(remote);

      var local = video_in_pipeline.create_gtk_widget();
      local_box.pack_start(local);

      call_state.media_receiver = this;
      hang_up.clicked.connect(on_hang_up);
      call_state.notify["in-call"].connect(call_state_changed);
      destroy.connect(on_hang_up);
      timer = new GLib.Timer();

      video_toggle.active = call_state.local_video;
      audio_toggle.active = call_state.local_audio;

      video_toggle.toggled.connect(toggle_video);
      audio_toggle.toggled.connect(toggle_audio);

      update_contact_details();
      contact.changed.connect(update_contact_details);

      destroy.connect(() => {
        if (timer_source != 0) {
          GLib.Source.remove(timer_source);
          timer_source = 0;
        }
      });
    }

    private void update_contact_details() {
      title = _("In call with %s").printf(contact.get_name_string());
    }

    private void toggle_video() {
      if (video_toggle.active) {
        video_in_pipeline.start();
      } else {
        video_in_pipeline.stop();
      }
    }

    private void toggle_audio() {
      if (audio_toggle.active) {
        audio_in_pipeline.start();
      } else {
        audio_in_pipeline.stop();
      }
    }

    private bool update_timer() {
      var t = timer.elapsed();
      var h = (int) t / 3600;
      t = t % 3600;
      var m = (int) t / 60;
      t = t % 60;
      var s = (int) t;
      timer_label.label = h > 0 ? "%02u:%02u:%02u".printf(h, m, s) : "%02u:%02u".printf(m, s);

      return GLib.Source.CONTINUE;
    }

    private Gst.FlowReturn on_new_audio_sample() {
      // logger.d("CallWidget on_new_audio_sample()");
      var sample = audio_app_sink.pull_sample();
      try {
        listener.send_audio_sample(contact, sample);
      } catch (Error e) {
        logger.d("Sending audio sample failed: " + e.message);
      }
      return Gst.FlowReturn.OK;
    }

    private Gst.FlowReturn on_new_video_sample() {
      // logger.d("CallWidget on_new_video_sample()");
      var sample = video_app_sink.pull_sample();
      try {
        listener.send_video_sample(contact, sample);
      } catch (Error e) {
        logger.d("Sending video sample failed: " + e.message);
      }
      return Gst.FlowReturn.OK;
    }

    public override void realize() {
      logger.d("CallWidget realize()");
      base.realize();
      if (call_state.local_audio) {
        audio_in_pipeline.start();
      }
      if (call_state.local_video) {
        video_in_pipeline.start();
      }
      video_out_pipeline.start();
      audio_out_pipeline.start();

      timer.start();
      timer_source = GLib.Timeout.add(500, update_timer);
    }

    ~CallWidget() {
      logger.d("CallWidget destroyed.");
    }

    private void tear_down() {
      logger.d("CallWidget tear_down()");
      on_hang_up();
      destroy();
    }

    private void call_state_changed() {
      logger.d(@"CallWidget call_state_changed($(call_state.in_call))");
      if (!call_state.in_call) {
        tear_down();
      }
    }

    private void on_hang_up() {
      logger.d("on_hang_up()");
      if (contact.is_connected() && call_state.in_call) {
        listener.stop_call(contact);
      }
      video_in_pipeline.stop();
      video_out_pipeline.stop();
      audio_in_pipeline.stop();
      audio_out_pipeline.stop();
      call_state.media_receiver = null;
    }

    public void push_audio_sample(Gst.Sample audio_sample) {
      audio_out_pipeline.push_sample(audio_sample);
    }

    public void push_video_sample(Gst.Sample video_sample) {
      video_out_pipeline.push_sample(video_sample);
    }
  }

  public interface CallWidgetListener : GLib.Object {
    public abstract void call(IContact contact, bool audio, bool video) throws Error;
    public abstract void answer(IContact contact) throws Error;
    public abstract void stop_call(IContact contact) throws Error;

    public abstract CallState get_call_state(IContact contact);

    public abstract void send_audio_sample(IContact contact, Gst.Sample sample) throws Error;
    public abstract void send_video_sample(IContact contact, Gst.Sample sample) throws Error;
  }
}
