/*
 *    Message.vala
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

namespace Venom {
  public enum MessageSender {
    REMOTE,
    LOCAL,
    SYSTEM
  }

  public enum TransmissionState {
    NONE,
    SENT,
    RECEIVED
  }

  public interface Message : GLib.Object {
    public abstract int id                  { get; set; }
    public abstract int peers_index         { get; set; }
    public abstract DateTime timestamp      { get; set; }
    public abstract MessageSender sender    { get; set; }
    public abstract string message          { get; set; }
    public abstract bool is_action          { get; set; }
    public abstract TransmissionState state { get; set; }

    public abstract bool is_conference_message();
    public abstract bool equals_sender(Message m);
  }

  public interface FormattedMessage : GLib.Object {
    public abstract string get_sender_plain();
    public abstract string get_sender_full();
    public abstract string get_sender_id();
    public abstract string get_conversation_id();
    public abstract string get_message_plain();
    public abstract string get_time_plain();
    public abstract Gdk.Pixbuf get_sender_image();
  }
}
