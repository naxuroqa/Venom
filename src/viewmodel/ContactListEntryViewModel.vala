/*
 *    ContactListEntryViewModel.vala
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
  public class ContactListEntryViewModel : GLib.Object {
    private Logger logger;
    private IContact contact;
    private bool compact;

    public string contact_name { get; set; }
    public string contact_status { get; set; }
    public Gdk.Pixbuf contact_image { get; set; }
    public string contact_status_image { get; set; }
    public string contact_status_tooltip { get; set; }
    public bool contact_requires_attention { get; set; }

    public ContactListEntryViewModel(Logger logger, IContact contact, bool compact) {
      logger.d("ContactListEntryViewModel created.");
      this.logger = logger;
      this.contact = contact;
      this.compact = compact;

      contact.changed.connect(update_contact);
      update_contact();
    }

    public IContact get_contact() {
      return contact;
    }

    private void update_contact() {
      contact_name = contact.get_name_string();
      contact_status = contact.get_status_string();
      contact_requires_attention = contact.get_requires_attention();

      var pixbuf = contact.get_image();
      if (pixbuf != null) {
        var size = compact ? 20 : 40;
        contact_image = round_corners(pixbuf.scale_simple(size, size, Gdk.InterpType.BILINEAR));
      }

      if (contact_requires_attention) {
        contact_status_tooltip = _("New Message!");
        contact_status_image = "mail-unread-symbolic";
      } else if (contact.is_connected()) {
        contact_status_tooltip = tooltip_from_status(contact.get_status());
        contact_status_image = icon_name_from_status(contact.get_status());
      } else {
        contact_status_tooltip = _("Offline");
        contact_status_image = R.icons.offline;
      }
    }

    private string tooltip_from_status(UserStatus status) {
      switch (status) {
        case UserStatus.AWAY:
          return _("Away");
        case UserStatus.BUSY:
          return _("Busy");
        default:
          return _("Online");
      }
    }

    private string icon_name_from_status(UserStatus status) {
      switch (status) {
        case UserStatus.AWAY:
          return R.icons.idle;
        case UserStatus.BUSY:
          return R.icons.busy;
        default:
          return R.icons.online;
      }
    }

    ~ContactListEntryViewModel() {
      logger.d("ContactListEntryViewModel destroyed.");
    }
  }

  public static Gdk.Pixbuf round_corners(Gdk.Pixbuf source) {
    var width = source.width;
    var height = source.height;
    var radius = width * 0.1f;
    var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, width, height);
    var context = new Cairo.Context(surface);
    var deg = Math.PI / 180.0;

    context.new_sub_path();
    context.arc(width - radius, radius, radius, -90 * deg, 0);
    context.arc(width - radius, height - radius, radius, 0, 90 * deg);
    context.arc(radius, height - radius, radius, 90 * deg, 180 * deg);
    context.arc(radius, radius, radius, 180 * deg, 270 * deg);
    context.close_path();

    Gdk.cairo_set_source_pixbuf(context, source, 0, 0);
    context.fill();

    return Gdk.pixbuf_get_from_surface(surface, 0, 0, width, height);
  }
}
