/*
 *    CallState.vala
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

public interface MediaReceiver : GLib.Object {
  public abstract void push_audio_sample(Gst.Sample audio_sample);
  public abstract void push_video_sample(Gst.Sample video_sample);
}

public class CallState : GLib.Object {
  public bool in_call { get; set; }
  public bool pending_in { get; set; }
  public bool pending_out { get; set; }
  public bool local_video { get; set; }
  public bool local_audio { get; set; }
  public bool remote_video { get; set; }
  public bool remote_audio { get; set; }

  public MediaReceiver? media_receiver;
}