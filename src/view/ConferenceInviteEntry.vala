/*
 *    ConferenceInviteEntry.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/conference_invite_entry.ui")]
  public class ConferenceInviteEntry : Gtk.ListBoxRow {
    private ILogger logger;
    private ConferenceInvite invite;
    private ConferenceInviteEntryListener listener;

    [GtkChild] private Gtk.Image contact_image;
    [GtkChild] private Gtk.Label contact_description;
    [GtkChild] private Gtk.Label contact_time;

    [GtkChild] private Gtk.Button accept;
    [GtkChild] private Gtk.Button reject;

    public ConferenceInviteEntry(ILogger logger, ConferenceInvite invite, ConferenceInviteEntryListener listener) {
      logger.d("ConferenceInviteEntry created.");
      this.logger = logger;
      this.invite = invite;
      this.listener = listener;

      var sender = invite.sender;

      var pixbuf = sender.get_image();
      if (pixbuf != null) {
        contact_image.pixbuf = round_corners(pixbuf.scale_simple(40, 40, Gdk.InterpType.BILINEAR));
      }
      contact_description.label = _("Invite from %s").printf(sender.get_name_string());
      contact_time.label = TimeStamp.get_pretty_timestamp(invite.timestamp);

      accept.clicked.connect(on_accept_clicked);
      reject.clicked.connect(on_reject_clicked);
    }

    private void on_accept_clicked() {
      try {
        listener.on_accept_conference_invite(invite);
      } catch (Error e) {
        logger.i("Could not accept conference invite: " + e.message);
      }
    }

    private void on_reject_clicked() {
      try {
        listener.on_reject_conference_invite(invite);
      } catch (Error e) {
        logger.i("Could not reject conference invite: " + e.message);
      }
    }

    ~ConferenceInviteEntry() {
      logger.d("ConferenceInviteEntry destroyed.");
    }
  }

  public interface ConferenceInviteEntryListener : GLib.Object {
    public abstract void on_accept_conference_invite(ConferenceInvite invite) throws Error;
    public abstract void on_reject_conference_invite(ConferenceInvite invite) throws Error;
  }
}
