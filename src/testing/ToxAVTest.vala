/*
 *    ToxAVTest.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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

    private Tox.Tox tox;
    private ToxAV.ToxAV tox_av;
    private DrawingArea drawing_area;
    private Pipeline pipeline;
    private Element src;
    private Element asrc;
    private Element sink;
    private Element asink;
    private ulong xid;

    public VideoSample () {
        create_widgets ();
        setup_gst_pipeline ();
        create_tox ();
    }

    private void create_widgets () {
        var vbox = new Box (Orientation.VERTICAL, 0);
        this.drawing_area = new DrawingArea ();
        this.drawing_area.realize.connect(on_realize);
        vbox.pack_start (this.drawing_area, true, true, 0);

        var play_button = new Button.from_stock (Stock.MEDIA_PLAY);
        play_button.clicked.connect (on_play);
        var stop_button = new Button.from_stock (Stock.MEDIA_STOP);
        stop_button.clicked.connect (on_stop);
        var quit_button = new Button.from_stock (Stock.QUIT);
        quit_button.clicked.connect (Gtk.main_quit);

        var bb = new ButtonBox (Orientation.HORIZONTAL);
        bb.add (play_button);
        bb.add (stop_button);
        bb.add (quit_button);
        vbox.pack_start (bb, false, true, 0);

        add (vbox);
        destroy.connect(() => {Gtk.main_quit();});
    }

    private void setup_gst_pipeline () {
        this.pipeline = new Pipeline ("mypipeline");
#if OSX
        GLib.assert_not_reached();
#elif WIN32
        GLib.assert_not_reached();
#elif UNIX
        this.src = ElementFactory.make ("v4l2src", "video");
        this.asrc = ElementFactory.make("pulsesrc", "audio");
        //this.src = ElementFactory.make ("videotestsrc", "video");
        //this.asrc = ElementFactory.make("audiotestsrc", "audio");
        this.sink = ElementFactory.make ("xvimagesink", "sink");
        this.asink = ElementFactory.make("autoaudiosink", "asink");
#else
        GLib.assert_not_reached();
#endif
        this.pipeline.add_many (this.src, this.asrc, this.sink, this.asink);
        this.src.link (this.sink);
        this.asrc.link(this.asink);
    }
    private void on_realize() {
#if OSX
        GLib.assert_not_reached();
#elif WIN32
        GLib.assert_not_reached();
#elif UNIX
        this.xid = (ulong)Gdk.X11Window.get_xid(this.drawing_area.get_window());
#else
        GLib.assert_not_reached();
#endif
    }

    private void create_tox() {
      tox = new Tox.Tox(0);
      tox.callback_friend_request(on_friend_request);
      ToxAV.CodecSettings settings = ToxAV.DefaultCodecSettings;
      tox_av = new ToxAV.ToxAV(tox, settings);

      ToxAV.register_callstate_callback(on_toxav_invite         , ToxAV.CallbackID.INVITE);
      ToxAV.register_callstate_callback(on_toxav_start          , ToxAV.CallbackID.START);
      ToxAV.register_callstate_callback(on_toxav_cancel         , ToxAV.CallbackID.CANCEL);
      ToxAV.register_callstate_callback(on_toxav_reject         , ToxAV.CallbackID.REJECT);
      ToxAV.register_callstate_callback(on_toxav_end            , ToxAV.CallbackID.END);
      ToxAV.register_callstate_callback(on_toxav_ringing        , ToxAV.CallbackID.RINGING);
      ToxAV.register_callstate_callback(on_toxav_starting       , ToxAV.CallbackID.STARTING);
      ToxAV.register_callstate_callback(on_toxav_ending         , ToxAV.CallbackID.ENDING);
      ToxAV.register_callstate_callback(on_toxav_error          , ToxAV.CallbackID.ERROR);
      ToxAV.register_callstate_callback(on_toxav_request_timeout, ToxAV.CallbackID.REQUEST_TIMEOUT);
      ToxAV.register_callstate_callback(on_toxav_peer_timeout   , ToxAV.CallbackID.PEER_TIMEOUT);

      uint8[] buf = new uint8[Tox.FRIEND_ADDRESS_SIZE];
      tox.get_address(buf);
      stdout.printf("[LOG] Tox ID: %s\n", Venom.Tools.bin_to_hexstring(buf));
      tox.set_name("AV Test".data);

      bool bootstrapped = false;
      bool connected = false;
      GLib.Timeout.add(25, () => {
        if(!bootstrapped) {
          tox.bootstrap_from_address("66.175.223.88",
            0,
            ((uint16)33445).to_big_endian(),
            Venom.Tools.hexstring_to_bin("B24E2FB924AE66D023FE1E42A2EE3B432010206F751A2FFD3E297383ACF1572E")
          );
          bootstrapped = true;
          print("[LOG] Bootstrapped.\n");
        }
        if(tox.isconnected() != 0) {
          if(!connected) {
            connected = true;
            print("[LOG] Connected.\n");
          }
        } else {
          if(connected) {
            connected = false;
            print("[LOG] Disconnected.\n");
          }
        }

        tox.do();
        return true;
      });
    }

    private void on_friend_request(Tox.Tox tox, uint8[] key, uint8[] data) {
      print("[LOG] Friend request from %s received.\n", Venom.Tools.bin_to_hexstring(key));
      int friend_number = tox.add_friend_norequest(key);
      if(friend_number < 0) {
        print("[ERR] Friend could not be added.\n");
      }
    }

    private void on_toxav_invite() {
      print("[LOG] on_toxav_invite\n");
    }
    private void on_toxav_start() {
      print("[LOG] on_toxav_start\n");
    }
    private void on_toxav_cancel() {
      print("[LOG] on_toxav_cancel\n");
    }
    private void on_toxav_reject() {
      print("[LOG] on_toxav_reject\n");
    }
    private void on_toxav_end() {
      print("[LOG] on_toxav_end\n");
    }
    private void on_toxav_ringing() {
      print("[LOG] on_toxav_ringing\n");
    }
    private void on_toxav_starting() {
      print("[LOG] on_toxav_starting\n");
    }
    private void on_toxav_ending() {
      print("[LOG] on_toxav_ending\n");
    }
    private void on_toxav_error() {
      print("[LOG] on_toxav_error\n");
    }
    private void on_toxav_request_timeout() {
      print("[LOG] on_toxav_request_timeout\n");
    }
    private void on_toxav_peer_timeout() {
      print("[LOG] on_toxav_peer_timeout\n");
    }

    private void on_play () {
        var xoverlay = this.sink as XOverlay;
        xoverlay.set_xwindow_id (this.xid);
        this.pipeline.set_state (State.PLAYING);
    }

    private void on_stop () {
        this.pipeline.set_state (State.READY);
    }

    public static int main (string[] args) {
        Gst.init (ref args);
        Gtk.init (ref args);

        var sample = new VideoSample ();
        sample.show_all ();

        Gtk.main ();

        return 0;
    }
}
