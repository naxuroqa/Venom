/*
 *    VideoSendBot.vala
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

public class VideoSendBot : Gtk.Window {
  private const string savefile_name = "videobot.tox";

  private ToxCore.Tox tox;
  private ToxAV.ToxAV tox_av;
  private Gst.Pipeline pipeline;
  private uint tox_timeout_id;
  private uint tox_av_timeout_id;
  private bool connected;
  private Gst.App.Sink sink;
  private uint32 connected_contact;
  private bool in_call;
  private Gtk.Widget gtksink_widget;

  public VideoSendBot(string filename) {
    set_default_size(800, 600);
    destroy.connect(kill);
    try {
      // var src = "v4l2src";
      var src = "videotestsrc";
      // var src = "filesrc location=\"$filename\" ! decodebin";
      pipeline = (Gst.Pipeline) Gst.parse_launch(@"$src ! videoconvert ! coloreffects preset=heat ! tee name=t ! queue ! videoconvert ! appsink name=sink emit-signals=true caps=video/x-raw,format=I420,framerate=30/1"
                                                + " t. ! queue ! videoconvert ! gtksink name=gtksink"
      );
      sink = (Gst.App.Sink) pipeline.get_by_name("sink");
      sink.new_sample.connect(on_new_sample);

      var gtksink = pipeline.get_by_name("gtksink");
      gtksink.get("widget", out gtksink_widget);
      add(gtksink_widget);
    } catch (Error e) {
      stderr.printf("[FATAL] Could not initialize pipeline\n");
      assert_not_reached();
    }
    create_tox();
  }

  ~VideoSendBot() {
    stdout.printf("[LOG] VideoSendBot destructed.\n");
  }

  private void kill() {
    if (tox_timeout_id > 0) {
      Source.remove(tox_timeout_id);
    }
    if (tox_av_timeout_id > 0) {
      Source.remove(tox_av_timeout_id);
    }
    save_tox();
    tox_av = null;
    tox = null;
    Gtk.main_quit();
  }

  private void create_tox() {
    var err_options = ToxCore.ErrOptionsNew.OK;
    var options = new ToxCore.Options(out err_options);
    if (err_options != ToxCore.ErrOptionsNew.OK) {
      stderr.printf("[FATAL] Could not create options: %s\n", err_options.to_string());
      assert_not_reached();
    }
    uint8[] data;
    if (GLib.FileUtils.test(savefile_name, GLib.FileTest.EXISTS)) {
      try {
        GLib.FileUtils.get_data(savefile_name, out data);
        options.set_savedata_data(data);
        options.savedata_type = ToxCore.SaveDataType.TOX_SAVE;
      } catch (Error e) {
        stdout.printf("[WARN] Could not load tox data file: %s\n", e.message);
      }
    } else {
      stdout.printf("[LOG] Tox data file does not exist, creating new one.\n");
    }

    var err = ToxCore.ErrNew.OK;
    tox = new ToxCore.Tox(options, out err);
    if (err != ToxCore.ErrNew.OK) {
      stderr.printf("[FATAL] Could not create instance: %s\n", err.to_string());
      assert_not_reached();
    }

    tox.callback_friend_request(on_friend_request);
    tox.callback_self_connection_status(on_self_connection_status);

    var err_av = ToxAV.ErrNew.OK;
    tox_av = new ToxAV.ToxAV(tox, out err_av);
    if (err_av != ToxAV.ErrNew.OK) {
      stderr.printf("[FATAL] Could not create av instance: %s\n", err_av.to_string());
      assert_not_reached();
    }

    tox_av.callback_call(on_call);
    tox_av.callback_call_state(on_call_state);
    tox_av.callback_video_receive_frame(on_video_receive_frame);
    tox_av.callback_audio_receive_frame(on_audio_receive_frame);

    var address = tox.self_get_address();
    stdout.printf("[LOG] Tox ID: %s\n", bin_to_hex(address));
    var err_info = ToxCore.ErrSetInfo.OK;
    if (!tox.self_set_name("AV Test bot", out err_info)) {
      stderr.printf("[FATAL] Could not set name: %s\n", err_info.to_string());
      assert_not_reached();
    }

    var pub_key_string = "2C289F9F37C20D09DA83565588BF496FAB3764853FA38141817A72E3F18ACA0B";
    var pub_key = hex_to_bin(pub_key_string);

    var err_bootstrap = ToxCore.ErrBootstrap.OK;
    if (!tox.bootstrap("163.172.136.118", (uint16) 33445, pub_key, out err_bootstrap)) {
      stderr.printf("[FATAL] Bootstrapping failed: %s\n", err_bootstrap.to_string());
      assert_not_reached();
    }
    stdout.printf("[LOG] Bootstrapped.\n");

    timeout_tox_loop();
    timeout_tox_av_loop();
  }

  private bool timeout_tox_loop() {
    tox.iterate(this);
    tox_timeout_id = Timeout.add(tox.iteration_interval(), timeout_tox_loop);
    return false;
  }

  private bool timeout_tox_av_loop() {
    tox_av.iterate();
    tox_av_timeout_id = Timeout.add(tox_av.iteration_interval(), timeout_tox_av_loop);
    return false;
  }

  private void save_tox() {
    try {
      var savedata = tox.get_savedata();
      GLib.FileUtils.set_data(savefile_name, savedata);
    } catch (Error e) {
      error("Can not save tox data file: " + e.message);
    }
  }

  private string friend_get_name(uint32 friend_number) {
    var err = ToxCore.ErrFriendQuery.OK;
    var name = tox.friend_get_name(friend_number, out err);
    return err != ToxCore.ErrFriendQuery.OK ? "FRIEND #%u".printf(friend_number) : name;
  }

  private void on_call(ToxAV.ToxAV self, uint32 friend_number, bool audio_enabled, bool video_enabled) {
    stdout.printf("[LOG] on_call from %s: audio_enabled: %s, video_enabled: %s\n", friend_get_name(friend_number), audio_enabled.to_string(), video_enabled.to_string());
    if (in_call) {
      stdout.printf("[LOG] already in call, ignoring...\n");
      return;
    }

    stdout.printf("[LOG] answering call...\n");
    var err_answer = ToxAV.ErrAnswer.OK;
    tox_av.answer(friend_number, 0, 5000, out err_answer);
    if (err_answer != ToxAV.ErrAnswer.OK) {
      stderr.printf("[ERR] Error answering call: %s\n", err_answer.to_string());
      return;
    }
    in_call = true;
    connected_contact = friend_number;
    pipeline.set_state(Gst.State.PLAYING);
  }

  private void on_call_state(ToxAV.ToxAV self, uint32 friend_number, ToxAV.FriendCallState state) {
    stdout.printf("[LOG] on_call_state %s: %s\n", friend_get_name(friend_number), state.to_string());
    if (in_call && connected_contact == friend_number && (state == ToxAV.FriendCallState.FINISHED || state == ToxAV.FriendCallState.ERROR)) {
      stdout.printf("[LOG] call finished\n");
      in_call = false;
      pipeline.set_state(Gst.State.READY);
    }
  }

  private void on_audio_receive_frame(ToxAV.ToxAV self, uint32 friend_number, int16[] pcm, size_t sample_count, uint8 channels, uint32 sampling_rate) {
    stdout.printf("[LOG] on_audio_receive_frame %s: channels: %u, sampling_rate: %u\n", friend_get_name(friend_number), channels, sampling_rate);
  }

  private void on_video_receive_frame(ToxAV.ToxAV self, uint32 friend_number, uint16 width, uint16 height, uint8[] y, uint8[] u, uint8[] v, int32 ystride, int32 ustride, int32 vstride) {
    stdout.printf("[LOG] on_video_receive_frame %s: width: %u, height: %u\n", friend_get_name(friend_number), width, height);
  }

  private Gst.FlowReturn on_new_sample() {
    stdout.printf("[LOG] on_new_sample\n");
    var sample = sink.pull_sample();
    var buffer = sample.get_buffer();
    var caps = sample.get_caps();
    stdout.printf("[LOG] Caps: %s\n", caps.to_string());
    var info = new Gst.Video.Info();
    info.from_caps(caps);
    Gst.MapInfo map_info;
    buffer.map(out map_info, Gst.MapFlags.READ);

    int[] strides = {info.width, info.width / 2, info.width / 2};
    int[] heights = {info.height, info.height / 2, info.height / 2};
    int[] sizes = {strides[0]*heights[0], strides[1]*heights[1], strides[2]*heights[2]};
    var y = new uint8[sizes[0]];
    var u = new uint8[sizes[1]];
    var v = new uint8[sizes[2]];
    uint8*[] planes = {y, u, v};
    for (var i = 0; i < planes.length; i++) {
      for (var j = 0; j < heights[i]; j++) {
        GLib.Memory.copy(planes[i] + j * strides[i], (uint8*) map_info.data + j * info.stride[i] + info.offset[i], strides[i]);
      }
    }
    buffer.unmap(map_info);
    var err = ToxAV.ErrSendFrame.OK;
    tox_av.video_send_frame(connected_contact, (uint16) info.width, (uint16) info.height, y, u, v, out err);
    if (err != ToxAV.ErrSendFrame.OK) {
      stdout.printf("[WARN] Could not send sample: %s\n", err.to_string());
    }
    return Gst.FlowReturn.OK;
  }

  private static void on_self_connection_status(ToxCore.Tox self, ToxCore.Connection connection, void* user_data) {
    VideoSendBot _this = (VideoSendBot) user_data;
    _this.connected = connection != ToxCore.Connection.NONE;
    stdout.printf(_this.connected ? "[LOG] Connected.\n" : "[LOG] Disconnected.\n");
  }

  private static void on_friend_request(ToxCore.Tox self, uint8[] key, uint8[] message, void* user_data) {
    stdout.printf("[LOG] Friend request from %s received: %s\n", bin_to_hex(key), (string) message);
    self.friend_add_norequest(key, null);
  }

  private static string bin_to_hex(uint8[] bin) requires(bin.length != 0) {
    var b = new StringBuilder();
    for (var i = 0; i < bin.length; ++i) {
      b.append("%02X".printf(bin[i]));
    }
    return b.str;
  }

  private static uint8[] hex_to_bin(string hex) {
    var buf = new uint8[hex.length / 2];
    var b = 0;
    for (int i = 0; i < buf.length; ++i) {
      hex.substring(2 * i, 2).scanf("%02x", ref b);
      buf[i] = (uint8) b;
    }
    return buf;
  }

  public static int main (string[] args) {
    if (args.length != 2) {
      stdout.printf("Usage: %s <filename>\n", args[0]);
      return -1;
    }

    Gst.init(ref args);
    Gtk.init(ref args);

    var sample = new VideoSendBot(args[1]);
    sample.show_all();

    Gtk.main();

    return 0;
  }
}
