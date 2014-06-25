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

  public class AudioManager { 

    private const string PIPELINE = "audioPipeline";
    private const string AUDIO_SOURCE_IN = "audioSourceIn";
    private const string AUDIO_SOURCE_OUT = "audioSourceOut";
    private const string AUDIO_SINK_IN = "audioSinkIn";
    private const string AUDIO_SINK_OUT = "audioSinkOut";

    private const int CHUNK_SIZE = 1024; 
    private const int SAMPLE_RATE = 44100;
    private const string AUDIO_CAPS = "audio/x-raw-int,channels=1,rate=44100,signed=(boolean)true,width=16,depth=16,endianness=BYTE_ORDER";

    private Gst.Pipeline pipeline;
    private Gst.AppSrc audio_source_in;
    private Gst.Element audio_source_out;
    private Gst.Element audio_sink_in;
    private Gst.AppSink audio_sink_out;

    public static AudioManager instance {get; private set;}

    public static void init() throws AudioManagerError {
      instance = new AudioManager({""});
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

      pipeline = new Gst.Pipeline(PIPELINE);
      audio_source_out = Gst.ElementFactory.make("autoaudiosrc", AUDIO_SOURCE_OUT);
      audio_sink_out = (Gst.AppSink)Gst.ElementFactory.make("appsink", AUDIO_SINK_OUT);
      audio_source_in = (Gst.AppSrc)Gst.ElementFactory.make("appsrc", AUDIO_SOURCE_IN);
      audio_sink_in = Gst.ElementFactory.make("autoaudiosink", AUDIO_SINK_IN);
      pipeline.add_many(audio_source_out, audio_sink_out, audio_source_in, audio_sink_in);
      audio_source_in.link(audio_sink_in);
      audio_source_out.link(audio_sink_out);

      Gst.Caps caps = Gst.Caps.from_string(AUDIO_CAPS);
      audio_source_in.set_caps(caps);      
      audio_sink_out.set_caps(caps);
       
    }

    public void destroy_audio_pipeline() {
      pipeline.set_state(Gst.State.NULL);
    }

    public void set_pipeline_paused() {
      pipeline.set_state(Gst.State.PAUSED);
      stdout.printf("Pipeline set to paused\n");
    }

    public void set_pipeline_playing() {
      pipeline.set_state(Gst.State.PLAYING);
      stdout.printf("Pipeline set to playing\n");
    }

    public void buffer_in() { 
 
    }

    public void buffer_out() { 
        uint8[] buf = new uint8[20];
       
        //THIS LINE IS NOT WORKING 
        //Gst.Buffer gst_buf = new Gst.Buffer.wrapped(buf);

    } 


  }
}

