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
    [CCode (cname = "av_OnError")]
    ERROR,
    [CCode (cname = "av_OnRequestTimeout")]
    REQUEST_TIMEOUT,
    [CCode (cname = "av_OnPeerTimeout")]
    PEER_TIMEOUT
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

  /**
   * @brief Error indicators.
   *
   */
  [CCode (cname = "ToxAvError", cprefix = "Error", has_type_id = false)]
  public enum AV_Error {
    [CCode (cname = "ErrorNone")]
    NONE,
    [CCode (cname = "ErrorInternal")]
    INTERNAL,
    [CCode (cname = "ErrorAlreadyInCall")]
    ALREADY_IN_CALL,
    [CCode (cname = "ErrorNoCall")]
    NO_CALL,
    [CCode (cname = "ErrorInvalidState")]
    INVALID_STATE,
    [CCode (cname = "ErrorNoRtpSession")]
    NO_RTP_SESSION,
    [CCode (cname = "ErrorAudioPacketLost")]
    AUDIO_PACKET_LOST,
    [CCode (cname = "ErrorStartingAudioRtp")]
    STARTING_AUDIO_RTP,
    [CCode (cname = "ErrorStartingVideoRtp")]
    STARTING_VIDEO_RTP,
    [CCode (cname = "ErrorTerminatingAudioRtp")]
    TERMINATING_AUDIO_RTP,
    [CCode (cname = "ErrorTerminatingVideoRtp")]
    TERMINATING_VIDEO_RTP,
    [CCode (cname = "ErrorPacketTooLarge")]
    PACKET_TOO_LARGE
  }

  /**
   * @brief Locally supported capabilities.
   */
  [Flags]
  [CCode (cname = "ToxAvCapabilities", cprefix = "", has_type_id = false)]
  public enum Capabilities {
    [CCode (cname = "AudioEnconding")]
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
  [CCode (cname = "ToxAvCodecSettings", destroy_function = "", cprefix = "", has_copy_function = false, has_type_id = false)]
  public struct CodecSettings {
      uint32 video_bitrate; /* In bits/s */
      uint16 video_width; /* In px */
      uint16 video_height; /* In px */
      
      uint32 audio_bitrate; /* In bits/s */
      uint16 audio_frame_duration; /* In ms */
      uint32 audio_sample_rate; /* In Hz */
      uint32 audio_channels;
      
      uint32 jbuf_capacity; /* Size of jitter buffer */
  }

  [CCode (cname = "av_DefaultSettings", has_type_id = false)]
  public const CodecSettings DefaultCodecSettings;

  /**
   * @brief Register callback for call state.
   *
   * @param callback The callback
   * @param id One of the ToxAvCallbackID values
   * @return void
   */
  //typedef void ( *ToxAVCallback ) ( void *arg );
  [CCode (cname = "ToxAVCallback", has_type_id = false)]
  public delegate void CallstateCallback(int32 call_index);
  //FIXME
  [CCode (cname = "toxav_register_callstate_callback", has_type_id = false)]
  public static void register_callstate_callback ([CCode( delegate_target_pos = 3 )] CallstateCallback callback, CallbackID id);


  [CCode (cname = "ToxAv", free_function = "toxav_kill", cprefix = "toxav_", has_type_id = false)]
  [Compact]
  public class ToxAV {
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
    public AV_Error call(ref int32 call_index, int user, CallType call_type, int ringing_seconds);

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
    public AV_Error answer(int32 call_index, CallType call_type );

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
    public AV_Error prepare_transmission(int32 call_index, CodecSettings codec_settings, int support_video);

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
     * @brief Receive decoded video packet.
     *
     * @param av Handler.
     * @param output Storage.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On Error.
     */
    public AV_Error recv_video (int32 call_index, ref Vpx.Image output);

    /**
     * @brief Receive decoded audio frame.
     *
     * @param av Handler.
     * @param frame_size ...
     * @param dest Destination of the packet. Make sure it has enough space for
     *             RTP_PAYLOAD_SIZE bytes.
     * @return int
     * @retval >=0 Size of received packet.
     * @retval ToxAvError On error.
     */
    public AV_Error recv_audio(int32 call_index, int frame_size, [CCode(array_length=false)] int16[] dest );

    /**
     * @brief Send video packet.
     *
     * @param av Handler.
     * @param input The packet.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error send_video (int32 call_index, uint8[] frame);

    /**
     * @brief Send audio frame.
     *
     * @param av Handler.
     * @param frame The frame.
     * @param frame_size It's size.
     * @return int
     * @retval 0 Success.
     * @retval ToxAvError On error.
     */
    public AV_Error send_audio (int32 call_index, uint8[] frame);

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
    public AV_Error prepare_audio_frame(int32 call_index, uint8[] dest, int16[] frame);

    /**
     * @brief Get peer transmission type. It can either be audio or video.
     *
     * @param av Handler.
     * @param peer The peer
     * @return int
     * @retval ToxAvCallType On success.
     * @retval ToxAvError On error.
     */
    public AV_Error get_peer_transmission_type (int32 call_index, int peer);

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
     * @brief Is certain capability supported
     * 
     * @param av Handler
     * @return int
     * @retval 1 Yes.
     * @retval 0 No.
     */
    public int capability_supported ( int32 call_index, Capabilities capability );

    /**
     * @brief Set queue limit
     *
     * @param av Handler
     * @param call_index index
     * @param limit the limit
     * @return void
     */
    public int set_audio_queue_limit ( int32 call_index, uint64 limit );

    /**
     * @brief Set queue limit
     *
     * @param av Handler
     * @param call_index index
     * @param limit the limit
     * @return void
     */
    public int set_video_queue_limit ( int32 call_index, uint64 limit );

    /**
     * @brief Get messenger handle
     * 
     * @param av Handler.
     * @return Tox*
     */
    public Tox.Tox tox_handle {
      [CCode (cname = "toxav_get_tox")] get;
    }
  }
}


