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
    bool shutdown;
    bool startup;
    bool active;
    bool video;
  }

  public class AudioManager { 

    private const string PIPELINE_IN        = "audioPipelineIn";
    private const string AUDIO_SOURCE_IN    = "audioSourceIn";
    private const string AUDIO_SINK_IN      = "audioSinkIn";

    private const string PIPELINE_OUT       = "audioPipelineOut";
    private const string AUDIO_SOURCE_OUT   = "audioSourceOut";
    private const string AUDIO_SINK_OUT     = "audioSinkOut";

    private const string VIDEO_PIPELINE_IN  = "videoPipelineIn";
    private const string VIDEO_SOURCE_IN    = "videoSourceIn";
    private const string VIDEO_SINK_IN      = "videoSinkIn";
    
    private const string VIDEO_PIPELINE_OUT = "videoPipelineOut";
    private const string VIDEO_SOURCE_OUT   = "videoSourceOut";
    private const string VIDEO_SINK_OUT     = "videoSinkOut";  

    private const int CHUNK_SIZE = 1024; 
    private const int SAMPLE_RATE = 44100;
    private const string AUDIO_CAPS = "audio/x-raw-int,channels=1,rate=48000,signed=true,width=16,depth=16,endianness=1234";
    private const string VIDEO_CAPS = "vide/x-raw-yuv,height=640,width=480,framerate=24/1";

    private const int MAX_CALLS = 16;
    private CallInfo[] calls = new CallInfo[MAX_CALLS];

    private Gst.Pipeline pipeline_in;
    private Gst.AppSrc   audio_source_in;
    private Gst.Element  audio_sink_in;

    private Gst.Pipeline pipeline_out;
    private Gst.Element  audio_source_out;
    private Gst.AppSink  audio_sink_out;

    private Gst.Pipeline video_pipeline_in;
    private Gst.AppSrc  video_source_in;
    private Gst.Element  video_sink_in;

    private Gst.Pipeline video_pipeline_out;
    private Gst.Element  video_source_out;
    private Gst.AppSink  video_sink_out;

    private Thread<int> av_thread = null;
    private bool running = false;

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
      instance = new AudioManager({""/*,"--gst-debug-level=3"*/});
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
      Logger.log(LogLevel.INFO, "Gstreamer initialized");

      // input audio pipeline
      pipeline_in  = new Gst.Pipeline(PIPELINE_IN);
      audio_source_in = (Gst.AppSrc)Gst.ElementFactory.make("appsrc", AUDIO_SOURCE_IN);
      audio_sink_in   = Gst.ElementFactory.make("openalsink", AUDIO_SINK_IN);
      pipeline_in.add_many (audio_source_in, audio_sink_in);
      audio_source_in.link(audio_sink_in);

      // output audio pipeline
      pipeline_out = new Gst.Pipeline(PIPELINE_OUT);
      audio_source_out = Gst.ElementFactory.make("pulsesrc", AUDIO_SOURCE_OUT);
      audio_sink_out   = (Gst.AppSink)Gst.ElementFactory.make("appsink", AUDIO_SINK_OUT);
      pipeline_out.add_many(audio_source_out, audio_sink_out);
      audio_source_out.link(audio_sink_out);

      // input video pipeline
      video_pipeline_in  = new Gst.Pipeline(VIDEO_PIPELINE_IN);
      video_source_in = (Gst.AppSrc)Gst.ElementFactory.make("appsrc", VIDEO_SOURCE_IN);
      video_sink_in   = Gst.ElementFactory.make("autovideosink", VIDEO_SINK_IN);
      video_pipeline_in.add_many (video_source_in, video_sink_in);
      video_source_in.link(video_sink_in);

      // output video pipeline
      video_pipeline_out  = new Gst.Pipeline(VIDEO_PIPELINE_OUT);
      video_source_out = Gst.ElementFactory.make("v4l2src", VIDEO_SOURCE_OUT);
      video_sink_out   = (Gst.AppSink)Gst.ElementFactory.make("appsink", VIDEO_SINK_OUT);
      video_pipeline_out.add_many (video_source_out, video_sink_out);
      video_source_out.link(video_sink_out);

      // caps
      Gst.Caps caps  = Gst.Caps.from_string(AUDIO_CAPS);
      Gst.Caps vcaps = Gst.Caps.from_string(VIDEO_CAPS);
      Logger.log(LogLevel.INFO, "Caps is [" + caps.to_string() + "]");

      audio_source_in.caps = caps;
      audio_sink_out.caps  = caps;

      video_source_in.caps  = vcaps;
      video_sink_out.caps = vcaps;

      ((Gst.BaseSrc)audio_source_out).blocksize = (ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000 * 2;
      ((Gst.BaseSrc)video_source_out).blocksize = (ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000 * 2;

    }
    ~AudioManager() {
      running = false;
      if(av_thread != null) {
        av_thread.join();
      }
    }

    public static void audio_receive_callback(ToxAV.ToxAV toxav, int32 call_index, int16[] frames) {
      Logger.log(LogLevel.DEBUG, "Got audio frames, of size: %d".printf(frames.length * 2));
      instance.buffer_in(frames, frames.length);
    }

    public static void video_receive_callback(ToxAV.ToxAV toxav, int32 call_index, Vpx.Image frame) { 
      Logger.log(LogLevel.DEBUG, "Got video frame, of size: %d".printf(frame.img_data.length));    
      instance.video_buffer_in(frame.img_data, frame.img_data.length);
    }

    public void register_callbacks() {
      toxav.register_audio_recv_callback(audio_receive_callback);
      toxav.register_video_recv_callback(video_receive_callback);
    }

    public void destroy_audio_pipeline() {
      pipeline_in.set_state(Gst.State.NULL);
      pipeline_out.set_state(Gst.State.NULL);
      Logger.log(LogLevel.INFO, "Audio pipeline destroyed");
    }

    public void set_pipeline_paused() {
      pipeline_in.set_state(Gst.State.PAUSED);
      pipeline_out.set_state(Gst.State.PAUSED);
      Logger.log(LogLevel.INFO, "Audio pipeline set to paused");
    }

    public void set_pipeline_playing() {
      pipeline_in.set_state(Gst.State.PLAYING);
      pipeline_out.set_state(Gst.State.PLAYING);
      Logger.log(LogLevel.INFO, "Audio pipeline set to playing");
    }

    public void buffer_in(int16[] buffer, int buffer_size) {
      int len = int.min(buffer_size * 2, buffer.length * 2);
      Gst.Buffer gst_buf = new Gst.Buffer.and_alloc(len);
      Memory.copy(gst_buf.data, buffer, len);

      audio_source_in.push_buffer(gst_buf);
      Logger.log(LogLevel.DEBUG, "pushed %i bytes to IN pipeline".printf(len));
      return;
    }


    //TODO FIXME SOLUTION!!!
    //INSTEAD OF MAKING THIS RETURN LEN / 2 OR WHATEVER, MAKE IT RETURN
    //A BUFFER THAT IT ALLOCS. THAT WAY WE CAN ALLOC EXACTLY THE AMOUNT OF SPACE WE NEED
    //THEN FREE AFTER YOU SEND THE PACKET!!!
    public int buffer_out(/*There will be NO Args*/int16[] dest) {
      Gst.Buffer gst_buf = audio_sink_out.pull_buffer();
      //Allocate the new buffer here, we will return this buffer (it is dest)
      int len = int.min(gst_buf.data.length, dest.length * 2);
      Memory.copy(dest, gst_buf.data, len);
      Logger.log(LogLevel.DEBUG, "pulled %i bytes from OUT pipeline".printf(len));
      return len / 2;
    }


    public void video_buffer_in(uint8[] buffer, int buffer_size) { 
       int len = int.min(buffer_size, buffer.length);
       Gst.Buffer gst_buf = new Gst.Buffer.and_alloc(len);
       Memory.copy(gst_buf.data, buffer, len);

       video_source_in.push_buffer(gst_buf);
       Logger.log(LogLevel.DEBUG, "pushed %i bytes to VIDEO_IN pipeline".printf(len));
       return;
    }

    public uint8[] video_buffer_out() { 
        Gst.Buffer gst_buf = video_sink_out.pull_buffer();
        uint8[] return_buffer = (uint8[])malloc(sizeof(uint8) * gst_buf.data.length);
        Memory.copy(return_buffer, gst_buf.data, gst_buf.data.length);
        Logger.log(LogLevel.DEBUG, "pulled %i bytes form VIDEO_OUT pipeline".printf(gst_buf.data.length));
        return return_buffer;
    }

    private int av_thread_fun() {
      Logger.log(LogLevel.INFO, "starting av thread...");
      set_pipeline_playing();
      int perframe = (int)(ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000;
      int buffer_size;
      int16[] buffer = new int16[perframe];
      uint8[] enc_buffer = new uint8[perframe*2];
      int prep_frame_ret = 0;
      ToxAV.AV_Error send_audio_ret;
      //ToxAV.AV_Error send_video_ret;
      int number_of_calls = 0;

      while(running) {
        // read samples from pipeline
        //TODO THIS LINE NEEDS TO CHANGE TO BE A INT16[] GOTTEN FROM BUFFER_OUT(NO ARGS);
        buffer_size = buffer_out(buffer);
        if(buffer_size <= 0) {
          Logger.log(LogLevel.WARNING, "Could not read samples from audio pipeline!");
          Thread.usleep(1000);
          continue;
        }

        // distribute samples across peers
        for(int i = 0; i < MAX_CALLS; i++) {
          if(calls[i].shutdown && calls[i].active) {
            Logger.log(LogLevel.DEBUG, "Shutting down av transmission %i".printf(i));
            ToxAV.AV_Error e = toxav.kill_transmission(i);
            if(e != ToxAV.AV_Error.NONE) {
              Logger.log(LogLevel.FATAL, "Could not shutdown AV transmission: %i".printf((int)e));
            }
            number_of_calls--;
            calls[i].active = false;
            calls[i].shutdown = false;
          }
          if(calls[i].startup && !calls[i].active) {
            Logger.log(LogLevel.DEBUG, "Starting av transmission %i".printf(i));
            calls[i].startup = false;
            ToxAV.CodecSettings t_settings = ToxAV.DefaultCodecSettings;
            ToxAV.AV_Error e = toxav.prepare_transmission(i, ref t_settings, ToxAV.CallType.AUDIO);
            if(e != ToxAV.AV_Error.NONE) {
              Logger.log(LogLevel.FATAL, "Could not prepare AV transmission: %i".printf((int)e));
            } else {
              number_of_calls++;
              calls[i].active = true;
            }
          }
          if(calls[i].active) {
            prep_frame_ret = toxav.prepare_audio_frame(i, enc_buffer, buffer, buffer_size);
            if(prep_frame_ret <= 0) {
              Logger.log(LogLevel.WARNING, "prepare_audio_frame returned an error: %i".printf(prep_frame_ret));
            } else {
              send_audio_ret = toxav.send_audio(i, enc_buffer, prep_frame_ret);
              if(send_audio_ret != ToxAV.AV_Error.NONE) {
                Logger.log(LogLevel.WARNING, "send_audio returned %d".printf(send_audio_ret));
              }
            }
            
           // if(true/*THIS SHOULD BE if(VIDEO) but I don't know what variable that is*/) { 
           //   prep_frame_ret = toxav.prepare_video_frame(i, enc_buffer, buffer, buffer_size);
           //   if(prep_frame_ret <= 0) { 
           //     Logger.log(LogLevel.WARNING, "prepare_video_frame returned an error: %i".printf(prep_frame_ret));
           //   } else { 
           //     send_video_ret = toxav.send_video(i, enc_buffer, prep_frame_ret);
           //     if(send_video_ret != ToxAV.AV_Error.NONE) { 
           //       Logger.log(LogLevel.WARNING, "send_video returned %d".printf(send_video_ret));
           //     }
           //   } 
           // }
          
        }

        if(number_of_calls <= 0) {
          Logger.log(LogLevel.INFO, "No remaining calls, stopping audio thread.");
          number_of_calls = 0;
          running = false;
        }
      }
    }

      Logger.log(LogLevel.INFO, "stopping audio thread...");
      set_pipeline_paused();
      return 0;
  }
   

    public void on_start_call(Contact c) {

      calls[c.call_index].startup = true;
      calls[c.call_index].video = false;

      if(!running) {
        running = true;
        av_thread = new GLib.Thread<int>("toxavthread", this.av_thread_fun);
      }
    }

    public void on_end_call(Contact c) {
      if(!running) {
        Logger.log(LogLevel.INFO, "No av thread running");
        return;
      }

      calls[c.call_index].shutdown = true;
    }

  }
}
