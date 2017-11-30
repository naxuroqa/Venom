/*
 *    Contacts.vala
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
  public interface Contacts : GLib.Object {
    public signal void contact_changed(GLib.Object sender, uint position);
    public signal void contact_added(GLib.Object sender, uint positon);
    public signal void contact_removed(GLib.Object sender, uint position);

    public abstract void add_contact(GLib.Object sender, IContact c);
    public abstract void remove_contact(GLib.Object sender, IContact c);

    public abstract bool is_empty();
    public abstract uint length();
    public abstract IContact get_item(uint position);
    public abstract uint index(IContact contact);
  }

  public class ContactsImpl : Contacts, GLib.Object {
    private GLib.List<IContact> contacts;
    private ILogger logger;

    public ContactsImpl(ILogger logger) {
      this.logger = logger;
      contacts = new GLib.List<IContact>();
    }

    public virtual void add_contact(GLib.Object sender, IContact c) {
      var idx = length();
      contacts.append(c);
      contact_added(sender, idx);
    }

    public virtual void remove_contact(GLib.Object sender, IContact c) {
      var idx = index(c);
      contacts.remove(c);
      contact_removed(sender, idx);
    }

    public virtual bool is_empty() {
      return contacts == null || contacts.length() <= 0;
    }

    public virtual uint length() {
      return contacts == null ? 0 : contacts.length();
    }

    public virtual IContact get_item(uint position) {
      return contacts.nth_data(position);
    }

    public virtual uint index(IContact contact) {
      return contacts.index(contact);
    }

    public virtual unowned GLib.List<IContact> get_contacts() {
      return contacts;
    }
  }
}
