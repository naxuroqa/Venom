/*
 *    ContactListViewModel.vala
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
  public class ContactListViewModel : GLib.Object {
    private ILogger logger;
    private ContactListWidgetCallback callback;
    private UserInfo user_info;
    private ObservableList contacts;
    private ObservableList friend_requests;
    private ObservableList conference_invites;

    private WeakRef right_clicked_contact;
    private WeakRef selected_contact;

    public string username { get; set; }
    public string statusmessage { get; set; }
    public Gdk.Pixbuf userimage { get; set; }
    public string image_status { get; set; }
    public bool friend_request_visible { get; set; }
    public string friend_request_label { get; set; }
    public bool conference_invite_visible { get; set; }
    public string conference_invite_label { get; set; }

    public ContactListViewModel(ILogger logger, ObservableList contacts, ObservableList friend_requests, ObservableList conference_invites, ContactListWidgetCallback callback, UserInfo user_info) {
      logger.d("ContactListViewModel created.");
      this.logger = logger;
      this.contacts = contacts;
      this.friend_requests = friend_requests;
      this.conference_invites = conference_invites;
      this.callback = callback;
      this.user_info = user_info;

      right_clicked_contact = WeakRef(null);
      selected_contact = WeakRef(null);

      refresh_user_info(this);
      user_info.info_changed.connect(refresh_user_info);

      refresh_friend_requests();
      friend_requests.changed.connect(refresh_friend_requests);

      refresh_conference_invites();
      conference_invites.changed.connect(refresh_conference_invites);
    }

    public ListModel get_list_model() {
      return new ObservableListModel(contacts);
    }

    public void on_contact_selected(IContact? contact) {
      selected_contact.@set(contact);
      if (contact != null) {
        callback.on_contact_selected(contact);
      }
    }

    private bool peers_contain(Gee.Collection<ConferencePeer> peers, string id) {
      foreach (var peer in peers) {
        if (peer.peer_key == id) {
          return true;
        }
      }
      return false;
    }

    public void on_invite_to_conference(string id) {
      var contact = right_clicked_contact.@get() as IContact;
      if (contact == null) {
        return;
      }
      callback.on_invite_id_to_conference(contact, id);
    }

    public GLib.MenuModel popup_menu(IContact? c) {
      logger.d("ContactListViewModel popup_menu");
      var contact = c ?? selected_contact.@get() as IContact;
      right_clicked_contact.@set(contact);
      var id = contact.get_id();
      var menu = new GLib.Menu();

      if (contact.is_connected() && !contact.is_conference()) {
        var conference_menu = new GLib.Menu();
        conference_menu.append(_("New conference…"), @"win.invite-to-conference('')");

        for (var i = 0; i < contacts.length(); i++) {
          if (contacts.nth_data(i) is Conference) {
            var conference = contacts.nth_data(i) as Conference;
            var peers = conference.get_peers().values;
            if (peers_contain(peers, id)) {
              continue;
            }
            var conference_id = conference.get_id();
            conference_menu.append(conference.get_name_string(), @"win.invite-to-conference('$conference_id')");
          }
        }
        menu.append_submenu(_("Invite to conference"), conference_menu);
      }

      menu.append(_("Show details"), @"win.show-contact-details('$id')");
      return menu;
    }

    private void refresh_user_info(GLib.Object sender) {
      username = user_info.name;
      statusmessage = user_info.status_message;
      var userimage_pixbuf = scalePixbuf(user_info.image);
      if (userimage_pixbuf != null) {
        userimage = userimage_pixbuf;
      }
      if (user_info.is_connected) {
        image_status = get_resource_from_status(user_info.user_status);
      } else {
        image_status = R.icons.offline;
      }
    }

    private void refresh_friend_requests() {
      var count = friend_requests.length();
      friend_request_visible = count > 0;
      if (count > 0) {
        friend_request_label = ngettext("%u new friend request", "%u new friend requests", count).printf(count);
      }
    }

    private void refresh_conference_invites() {
      var count = conference_invites.length();
      conference_invite_visible = count > 0;
      if (count > 0) {
        conference_invite_label = ngettext("%u new conference invite", "%u new conference invites", count).printf(count);
      }
    }

    private string get_resource_from_status(UserStatus status) {
      switch (status) {
        case UserStatus.AWAY:
          return R.icons.idle;
        case UserStatus.BUSY:
          return R.icons.busy;
        default:
          return R.icons.online;
      }
    }

    private Gdk.Pixbuf ? scalePixbuf(Gdk.Pixbuf ? pixbuf) {
      if (pixbuf == null) {
        return null;
      }
      return pixbuf.scale_simple(22, 22, Gdk.InterpType.BILINEAR);
    }

    ~ContactListViewModel() {
      logger.d("ContactListViewModel destroyed.");
    }
  }

  public interface ContactListWidgetCallback : GLib.Object {
    public abstract void on_contact_selected(IContact contact);
    public abstract void on_invite_id_to_conference(IContact contact, string id) throws Error;
  }
}
