/*
 *    ToxAVTest.vala
 *
 *    Copyright (C) 2013-2018  Venom authors and contributors
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
/*
 * Using example code from https://wiki.gnome.org/Projects/Vala/GStreamerSample
 */

using Gtk;
using Gst;

public class VideoSample : Window {

  private ToxCore.Tox tox;
  private ToxAV.ToxAV tox_av;
  private Pipeline pipeline;
  private Widget video_area;
  private uint timeout_id;

  construct {
    destroy.connect(kill);

    setup_gst_pipeline();
    create_widgets();
    create_tox();

    pipeline.set_state(State.PLAYING);
  }

  ~VideoSample() {
    stdout.printf("[LOG] VideoSample destructed.\n");
  }

  private void kill() {
    Source.remove(timeout_id);
    main_quit();
  }

  private void create_widgets () {
    set_default_size(800, 600);
    var vbox = new Box(Orientation.VERTICAL, 0);
    vbox.pack_start(video_area);

    var play_button = new Button.from_icon_name("media-playback-start-symbolic", IconSize.BUTTON);
    var stop_button = new Button.from_icon_name("media-playback-stop-symbolic", IconSize.BUTTON);
    var quit_button = new Button.from_icon_name("application-exit-symbolic", IconSize.BUTTON);

    play_button.clicked.connect(on_play);
    stop_button.clicked.connect(on_stop);
    quit_button.clicked.connect(close);

    var bb = new ButtonBox(Orientation.HORIZONTAL);
    bb.add(play_button);
    bb.add(stop_button);
    bb.add(quit_button);
    vbox.pack_end(bb, false);

    add(vbox);
  }

  private void setup_gst_pipeline () {
    pipeline = new Pipeline("avtestpipeline");

    var src = ElementFactory.make("videotestsrc", null);
    var sink = ElementFactory.make("gtksink", null);
    sink.get("widget", out video_area);

    var asrc = ElementFactory.make("audiotestsrc", null);
    var asink = ElementFactory.make("autoaudiosink", null);

    pipeline.add_many(src, sink, asrc, asink);
    src.link(sink);
    asrc.link(asink);
  }

  private void create_tox() {
    var err_options = ToxCore.ErrOptionsNew.OK;
    var options = new ToxCore.Options(ref err_options);
    if (err_options != ToxCore.ErrOptionsNew.OK) {
      stderr.printf("[FTL] Could not create options: %s\n", err_options.to_string());
      assert_not_reached();
    }

    var err = ToxCore.ErrNew.OK;
    tox = new ToxCore.Tox(options, ref err);
    if (err != ToxCore.ErrNew.OK) {
      stderr.printf("[FTL] Could not create instance: %s\n", err.to_string());
      assert_not_reached();
    }

    tox.callback_friend_request(on_friend_request);

    var err_av = ToxAV.ErrNew.OK;
    tox_av = new ToxAV.ToxAV(tox, ref err_av);
    if (err_av != ToxAV.ErrNew.OK) {
      stderr.printf("[FTL] Could not create av instance: %s\n", err_av.to_string());
      assert_not_reached();
    }

    tox_av.callback_call(on_call);
    tox_av.callback_call_state(on_call_state);
    tox_av.callback_bit_rate_status(on_bit_rate_status);
    tox_av.callback_video_receive_frame(on_video_receive_frame);
    tox_av.callback_audio_receive_frame(on_audio_receive_frame);

    var address = tox.self_get_address();
    stdout.printf("[LOG] Tox ID: %s\n", Venom.Tools.bin_to_hexstring(address));
    var err_info = ToxCore.ErrSetInfo.OK;
    if (!tox.self_set_name("AV Test bot", ref err_info)) {
      stderr.printf("[FTL] Could not set name: %s\n", err_info.to_string());
      assert_not_reached();
    }

    var ip_string = "node.tox.biribiri.org";
    var pub_key_string = "F404ABAA1C99A9D37D61AB54898F56793E1DEF8BD46B1038B9D822E8460FAB67";
    var port = 33445;
    var pub_key = Venom.Tools.hexstring_to_bin(pub_key_string);

    var err_bootstrap = ToxCore.ErrBootstrap.OK;
    if (!tox.bootstrap(ip_string, (uint16) port, pub_key, ref err_bootstrap)) {
      stderr.printf("[ERR] Bootstrapping failed: %s\n", err_bootstrap.to_string());
      assert_not_reached();
    }
    stdout.printf("[LOG] Bootstrapped.\n");

    var connected = false;
    timeout_id = Timeout.add(tox.iteration_interval(), () => {
      if (tox.self_get_connection_status() != ToxCore.Connection.NONE) {
        if (!connected) {
          connected = true;
          stdout.printf("[LOG] Connected.\n");
        }
      } else {
        if (connected) {
          connected = false;
          stdout.printf("[LOG] Disconnected.\n");
        }
      }

      tox.iterate(this);
      tox_av.iterate();
      return true;
    });
  }

  private string friend_get_name(uint32 friend_number) {
    var err = ToxCore.ErrFriendQuery.OK;
    var name = tox.friend_get_name(friend_number, ref err);
    return err != ToxCore.ErrFriendQuery.OK ? "FRIEND #%u".printf(friend_number) : name;
  }

  private void on_call(ToxAV.ToxAV self, uint32 friend_number, bool audio_enabled, bool video_enabled) {
    stdout.printf("[LOG] on_call from %s: audio_enabled: %s, video_enabled: %s\n", friend_get_name(friend_number), audio_enabled.to_string(), video_enabled.to_string());
  }

  private void on_call_state(ToxAV.ToxAV self, uint32 friend_number, ToxAV.FriendCallState state) {
    stdout.printf("[LOG] on_call_state %s: %i\n", friend_get_name(friend_number), state);
  }

  private void on_bit_rate_status(ToxAV.ToxAV self, uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate) {
    stdout.printf("[LOG] on_bit_rate_status %s: audio_bit_rate: %u, video_bit_rate: %u\n", friend_get_name(friend_number), audio_bit_rate, video_bit_rate);
  }

  private void on_audio_receive_frame(ToxAV.ToxAV self, uint32 friend_number, int16[] pcm, uint8 channels, uint32 sampling_rate) {
    stdout.printf("[LOG] on_audio_receive_frame %s: channels: %u, sampling_rate: %u\n", friend_get_name(friend_number), channels, sampling_rate);
  }

  private void on_video_receive_frame(ToxAV.ToxAV self, uint32 friend_number, uint16 width, uint16 height, uint8[] y, uint8[] u, uint8[] v, int32 ystride, int32 ustride, int32 vstride) {
    stdout.printf("[LOG] on_video_receive_frame %s: width: %u, height: %u\n", friend_get_name(friend_number), width, height);
  }

  private static void on_friend_request(ToxCore.Tox tox, uint8[] key, uint8[] message, void* user_data) {
    stdout.printf("[LOG] Friend request from %s received: %s\n", Venom.Tools.bin_to_hexstring(key), (string) message);
    var error = ToxCore.ErrFriendAdd.OK;
    tox.friend_add_norequest(key, ref error);
    if (error != ToxCore.ErrFriendAdd.OK) {
      stderr.printf("[ERR] Friend could not be added: %s\n", error.to_string());
    }
  }

  private void on_play () {
    pipeline.set_state(State.PLAYING);
  }

  private void on_stop () {
    pipeline.set_state(State.READY);
  }

  public static int main (string[] args) {
    Gst.init(ref args);
    Gtk.init(ref args);

    var sample = new VideoSample();
    sample.show_all();

    Gtk.main();

    return 0;
  }
}
