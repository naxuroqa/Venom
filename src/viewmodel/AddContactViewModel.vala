/*
 *    AddContactViewModel.vala
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
  public class AddContactViewModel : GLib.Object {
    public string contact_id { get; set; }
    public string contact_message { get; set; }
    public bool contact_id_error_visible { get; set; }
    public string contact_id_error_message { get; set; }
    public bool new_friend_request { get; set; }
    public Gdk.Pixbuf contact_image { get; set; }
    public bool contact_image_visible { get; set; }

    private ILogger logger;
    private AddContactWidgetListener listener;
    private ObservableList friend_requests;

    public AddContactViewModel(ILogger logger, ObservableList friend_requests, AddContactWidgetListener listener) {
      logger.d("AddContactViewModel created.");
      this.logger = logger;
      this.friend_requests = friend_requests;
      this.listener = listener;

      this.notify["contact-id"].connect(on_contact_id_changed);
      friend_requests.changed.connect(on_friend_requests_changed);
      on_friend_requests_changed();
    }

    private void on_friend_requests_changed() {
      new_friend_request = friend_requests.length() > 0;
    }

    private void on_contact_id_changed() {
      contact_id_error_visible = false;
      var id = Tools.hexstring_to_bin(contact_id);
      if (id.length == ToxCore.address_size()) {
        var pixbuf = Identicon.generate_pixbuf(id[0 : ToxCore.public_key_size()]);
        contact_image = round_corners(pixbuf.scale_simple(44, 44, Gdk.InterpType.BILINEAR));
        contact_image_visible = true;
      } else {
        contact_image_visible = false;
      }
    }

    public ListModel get_list_model() {
      return new ObservableListModel(friend_requests);
    }

    public void on_send() {
      try {
        listener.on_send_friend_request(contact_id, contact_message);
      } catch (Error e) {
        contact_id_error_message = "Could not add contact: " + e.message;
        contact_id_error_visible = true;
        logger.e(contact_id_error_message);
        return;
      }
    }

    public void on_paste_clipboard() {
      var clipboard = Gtk.Clipboard.@get(Gdk.SELECTION_CLIPBOARD);
      contact_id = clipboard.wait_for_text() ?? "";
    }

    ~AddContactViewModel() {
      logger.d("AddContactViewModel destroyed.");
    }
  }

  public class StackIndexTransform {
    private string[] child_names;
    private Gtk.Stack stack;

    public StackIndexTransform(Gtk.Stack stack) {
      this.stack = stack;
      foreach (var w in stack.get_children()) {
        var name = "";
        stack.child_get(w, "name", &name);
        child_names += name;
      }
    }
    public void transform_list_box_row(Gtk.ListBoxRow? row) {
      if (row != null) {
        stack.visible_child_name = child_names[row.get_index()];
      }
    }

    public bool transform_boolean(GLib.Binding binding, GLib.Value source, ref GLib.Value dest) {
      dest.set_string(child_names[source.get_boolean() ? 1 : 0]);
      return true;
    }
  }

  public interface AddContactWidgetListener : GLib.Object {
    public abstract void on_send_friend_request(string id, string message) throws Error;
  }

  public class ContainerChildBooleanBinding : GLib.Object {
    private Gtk.Container container;
    private Gtk.Widget child;
    private string property_name;
    public bool active {
      set {
        container.child_set(child, property_name, value);
      }
    }
    public ContainerChildBooleanBinding(Gtk.Container container, Gtk.Widget child, string property_name) {
      this.container = container;
      this.child = child;
      this.property_name = property_name;
    }
  }
}
