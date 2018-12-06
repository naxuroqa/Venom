/*
 *    ToxCallAdapter.vala
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

namespace Venom {
  public interface CallAdapterListener : GLib.Object {
    public abstract void on_incoming_call(IContact contact);
    public abstract void on_outgoing_call(IContact contact);
    public abstract void on_call_accepted(IContact contact);
  }

  public class DefaultToxCallAdapter : ToxCallAdapter, CallWidgetListener, GLib.Object {
    private unowned ToxSession session;
    private unowned Gee.Map<uint32, IContact> friends;
    private unowned CallAdapterListener call_listener;
    private Logger logger;

    private Gee.Map<IContact, CallState> call_states;
    private Gee.Map<IContact, Gst.Base.Adapter> call_adapters;

    private NotificationListener notification_listener;
    private ToxAV.ToxAV toxav_dummy;

    public DefaultToxCallAdapter(Logger logger, NotificationListener notification_listener, CallAdapterListener call_listener) {
      logger.d("DefaultToxCallAdapter created.");
      this.logger = logger;
      this.notification_listener = notification_listener;
      this.call_listener = call_listener;
      call_states = new Gee.HashMap<IContact, CallState>();
      call_adapters = new Gee.HashMap<IContact, Gst.Base.Adapter>();
    }

    ~DefaultToxCallAdapter() {
      logger.d("DefaultToxCallAdapter destroyed.");
    }

    public void attach_to_session(ToxSession session) {
      this.session = session;
      session.set_call_adapter(this);
      friends = session.get_friends();
    }

    public CallState get_call_state(IContact contact) {
      var call_state = call_states.@get(contact);
      if (call_state == null) {
        call_state = new CallState();
        call_states.@set(contact, call_state);
      }
      return call_state;
    }

    public void stop_call(IContact contact) throws Error {
      logger.d(@"DefaultToxCallAdapter stop_call(...)");
      var c = contact as Contact;
      var call_state = get_call_state(c);

      session.call_control(c.tox_friend_number, ToxAV.CallControl.CANCEL);
      call_state.freeze_notify();
      call_state.in_call = false;
      call_state.pending_in = false;
      call_state.pending_out = false;
      call_state.thaw_notify();
      call_adapters.unset(contact);
    }

    public void answer(IContact contact) throws Error {
      logger.d(@"DefaultToxCallAdapter answer(...)");
      var c = contact as Contact;
      var call_state = get_call_state(contact);

      session.accept_call(c.tox_friend_number, 128, 1000);

      call_adapters.@set(contact, new Gst.Base.Adapter());

      call_state.freeze_notify();
      call_state.pending_in = false;
      call_state.in_call = true;
      call_state.local_audio = true;
      call_state.local_video = false;
      call_state.thaw_notify();
    }

    public void call(IContact contact, bool audio, bool video) throws Error {
      logger.d(@"DefaultToxCallAdapter call(..., $audio, $video)");
      var c = contact as Contact;
      var call_state = get_call_state(contact);
      session.call(c.tox_friend_number, 128, 1000);

      call_state.freeze_notify();
      call_state.local_audio = audio;
      call_state.local_video = video;
      call_state.pending_out = true;
      call_state.thaw_notify();
      call_listener.on_outgoing_call(contact);
    }

    public void on_call_cb(uint32 friend_number, bool audio_enabled, bool video_enabled) {
      logger.d(@"DefaultToxCallAdapter on_call_cb($friend_number, $audio_enabled, $video_enabled)");
      var contact = friends.@get(friend_number);
      var call_state = get_call_state(contact);

      call_state.freeze_notify();
      call_state.remote_audio = audio_enabled;
      call_state.remote_video = video_enabled;
      call_state.pending_in = true;
      call_state.thaw_notify();

      notification_listener.on_incoming_call(contact, video_enabled);
      call_listener.on_incoming_call(contact);
    }

    public void on_call_state_cb(uint32 friend_number, ToxAV.FriendCallState state) {
      logger.d("DefaultToxCallAdapter on_call_state_cb(%u, %#00X)".printf(friend_number, state));
      var contact = friends.@get(friend_number);
      var call_state = get_call_state(contact);

      call_state.freeze_notify();
      call_state.remote_video = ToxAV.FriendCallState.SENDING_V in state;
      call_state.remote_audio = ToxAV.FriendCallState.SENDING_A in state;

      if (ToxAV.FriendCallState.FINISHED in state) {
        logger.i("Call finished");
        call_state.in_call = false;
        call_state.pending_in = false;
        call_state.pending_out = false;
        call_adapters.unset(contact);
      } else if (ToxAV.FriendCallState.ERROR in state) {
        logger.i("Call errored");
        call_state.in_call = false;
        call_state.pending_in = false;
        call_state.pending_out = false;
        call_adapters.unset(contact);
      } else if (!call_state.in_call && call_state.pending_out) {
        call_adapters.@set(contact, new Gst.Base.Adapter());
        call_state.pending_out = false;
        call_state.in_call = true;
        call_listener.on_call_accepted(contact);
      }
      call_state.thaw_notify();
    }

    public void send_audio_sample(IContact contact, Gst.Sample sample) throws Error {
      var c = contact as Contact;
      var call_state = get_call_state(contact);
      if (!call_state.in_call || !c.is_connected()) {
        logger.d("Trying to send audio sample, but not in a call with contact");
        return;
      }

      var adapter = call_adapters.@get(contact);
      if (adapter == null) {
        throw new IOError.FAILED("Gst.Base.Adapter for contact is missing");
      }

      var buffer = sample.get_buffer();
      adapter.push(buffer);

      var caps = sample.get_caps();
      session.audio_send_sample(c.tox_friend_number, adapter, caps);
    }

    public void send_video_sample(IContact contact, Gst.Sample sample) throws Error {
      var c = contact as Contact;
      session.video_send_sample(c.tox_friend_number, sample);
    }

    public void on_audio_bit_rate_cb(uint32 friend_number, uint32 audio_bit_rate) {
      logger.d(@"DefaultToxCallAdapter on_audio_bit_rate_cb($friend_number, $audio_bit_rate)");
      //FIXME
    }

    public void on_video_bit_rate_cb(uint32 friend_number, uint32 video_bit_rate) {
      logger.d(@"DefaultToxCallAdapter on_video_bit_rate_cb($friend_number, $video_bit_rate)");
      //FIXME
    }

    public void on_audio_receive_sample_cb(uint32 friend_number, Gst.Sample sample) {
      // logger.d(@"DefaultToxCallAdapter on_audio_receive_sample_cb($friend_number, ...)");
      var contact = friends.@get(friend_number);
      var call_state = get_call_state(contact);
      if (call_state.media_receiver != null) {
        call_state.media_receiver.push_audio_sample(sample);
      }
    }

    public void on_video_receive_sample_cb(uint32 friend_number, Gst.Sample sample) {
      // logger.d(@"DefaultToxCallAdapter on_video_receive_sample_cb($friend_number, ...)");
      var contact = friends.@get(friend_number);
      var call_state = get_call_state(contact);
      if (call_state.media_receiver != null) {
        call_state.media_receiver.push_video_sample(sample);
      }
    }

    public void on_av_conference_audio_sample_cb(uint32 group_number, uint32 peer_number, Gst.Sample sample) {
      logger.d(@"DefaultToxCallAdapter on_av_conference_audio_sample_cb($group_number, $peer_number, ...)");
      //FIXME
    }
  }
}
