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
    private const string AUDIO_SOURCE = "audioSource";
    private const string AUDIO_SINK = "audioSink";

    private Gst.Pipeline pipeline;
    private Gst.Element audio_source;
    private Gst.Element audio_sink;

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
      audio_source = Gst.ElementFactory.make("autoaudiosrc", AUDIO_SOURCE);
      audio_sink = Gst.ElementFactory.make("autoaudiosink", AUDIO_SINK);
      pipeline.add_many(audio_source, audio_sink);
      audio_source.link(audio_sink);
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

  }
}

