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
    INIT,
    PIPELINE
  }

  public struct CallInfo {
    bool   active;
    bool   video;
    bool   muted;
    int    volume;
  }

  public enum AVStatusChangeType {
    START,
    END,
    MUTE,
    VOLUME
  }

  public struct AVStatusChange {
    AVStatusChangeType type;
    int32 call_index;
    int var1;
  }

  public class AudioManager { 

    private const string PIPELINE_IN        = "audioPipelineIn";
    private const string AUDIO_SOURCE_IN    = "audioSourceIn";
    private const string AUDIO_SINK_IN      = "audioSinkIn";
    private const string AUDIO_VOLUME_IN    = "audioVolumeIn";

    private const string PIPELINE_OUT       = "audioPipelineOut";
    private const string AUDIO_SOURCE_OUT   = "audioSourceOut";
    private const string AUDIO_SINK_OUT     = "audioSinkOut";
    private const string AUDIO_VOLUME_OUT   = "audioVolumeOut";

    private const string VIDEO_PIPELINE_IN  = "videoPipelineIn";
    private const string VIDEO_SOURCE_IN    = "videoSourceIn";
    private const string VIDEO_SINK_IN      = "videoSinkIn";
    
    private const string VIDEO_PIPELINE_OUT = "videoPipelineOut";
    private const string VIDEO_SOURCE_OUT   = "videoSourceOut";
    private const string VIDEO_SINK_OUT     = "videoSinkOut";  

    private const string VIDEO_CAPS = "video/x-raw-yuv,width=640,height=480,framerate=24/1";

    private const int MAX_CALLS = 16;
    CallInfo[] calls = new CallInfo[MAX_CALLS];

    private AsyncQueue<AVStatusChange?> status_changes = new AsyncQueue<AVStatusChange?>();

    private Gst.Pipeline pipeline_in;
    private Gst.AppSrc   audio_source_in;
    private Gst.Element  audio_sink_in;
    private Gst.Element  audio_volume_in;

    private Gst.Pipeline pipeline_out;
    private Gst.Element  audio_source_out;
    private Gst.AppSink  audio_sink_out;
    private Gst.Element  audio_volume_out;

    private Gst.Pipeline video_pipeline_in;
    private Gst.AppSrc   video_source_in;
    private Gst.Element  video_sink_in;

    private Gst.Pipeline video_pipeline_out;
    private Gst.Element  video_source_out;
    private Gst.AppSink  video_sink_out;

    private Thread<int> av_thread = null;
    private bool running = false;

    // settings in use by audio in pipeline
    private ToxAV.CodecSettings current_audio_settings = ToxAV.DefaultCodecSettings;
    // settings in use by out pipeline
    private ToxAV.CodecSettings default_settings = ToxAV.DefaultCodecSettings;
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
#if DEBUG
      instance = new AudioManager({"", "--gst-debug-level=3"});
#else
      instance = new AudioManager({""});
#endif
    }

    public static void free() {
      instance.running = false;
      instance.join();
      instance.destroy_audio_pipeline();
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
      try {
        pipeline_in = Gst.parse_launch("appsrc name=" + AUDIO_SOURCE_IN +
                                    " ! volume name=" + AUDIO_VOLUME_IN +
                                    " ! openalsink name=" + AUDIO_SINK_IN) as Gst.Pipeline;
      } catch (Error e) {
        throw new AudioManagerError.PIPELINE("Error creating the audio input pipeline: " + e.message);
      }
      audio_source_in = pipeline_in.get_by_name(AUDIO_SOURCE_IN) as Gst.AppSrc;
      audio_volume_in = pipeline_in.get_by_name(AUDIO_VOLUME_IN);
      audio_sink_in   = pipeline_in.get_by_name(AUDIO_SINK_IN);

      // output audio pipeline
      try {
        pipeline_out = Gst.parse_launch("pulsesrc name=" + AUDIO_SOURCE_OUT +
                                     " ! volume name=" + AUDIO_VOLUME_OUT +
                                     " ! appsink name=" + AUDIO_SINK_OUT) as Gst.Pipeline;
      } catch (Error e) {
        throw new AudioManagerError.PIPELINE("Error creating the audio output pipeline: " + e.message);
      }
      audio_source_out = pipeline_out.get_by_name(AUDIO_SOURCE_OUT);
      audio_volume_out = pipeline_out.get_by_name(AUDIO_VOLUME_OUT);
      audio_sink_out   = pipeline_out.get_by_name(AUDIO_SINK_OUT) as Gst.AppSink;

      // input video pipeline
      try {
        video_pipeline_in = Gst.parse_launch("appsrc name=" + VIDEO_SOURCE_IN +
                                          " ! autovideosink name=" + VIDEO_SINK_IN) as Gst.Pipeline;
      } catch (Error e) {
        throw new AudioManagerError.PIPELINE("Error creating the video input pipeline: " + e.message);
      }
      video_source_in = video_pipeline_in.get_by_name(VIDEO_SOURCE_IN) as Gst.AppSrc;
      video_sink_in   = video_pipeline_in.get_by_name(VIDEO_SINK_IN);

      // output video pipeline
      try {
        video_pipeline_out = Gst.parse_launch("v4l2src name=" + VIDEO_SOURCE_OUT +
                                           " ! appsink name=" + VIDEO_SINK_OUT) as Gst.Pipeline;
      } catch (Error e) {
        throw new AudioManagerError.PIPELINE("Error creating the video output pipeline: " + e.message);
      }
      video_source_out = video_pipeline_out.get_by_name(VIDEO_SOURCE_OUT);
      video_sink_out   = video_pipeline_out.get_by_name(VIDEO_SINK_OUT) as Gst.AppSink;

      // caps
      Gst.Caps caps  = Gst.Caps.from_string(get_audio_caps_from_codec_settings(ref default_settings));
      Gst.Caps vcaps = Gst.Caps.from_string(VIDEO_CAPS);
      Logger.log(LogLevel.INFO, "Audio caps are [" + caps.to_string() + "]");
      Logger.log(LogLevel.INFO, "Video caps are [" + vcaps.to_string() + "]");

      audio_source_in.caps = caps;
      audio_sink_out.caps  = caps;

      video_source_in.caps = vcaps;
      video_sink_out.caps  = vcaps;

      //audio_sink_out.blocksize = (ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000 * 2;
      //audio_sink_out.drop = true;
      //audio_sink_out.max_buffers = 2;
      //audio_sink_out.max_lateness = 1000; // buffers older than 1 msec will be dropped

      ((Gst.BaseSrc)audio_source_out).blocksize = (ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000 * 2;
      //((Gst.BaseSrc)video_source_out).blocksize = (ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000 * 2;

      Settings.instance.bind_property(Settings.MIC_VOLUME_KEY, audio_volume_out, "volume", BindingFlags.SYNC_CREATE);
    }
    ~AudioManager() {
      running = false;
      if(av_thread != null) {
        av_thread.join();
      }
    }

    private static void audio_receive_callback(ToxAV.ToxAV toxav, int32 call_index, int16[] samples) {
      //Logger.log(LogLevel.DEBUG, "Received audio samples (%d bytes)".printf(samples.length * 2));
      instance.samples_in(call_index, samples);
    }

    private static void video_receive_callback(ToxAV.ToxAV toxav, int32 call_index, Vpx.Image frame) { 
//      Logger.log(LogLevel.DEBUG, "Got video frame, of size: %d".printf(frame.img_data.length));    
      instance.video_buffer_in(frame);
    }

    private void register_callbacks() {
      toxav.register_audio_recv_callback(audio_receive_callback);
      toxav.register_video_recv_callback(video_receive_callback);
    }

    private void destroy_audio_pipeline() {
      pipeline_in.set_state(Gst.State.NULL);
      pipeline_out.set_state(Gst.State.NULL);
      Logger.log(LogLevel.INFO, "Audio pipeline destroyed");
    }

    private void set_audio_pipeline_paused() {
      pipeline_in.set_state(Gst.State.PAUSED);
      pipeline_out.set_state(Gst.State.PAUSED);
      Logger.log(LogLevel.INFO, "Audio pipeline set to paused");
    }

    private void set_audio_pipeline_playing() {
      pipeline_in.set_state(Gst.State.PLAYING);
      pipeline_out.set_state(Gst.State.PLAYING);
      Logger.log(LogLevel.INFO, "Audio pipeline set to playing");
    }
 
    private void set_video_pipeline_playing() { 
      video_pipeline_in.set_state(Gst.State.PLAYING);
      video_pipeline_out.set_state(Gst.State.PLAYING);
      Logger.log(LogLevel.INFO, "Video pipeline set to playing");
    }

    private string get_audio_caps_from_codec_settings(ref ToxAV.CodecSettings settings) {
      return "audio/x-raw-int,channels=(int)%u,rate=(int)%u,signed=(boolean)true,width=(int)16,depth=(int)16,endianness=(int)1234".printf(settings.audio_channels, settings.audio_sample_rate);
    }

    private void samples_in(int32 call_index, int16[] buffer) {
      int len = buffer.length * 2;
      Gst.Buffer gst_buf = new Gst.Buffer.and_alloc(len);
      Memory.copy(gst_buf.data, buffer, len);

      ToxAV.CodecSettings settings = ToxAV.CodecSettings();
      ToxAV.AV_Error ret = toxav.get_peer_csettings(call_index, 0, ref settings);

      gst_buf.duration = -1; // settings.audio_frame_duration * Gst.MSECOND;
      gst_buf.timestamp = -1;

      if(ret != ToxAV.AV_Error.NONE) {
        Logger.log(LogLevel.WARNING, "Could not acquire codec settings for contact %i, assuming default settings".printf(call_index));
        settings = ToxAV.DefaultCodecSettings;
      }

      if(settings.audio_channels != current_audio_settings.audio_channels ||
         settings.audio_sample_rate != current_audio_settings.audio_sample_rate) {
        current_audio_settings = settings;
        string caps_string = get_audio_caps_from_codec_settings(ref settings);
        Logger.log(LogLevel.INFO, "Changing caps to " + caps_string);
        audio_source_in.caps = Gst.Caps.from_string(caps_string);
      }

      audio_source_in.push_buffer(gst_buf);
      //Logger.log(LogLevel.DEBUG, "pushed %i bytes to IN pipeline".printf(len));
      return;
    }

    private int buffer_out(/*There will be NO Args*/int16[] dest) {
      Gst.Buffer gst_buf = audio_sink_out.pull_buffer();
      //Allocate the new buffer here, we will return this buffer (it is dest)
      int len = int.min(gst_buf.data.length, dest.length * 2);
      Memory.copy(dest, gst_buf.data, len);
      //Logger.log(LogLevel.DEBUG, "pulled %i bytes from OUT pipeline".printf(len));
      return len / 2;
    }

    private void video_buffer_in(Vpx.Image frame) { 
       uint len = frame.d_w * frame.d_h * 4;
       Gst.Buffer gst_buf = new Gst.Buffer.and_alloc(len);
       uint8[] tempBuf = new uint8[len];
       int i;
       int j;

       for(i = 0; i < frame.d_h; ++i) { 
         for(j = 0; j < frame.d_w; ++j) { 
           uint8 y = frame.planes[0, ((i * frame.stride[0]) + j)];
           uint8 u = frame.planes[1, (((i / 2) * frame.stride[1]) + (j / 2))];
           uint8 v = frame.planes[2, (((i / 2) * frame.stride[2]) + (j / 2))];
           
           tempBuf += y;
           tempBuf += u;
           tempBuf += v;
         }
      }

      Memory.copy(gst_buf.data, tempBuf, len);
      video_source_in.push_buffer(gst_buf);
      //Logger.log(LogLevel.DEBUG, "pushed %i bytes to VIDEO_IN pipeline".printf(len));
      return;
    }

    private uint8[] video_buffer_out() { 
        Gst.Buffer gst_buf = video_sink_out.pull_buffer();
        uint8[] return_buffer = (uint8[])malloc(sizeof(uint8) * gst_buf.data.length);
        Memory.copy(return_buffer, gst_buf.data, gst_buf.data.length);
        Logger.log(LogLevel.DEBUG, "pulled %i bytes form VIDEO_OUT pipeline".printf(gst_buf.data.length));
        return return_buffer;
    }

    private int av_thread_fun() {
      Logger.log(LogLevel.INFO, "starting av thread...");
      set_audio_pipeline_playing();
      set_video_pipeline_playing();
      int perframe = (int)(ToxAV.DefaultCodecSettings.audio_frame_duration * ToxAV.DefaultCodecSettings.audio_sample_rate) / 1000;
      int buffer_size;
      int16[] buffer = new int16[perframe];
      uint8[] enc_buffer = new uint8[perframe*2];
      ToxAV.AV_Error prep_frame_ret = 0, send_audio_ret = 0, send_video_ret = 0;
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

        // calling try_pop once per cycle should be enough
        AVStatusChange? c = status_changes.try_pop();
        if(c != null) {
          switch(c.type) {
            case AVStatusChangeType.START:
              Logger.log(LogLevel.DEBUG, "Starting av transmission %i".printf(c.call_index));
              ToxAV.AV_Error e = toxav.prepare_transmission(
                c.call_index,
                ToxAV.JITTER_BUFFER_DEFAULT_CAPACITY,
                ToxAV.VAD_DEFAULT_THRESHOLD,
                c.var1 // video support
              );
              if(e != ToxAV.AV_Error.NONE) {
                Logger.log(LogLevel.FATAL, "Could not prepare AV transmission: %s".printf(e.to_string()));
              } else {
                number_of_calls++;
                calls[c.call_index].active = true;
                calls[c.call_index].video = (c.var1 != 0);
              }
              break;
            case AVStatusChangeType.END:
              Logger.log(LogLevel.DEBUG, "Shutting down av transmission %i".printf(c.call_index));
              ToxAV.AV_Error e = toxav.kill_transmission(c.call_index);
              if(e != ToxAV.AV_Error.NONE) {
                Logger.log(LogLevel.FATAL, "Could not shutdown AV transmission: %s".printf(e.to_string()));
              }
              number_of_calls--;
              calls[c.call_index].active = false;
              break;
            case AVStatusChangeType.MUTE:
              Logger.log(LogLevel.DEBUG, (c.var1 == 1) ? "Muting %i".printf(c.call_index) : "Unmuting %i".printf(c.call_index));
              calls[c.call_index].muted = (c.var1 == 1);
              break;
            case AVStatusChangeType.VOLUME:
              calls[c.call_index].volume = c.var1;
              Logger.log(LogLevel.DEBUG, "Set receive volume for %i to %i".printf(c.call_index, c.var1));
              //FIXME this only works for one contact right now
              audio_volume_in.set("volume", ((double)c.var1) / 100.0);
              break;
            default:
              Logger.log(LogLevel.ERROR, "unknown av status change type");
              break;
          }
        }
        
        // distribute samples across peers
        for(int i = 0; i < MAX_CALLS; i++) {
          if(calls[i].active) {
            prep_frame_ret = toxav.prepare_audio_frame(i, enc_buffer, buffer, buffer_size);
            if(prep_frame_ret <= 0) {
              Logger.log(LogLevel.ERROR, "prepare_audio_frame returned an error: %s".printf(prep_frame_ret.to_string()));
            } else {
              send_audio_ret = toxav.send_audio(i, enc_buffer, prep_frame_ret);
              if(send_audio_ret != ToxAV.AV_Error.NONE) {
                Logger.log(LogLevel.ERROR, "send_audio returned %s".printf(send_audio_ret.to_string()));
              }
            }
/*
            if(calls[i].video) {
              buffer_size = buffer_out(buffer);
              if(buffer_size <= 0) {
                Logger.log(LogLevel.WARNING, "Could not read samples from video pipeline!");
              }else { 
                prep_frame_ret = toxav.prepare_video_frame(i, enc_buffer, buffer, buffer_size);
                if(prep_frame_ret <= 0) { 
                   Logger.log(LogLevel.WARNING, "prepare_video_frame returned an error: %i".printf(prep_frame_ret));
                } else {
                  send_video_ret = toxav.send_video(i, enc_buffer, prep_frame_ret);
                  if(send_video_ret != ToxAV.AV_Error.NONE) { 
                    Logger.log(LogLevel.WARNING, "send_video returned %d".printf(send_video_ret));
                  }
                } 
              }
            }
*/
          }
        }

        if(number_of_calls <= 0 && status_changes.length() == 0) {
          Logger.log(LogLevel.INFO, "No remaining calls, stopping audio thread.");
          number_of_calls = 0;
          running = false;
        }
      }

      Logger.log(LogLevel.INFO, "stopping audio thread...");
      set_audio_pipeline_paused();
      return 0;
    }

    public int join() {
      if(av_thread != null) {
        return av_thread.join();
      }
      return -1;
    }

    // functions to control the AV Manager

    public void set_volume(Contact c, int volume) {
      status_changes.push( AVStatusChange() {
        type = AVStatusChangeType.VOLUME,
        call_index = c.call_index,
        var1 = volume
      });
    }

    public void set_mute(Contact c, bool mute) {
      int imute = (mute ? 1 : 0);
      status_changes.push( AVStatusChange() {
        type = AVStatusChangeType.MUTE,
        call_index = c.call_index,
        var1 = imute
      });
    }

    public void on_start_call(Contact c) {
      int video = c.video ? 1 : 0;
      status_changes.push( AVStatusChange() {
        type = AVStatusChangeType.START,
        call_index = c.call_index,
        var1 = video
      });

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

      status_changes.push( AVStatusChange() {
        type = AVStatusChangeType.END,
        call_index = c.call_index
      });

    }

  }
}
