/*
 *    GroupChatContact.vala
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

namespace Venom {
  public class GroupChatContact : IContact, GLib.Object{
    public int group_contact_id { get; set; }
    public string name          { get; set; }

    public GroupChatContact(int group_contact_id, string? name = null) {
      this.group_contact_id = group_contact_id;
      this.name = name;
    }

    public string get_status_string() { return _("Online"); }
    public string get_status_string_with_hyperlinks() { return get_status_string(); }
    public string get_status_string_alt() { return get_status_string(); }
    public string get_last_seen_string() { return ""; }

    public string get_name_string() {
      if(name != null && name != "") {
        return Markup.escape_text(name);
      } else {
        return "&lt;unknown&gt;";
      }
    }

    public string get_name_string_with_hyperlinks() {
      if(name != null && name != "") {
        return Tools.markup_uris(name);
      } else {
        return "&lt;unknown&gt;";
      }
    }
    public string get_tooltip_string() {
      return get_name_string();
    }
  }
}
