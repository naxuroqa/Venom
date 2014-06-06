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

using Gst;

namespace Venom { 
    public class AudioManager { 
        
        private Pipeline pipeline;
        private Element asrc;
        private Element asink;

        public AudioManager(string[] fakeArgs) { 
            Gst.init(ref fakeArgs);
        }

        public void build_audio_pipeline() { 
            this.pipeline = new Pipeline("audioPipeline");
            this.asrc = ElementFactory.make("autoaudiosrc", "audio");
            this.asink = ElementFactory.make("autoaudiosink", "asink");
            this.pipeline.add_many(this.asrc, this.asink);
            this.asrc.link(this.asink);
        }

        public void destroy_audio_pipeline() { 
            this.pipeline.set_state(Gst.State.NULL);
        }

        public void set_pipeline_ready() { 
            this.pipeline.set_state(State.READY);
        }

        public void set_pipeline_playing() { 
            this.pipeline.set_state(State.PLAYING);
        }

    }
}

