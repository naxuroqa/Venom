/*
 *    toxav.vapi
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

[CCode(cheader_filename = "tox/toxav.h", cprefix = "")]
namespace ToxAV {

  [CCode(cname = "TOXAV_ERR_NEW", cprefix = "TOXAV_ERR_NEW_", has_type_id = false)]
  public enum ErrNew {
    OK,
    NULL,
    MALLOC,
    MULTIPLE
  }

  [CCode(cname = "TOXAV_ERR_CALL", cprefix = "TOXAV_ERR_CALL_", has_type_id = false)]
  public enum ErrCall {
    OK,
    MALLOC,
    SYNC,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CONNECTED,
    FRIEND_ALREADY_IN_CALL,
    INVALID_BIT_RATE
  }

  [CCode(cname = "TOXAV_ERR_ANSWER", cprefix = "TOXAV_ERR_ANSWER_", has_type_id = false)]
  public enum ErrAnswer {
    OK,
    SYNC,
    CODEC_INITIALIZATION,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_CALLING,
    INVALID_BIT_RATE
  }

  [Flags]
  [CCode(cname = "TOXAV_FRIEND_CALL_STATE", cprefix = "TOXAV_FRIEND_CALL_STATE_", has_type_id = false)]
  public enum FriendCallState {
    NONE,
    ERROR,
    FINISHED,
    SENDING_A,
    SENDING_V,
    ACCEPTING_A,
    ACCEPTING_V
  }

  [CCode(cname = "TOXAV_CALL_CONTROL", cprefix = "TOXAV_CALL_CONTROL_", has_type_id = false)]
  public enum CallControl {
    RESUME,
    PAUSE,
    CANCEL,
    MUTE_AUDIO,
    UNMUTE_AUDIO,
    HIDE_VIDEO,
    SHOW_VIDEO
  }

  [CCode(cname = "TOXAV_ERR_CALL_CONTROL", cprefix = "TOXAV_ERR_CALL_CONTROL_", has_type_id = false)]
  public enum ErrCallControl {
    OK,
    SYNC,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_IN_CALL,
    INVALID_TRANSITION
  }

  [CCode(cname = "TOXAV_ERR_BIT_RATE_SET", cprefix = "TOXAV_ERR_BIT_RATE_SET_", has_type_id = false)]
  public enum ErrBitRateSet {
    OK,
    SYNC,
    INVALID_AUDIO_BIT_RATE,
    INVALID_VIDEO_BIT_RATE,
    FRIEND_NOT_FOUND,
    FRIEND_NOT_IN_CALL
  }

  [CCode(cname = "TOXAV_ERR_SEND_FRAME", cprefix = "TOXAV_ERR_SEND_FRAME_", has_type_id = false)]
  public enum ErrSendFrame {
    OK,
    NULL,
    NOT_FOUND,
    FRIEND_NOT_IN_CALL,
    SYNC,
    INVALID,
    PAYLOAD_TYPE_DISABLED,
    RTP_FAILED
  }

  [CCode(cname = "toxav_call_cb", has_target = false, has_type_id = false)]
  public delegate void CallCallback(ToxAV self, uint32 friend_number, bool audio_enabled, bool video_enabled, void* user_data);

  [CCode(cname = "toxav_call_state_cb", has_target = false, has_type_id = false)]
  public delegate void CallStateCallback(ToxAV self, uint32 friend_number, FriendCallState state, void* user_data);

  [CCode(cname = "toxav_bit_rate_status_cb", has_target = false, has_type_id = false)]
  public delegate void BitRateStatusCallback(ToxAV self, uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate, void* user_data);

  [CCode(cname = "toxav_audio_receive_frame_cb", has_target = false, has_type_id = false)]
  public delegate void AudioReceiveFrameCallback(ToxAV self, uint32 friend_number, int16[] pcm, uint8 channels, uint32 sampling_rate, void* user_data);

  [CCode(cname = "toxav_video_receive_frame_cb", has_target = false, has_type_id = false)]
  public delegate void VideoReceiveFrameCallback(ToxAV self, uint32 friend_number, uint16 width, uint16 height, [CCode(array_length = false)] uint8[] y, [CCode(array_length = false)] uint8[] u, [CCode(array_length = false)] uint8[] v, int32 ystride, int32 ustride, int32 vstride, void* user_data);

  [CCode(cname = "ToxAV", free_function = "toxav_kill", cprefix = "toxav_", has_type_id = false)]
  [Compact]
  public class ToxAV {

    [CCode(cname = "toxav_new")]
    public ToxAV(ToxCore.Tox tox, ref ErrNew e);

    public ToxCore.Tox tox {
      [CCode(cname = "toxav_get_tox")] get;
    }

    public uint32 iteration_interval();

    public void iterate();

    public bool call(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate, ref ErrCall error);

    public void callback_call(CallCallback callback);

    public bool answer(uint32 friend_number, uint32 audio_bit_rate, uint32 video_bit_rate, ref ErrAnswer error);

    public void callback_call_state(CallStateCallback callback);

    public bool call_control(uint32 friend_number, CallControl control, ref ErrCallControl error);

    public bool bit_rate_set(uint32 friend_number, int32 audio_bit_rate, int32 video_bit_rate, ref ErrBitRateSet error);

    public void callback_bit_rate_status(BitRateStatusCallback callback);

    public bool audio_send_frame(uint32 friend_number, int16[] pcm, uint8 channels, uint32 sampling_rate, ref ErrSendFrame error);

    public bool video_send_frame(uint32 friend_number, uint16 width, uint16 height, [CCode(array_length = false)] uint8[] y,
                                 [CCode(array_length = false)] uint8[] u, [CCode(array_length = false)] uint8 v, ref ErrSendFrame error);

    public void callback_audio_receive_frame(AudioReceiveFrameCallback callback);

    public void callback_video_receive_frame(VideoReceiveFrameCallback callback);
  }
}
