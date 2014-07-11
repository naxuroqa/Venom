/*
 *    AudioManager.vala
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

namespace Venom { 
  public errordomain AudioManagerError {
    INIT
  }

  public struct CallInfo {
    bool active;
    bool video;
  }

  public class AudioManager { 

    private const string PIPELINE_IN      = "audioPipelineIn";
    private const string AUDIO_SOURCE_IN  = "audioSourceIn";
    private const string AUDIO_SINK_IN    = "audioSinkIn";

    private const string PIPELINE_OUT     = "audioPipelineOut";
    private const string AUDIO_SOURCE_OUT = "audioSourceOut";
    private const string AUDIO_SINK_OUT   = "audioSinkOut";

    private const int CHUNK_SIZE = 1024; 
    private const int SAMPLE_RATE = 44100;
    private const string AUDIO_CAPS = "audio/x-raw-int,channels=1,rate=48000,signed=true,width=16,depth=16,endianness=1234";

    private const int MAX_CALLS = 16;
    private CallInfo[] calls = new CallInfo[MAX_CALLS];

    private Gst.Pipeline pipeline_in;
    private Gst.AppSrc   audio_source_in;
    private Gst.Element  audio_sink_in;

    private Gst.Pipeline pipeline_out;
    private Gst.Element  audio_source_out;
    private Gst.AppSink  audio_sink_out;

    private Thread<int> av_thread = null;
    private bool running = false;
    private int number_of_calls = 0;

    private ToxSession _tox_session = null;
    private unowned ToxAV.ToxAV toxav = null;
    public ToxSession tox_session {
      get {
        return _tox_session;
      } set {
        _tox_session = value;
        toxav = _tox_session.toxav_handle;
        register_callbacks();
      }
    }

    public static AudioManager instance {get; private set;}

    public static void init() throws AudioManagerError {
      instance = new AudioManager({"","--gst-debug-level=3"});
    }

    private AudioManager(string[] args) throws AudioManagerError {
      // Initialize Gstreamer
      try {
        if(!Gst.init_check(ref args)) {
          throw new AudioManagerError.INIT("Gstreamer initialization failed.");
        }
      } catch (Error e) {
        throw new AudioManagerError.INIT(e.message);
      }
      stdout.printf("Gstreamer initialized\n");

      // input pipeline
      pipeline_in  = new Gst.Pipeline(PIPELINE_IN);
      audio_source_in = (Gst.AppSrc)Gst.ElementFactory.make("appsrc", AUDIO_SOURCE_IN);
      audio_sink_in   = Gst.ElementFactory.make("autoaudiosink", AUDIO_SINK_IN);
      pipeline_in.add_many (audio_source_in, audio_sink_in);
      audio_source_in.link(audio_sink_in);

      // output pipeline
      pipeline_out = new Gst.Pipeline(PIPELINE_OUT);
      audio_source_out = Gst.ElementFactory.make("autoaudiosrc", AUDIO_SOURCE_OUT);
      audio_sink_out   = (Gst.AppSink)Gst.ElementFactory.make("appsink", AUDIO_SINK_OUT);
      pipeline_out.add_many(audio_source_out, audio_sink_out);
      audio_source_out.link(audio_sink_out);

      // caps
      Gst.Caps caps = Gst.Caps.from_string(AUDIO_CAPS);
      stdout.printf("Caps is [%s]\n", caps.to_string());
      audio_source_in.caps = caps;
      audio_sink_out.caps = caps;
    }

    public static void audio_receive_callback(ToxAV.ToxAV toxav, int32 call_index, int16[] frames) {
      stdout.printf("Got audio frames, of size: %d\n", frames.length * 2);
      //instance.buffer_in(frames, frames.length);
    }

    public static void video_receive_callback(ToxAV.ToxAV toxav, int32 call_index, Vpx.Image frame) {
    }

    public void register_callbacks() {
      toxav.register_audio_recv_callback(audio_receive_callback);
      toxav.register_video_recv_callback(video_receive_callback);
    }

    public void destroy_audio_pipeline() {
      pipeline_out.set_state(Gst.State.NULL);
      pipeline_out.set_state(Gst.State.NULL);
      stdout.printf("Pipeline destroyed\n");
    }

    public void set_pipeline_paused() {
      pipeline_in.set_state(Gst.State.PAUSED);
      pipeline_out.set_state(Gst.State.PAUSED);
      stdout.printf("Pipeline set to paused\n");
    }

    public void set_pipeline_playing() {
      pipeline_out.set_state(Gst.State.PLAYING);
      stdout.printf("Pipeline set to playing\n");
      pipeline_in.set_state(Gst.State.PLAYING);
    }

    public void buffer_in(int16[] buffer, int buffer_size) {
      int len = int.min(buffer_size * 2, buffer.length * 2);
      Gst.Buffer gst_buf = new Gst.Buffer.and_alloc(len);
      gst_buf.make_writable();
      Memory.copy(gst_buf.data, buffer, len);

      audio_source_in.push_buffer(gst_buf);
      stdout.printf("pushed %i bytes to IN pipeline\n", len);
      return;
    }

    public int buffer_out(int16[] dest) {
      Gst.Buffer gst_buf = audio_sink_out.pull_buffer();
      int len = int.min(gst_buf.data.length, dest.length * 2);
      Memory.copy(dest, gst_buf.data, len);
      stdout.printf("pulled %i bytes from OUT pipeline\n", len);
      return len / 2;
    }

    private int av_thread_fun() {
      stdout.printf("starting av thread...\n");
      set_pipeline_playing();
      int perframe = (int)(ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000;
      int buffer_size;
      int16[] buffer = new int16[perframe];
      uint8[] enc_buffer = new uint8[perframe*2];
      int prep_frame_ret = 0;
      ToxAV.AV_Error send_audio_ret;

      stdout.printf("buffer size (bytes): %i\n", buffer.length);
      stdout.printf("enc_buffer size (bytes): %i\n", enc_buffer.length * 2);
      while(running) {
        // read samples from pipeline
        buffer_size = buffer_out(buffer);
        if(buffer_size <= 0) {
          stdout.printf("Could not read samples from pipeline!\n");
          Thread.usleep(1000);
          continue;
        }
        // distribute samples across peers
        for(int i = 0; i < MAX_CALLS; i++) {
          if(calls[i].active) {

            //FIXME should be this but returns -1
            prep_frame_ret = toxav.prepare_audio_frame(i, enc_buffer, buffer, buffer.length);
            if(prep_frame_ret <= 0) {
              stdout.printf("prepare_audio_frame returned an error: %i\n", prep_frame_ret);
              continue;
            }

            send_audio_ret = toxav.send_audio(i, enc_buffer, prep_frame_ret);
            if(send_audio_ret != ToxAV.AV_Error.NONE) {
              stdout.printf("send_audio returned %d\n", send_audio_ret);
            }
          }
        }
      }

      stdout.printf("stopping av thread...\n");
      set_pipeline_paused();
      return 0;
    }

    public void on_start_call(Contact c) {
      ToxAV.CallType call_type = tox_session.get_peer_transmission_type(c);

      if(!tox_session.prepare_transmission(c, call_type)) {
        stderr.printf("Could not prepare AV transmission!\n");
        return;
      }

      calls[c.call_index].active = true;
      calls[c.call_index].video = false;
      number_of_calls++;

      if(!running) {
        running = true;
        av_thread = new GLib.Thread<int>("toxavthread", this.av_thread_fun);
      }
    }

    public void on_end_call(Contact c) {
      if(!running) {
        stdout.printf("No av thread running\n");
        return;
      }

      calls[c.call_index].active = false;
      number_of_calls--;

      if(number_of_calls == 0) {
        stdout.printf("number of calls is 0, stopping av thread...\n");
        running = false;
      }
    }

  }
}

