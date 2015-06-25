/*
 *    toxav-1.0.vapi
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

[CCode (cheader_filename = "tox/toxav.h", cprefix = "")]
namespace ToxAV {

  public const int RTP_PAYLOAD_SIZE;

  /**
   * @brief Callbacks ids that handle the call states.
   */
  [CCode (cname = "ToxAvCallbackID", cprefix = "av_On", has_type_id = false)]
  public enum CallbackID {
    /* Requests */
    [CCode (cname = "av_OnInvite")]
    INVITE,
    [CCode (cname = "av_OnStart")]
    START,
    [CCode (cname = "av_OnCancel")]
    CANCEL,
    [CCode (cname = "av_OnReject")]
    REJECT,
    [CCode (cname = "av_OnEnd")]
    END,

    /* Responses */
    [CCode (cname = "av_OnRinging")]
    RINGING,
    [CCode (cname = "av_OnStarting")]
    STARTING,
    [CCode (cname = "av_OnEnding")]
    ENDING,

    /* Protocol */
    [CCode (cname = "av_OnRequestTimeout")]
    REQUEST_TIMEOUT,
    [CCode (cname = "av_OnPeerTimeout")]
    PEER_TIMEOUT,
    [CCode (cname = "av_OnMediaChange")]
    MEDIA_CHANGE
  }

  /**
   * @brief Call type identifier.
   */
  [CCode (cname = "ToxAvCallType", cprefix = "Type", has_type_id = false)]
  public enum CallType {
    [CCode (cname = "TypeAudio")]
    AUDIO,
    [CCode (cname = "TypeVideo")]
    VIDEO
  }

  [CCode (cname = "ToxAvCallState", has_type_id = false)]
  public enum CallState {
    [CCode (cname = "av_CallNonExistant")]
    NON_EXISTANT,
    [CCode (cname = "av_CallInviting")]
    INVITING, /* when sending call invite */
    [CCode (cname = "av_CallStarting")]
    STARTING, /* when getting call invite */
    [CCode (cname = "av_CallActive")]
    ACTIVE,
    [CCode (cname = "av_CallHold")]
    HOLD,
    [CCode (cname = "av_CallHanged_up")]
    HANGED_UP
  }

  /**
   * @brief Error indicators.
   *
   */
  [CCode (cname = "ToxAvError", cprefix = "Error", has_type_id = false)]
  public enum AV_Error {
    [CCode (cname = "ErrorNone")]
    NONE,
    [CCode (cname = "ErrorInternal")]
    INTERNAL, /* Internal error */
    [CCode (cname = "ErrorAlreadyInCall")]
    ALREADY_IN_CALL, /* Already has an active call */
    [CCode (cname = "ErrorNoCall")]
    NO_CALL, /* Trying to perform call action while not in a call */
    [CCode (cname = "ErrorInvalidState")]
    INVALID_STATE, /* Trying to perform call action while in invalid state*/
    [CCode (cname = "ErrorNoRtpSession")]
    NO_RTP_SESSION, /* Trying to perform rtp action on invalid session */
    [CCode (cname = "ErrorAudioPacketLost")]
    AUDIO_PACKET_LOST, /* Indicating packet loss */
    [CCode (cname = "ErrorStartingAudioRtp")]
    STARTING_AUDIO_RTP,  /* Error in toxav_prepare_transmission() */
    [CCode (cname = "ErrorStartingVideoRtp")]
    STARTING_VIDEO_RTP,  /* Error in toxav_prepare_transmission() */
    [CCode (cname = "ErrorTerminatingAudioRtp")]
    TERMINATING_AUDIO_RTP, /* Returned in toxav_kill_transmission() */
    [CCode (cname = "ErrorTerminatingVideoRtp")]
    TERMINATING_VIDEO_RTP, /* Returned in toxav_kill_transmission() */
    [CCode (cname = "ErrorPacketTooLarge")]
    PACKET_TOO_LARGE, /* Buffer exceeds size while encoding */
    [CCode (cname = "ErrorInvalidCodecState")]
    INVALID_CODEC_STATE; /* Codec state not initialized */

    [CCode (cname = "vala_av_error_to_string")]
    public string to_string() {
      switch(this) {
        case NONE:
          return "No error";
        case INTERNAL:
          return "Internal error";
        case ALREADY_IN_CALL:
          return "Already has an active call";
        case NO_CALL:
          return "Trying to perform call action while not in a call";
        case INVALID_STATE:
          return "Trying to perform call action while in invalid state";
        case NO_RTP_SESSION:
          return "Trying to perform rtp action on invalid session";
        case AUDIO_PACKET_LOST:
          return "Indicating packet loss";
        case STARTING_AUDIO_RTP:
          return "Error in toxav_prepare_transmission()";
        case STARTING_VIDEO_RTP:
          return "Error in toxav_prepare_transmission()";
        case TERMINATING_AUDIO_RTP:
          return "Returned in toxav_kill_transmission()";
        case TERMINATING_VIDEO_RTP:
          return "Returned in toxav_kill_transmission()";
        case PACKET_TOO_LARGE:
          return "Buffer exceeds size while encoding";
        case INVALID_CODEC_STATE:
          return "Codec state not initialized";
        default:
          return "unknown error, fix vapi";
      }
    }
  }

  /**
   * @brief Locally supported capabilities.
   */
  [Flags]
  [CCode (cname = "ToxAvCapabilities", cprefix = "", has_type_id = false)]
  public enum Capabilities {
    [CCode (cname = "AudioEncoding")]
    AUDIO_ENCODING,
    [CCode (cname = "AudioDecoding")]
    AUDIO_DECODING,
    [CCode (cname = "VideoEncoding")]
    VIDEO_ENCODING,
    [CCode (cname = "VideoDecoding")]
    VIDEO_DECODING
  }

  /**
   * @brief Encoding settings.
   */
  [CCode (cname = "ToxAvCSettings", destroy_function = "", cprefix = "", has_copy_function = false, has_type_id = false)]
  public struct CodecSettings {
      CallType call_type;

      uint32 video_bitrate; /* In kbits/s */
      uint16 max_video_width; /* In px */
      uint16 max_video_height; /* In px */
      
      uint32 audio_bitrate; /* In bits/s */
      uint16 audio_frame_duration; /* In ms */
      uint32 audio_sample_rate; /* In Hz */
      uint32 audio_channels;
  }

  [CCode (cname = "av_DefaultSettings", has_type_id = false)]
  public const CodecSettings DefaultCodecSettings;
  [CCode (cname = "av_jbufdc")]
  public const uint32 JITTER_BUFFER_DEFAULT_CAPACITY;
  [CCode (cname = "av_VADd")]
  public const uint32 VAD_DEFAULT_THRESHOLD;

  [CCode (cname = "ToxAv", free_function = "toxav_kill", cprefix = "toxav_", has_type_id = false)]
  [Compact]
  public class ToxAV {
    /**
     * @brief Register callback for call state.
     *
     * @param callback The callback
     * @param id One of the ToxAvCallbackID values
     * @return void
     */
    //typedef void ( *ToxAVCallback ) ( void *arg );
    [CCode (cname = "ToxAVCallback", has_target = true)]
    public delegate void CallstateCallback(ToxAV av, int32 call_index);

    [CCode (cname = "toxav_register_callstate_callback", has_type_id = false)]
    public void register_callstate_callback ([CCode( delegate_target_pos = 3 )] CallstateCallback callback, CallbackID id);

    /**
     * @brief Start new A/V session. There can only be one session at the time. If you register more
     *        it will result in undefined behaviour.
     *
     * @param messenger The messenger handle.
     * @param userdata The agent handling A/V session (i.e. phone).
     * @param video_width Width of video frame.
     * @param video_height Height of video frame.
     * @return ToxAv*
     * @retval NULL On error.
     */
    [CCode (cname = "toxav_new")]
    public ToxAV(Tox.Tox messenger, int32 max_calls);

    /* #### only here for completeness #### */
    ///**
    // * @brief Remove A/V session.
    // *
    // * @param av Handler.
    // * @return void
    // */
    //void toxav_kill(ToxAv *av);

    /**
    * @brief Register callback for recieving audio data
    *
    * @param callback The callback
    * @return void
    */
    [CCode (has_type_id = false)]
    public delegate void AudioRecvCallback(ToxAV toxav, int32 call_index, [CCode(array_length_type="int")] int16[] frames);
    public void register_audio_recv_callback(AudioRecvCallback callback);

    /**
    * @brief Register callback for recieving video data
    *
    * @param callback The callback
    * @return void
    */
    [CCode (has_type_id = false)]
    public delegate void VideoRecvCallback(ToxAV toxav, int32 call_index, Vpx.Image frame);
    public void register_video_recv_callback(VideoRecvCallback callback);

    /**
     * @brief Call user. Use its friend_id.
     *
     * @param av Handler.
     * @param user The user.
     * @param call_type Call type.
     * @param ringing_seconds Ringing timeout.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error call(ref int32 call_index, int user, ref CodecSettings csettings, int ringing_seconds);

    /**
     * @brief Hangup active call.
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error hangup(int32 call_index);

    /**
     * @brief Answer incomming call.
     *
     * @param av Handler.
     * @param call_type Answer with...
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error answer(int32 call_index, ref CodecSettings csettings );

    /**
     * @brief Reject incomming call.
     *
     * @param av Handler.
     * @param reason Optional reason. Set NULL if none.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error reject(int32 call_index,  string reason);

    /**
     * @brief Cancel outgoing request.
     *
     * @param av Handler.
     * @param reason Optional reason.
     * @param peer_id peer friend_id
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error cancel(int32 call_index, int peer_id, string reason);

    /**
     * @brief Notify peer that we are changing call settings
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error change_settings(int32 call_index, ref CodecSettings csettings);

    /**
     * @brief Terminate transmission. Note that transmission will be terminated without informing remote peer.
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error stop_call(int32 call_index);

    /**
     * @brief Must be call before any RTP transmission occurs.
     *
     * @param av Handler.
     * @param support_video Is video supported ? 1 : 0
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error prepare_transmission(int32 call_index, uint32 jbuf_size, uint32 VAD_threshold, int support_video);

    /**
     * @brief Call this at the end of the transmission.
     *
     * @param av Handler.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error kill_transmission(int32 call_index);

    /**
     * @brief Send video packet.
     *
     * @param av Handler.
     * @param input The packet.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error send_video (int32 call_index, [CCode(array_length=false)] uint8[] frame, uint frame_size);

    /**
     * @brief Send audio frame.
     *
     * @param av Handler.
     * @param data The audio data encoded with toxav_prepare_audio_frame().
     * @param size Its size in number of bytes.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error send_audio (int32 call_index, [CCode(array_length=false)] uint8[] frame, uint frame_size);

    /**
     * @brief Encode video frame
     *
     * @param av Handler
     * @param dest Where to
     * @param dest_max Max size
     * @param input What to encode
     * @return int
     * @retval ToxAvError On error.
     * @retval >0 On success
     */
    public AV_Error prepare_video_frame(int32 call_index, uint8[] dest, Vpx.Image input);

    /**
     * @brief Encode audio frame
     *
     * @param av Handler
     * @param dest dest
     * @param dest_max Max dest size
     * @param frame The frame
     * @param frame_size The frame size
     * @return int
     * @retval ToxAvError On error.
     * @retval >0 On success
     */
    public AV_Error prepare_audio_frame(int32 call_index, uint8[] dest, [CCode(array_length=false)] int16[] frame, int frame_size);

    /**
     * @brief Get peer transmission type. It can either be audio or video.
     *
     * @param av Handler.
     * @param peer The peer
     * @return int
     * @retval ToxAvCallType On success.
     * @retval ToxAvError On error.
     */
    public AV_Error get_peer_csettings (int32 call_index, int peer, ref CodecSettings dest);

    /**
     * @brief Get id of peer participating in conversation
     * 
     * @param av Handler
     * @param peer peer index
     * @return int
     * @retval ToxAvError No peer id
     */
    public AV_Error get_peer_id ( int32 call_index, int peer );

    /**
     * @brief Get current call state
     *
     * @param av Handler
     * @param call_index What call
     * @return int
     * @retval ToxAvCallState State id
     */
    public CallState get_call_state(int32 call_index);

    /**
     * @brief Is certain capability supported
     * 
     * @param av Handler
     * @return int
     * @retval 1 Yes.
     * @retval 0 No.
     */
    public int capability_supported ( int32 call_index, Capabilities capability );

    /**
     * @brief Get messenger handle
     * 
     * @param av Handler.
     * @return Tox*
     */
    public Tox.Tox tox_handle {
      [CCode (cname = "toxav_get_tox")] get;
    }

    public int has_activity(int32 call_index, ref int16 pcm, uint16 frame_size, float ref_energy);
  }
}
