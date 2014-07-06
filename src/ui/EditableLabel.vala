/*
 *    EditableLabel.vala
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
  public class EditableLabel : Gtk.EventBox {
    private Gtk.Box box_entry;
    private Gtk.Box box_label;

    public Gtk.Button button_cancel { get; set; }
    public Gtk.Button button_ok { get; set; }
    public Gtk.Entry entry { get; set; }
    public Gtk.Label label { get; set; }

    public signal void label_changed(string label_text);
    public signal void show_entry();
    public signal void show_label();

    public EditableLabel(string label = "") {
      this.label = new Gtk.Label(label);
      init_widgets();
      init_signals();
    }

    public EditableLabel.with_label(Gtk.Label label) {
      this.label = label;
      init_widgets();
      init_signals();
    }

    private void on_show_label() {
      box_label.visible = true;
      box_entry.visible = false;
    }

    private void on_show_entry() {
//FIXME define GTK_<MAJOR>_<MINOR> in cmake instead of using glib version
#if GLIB_2_34
      entry.attributes = label.attributes;
#endif
      box_label.visible = false;
      box_entry.no_show_all = false;
      box_entry.show_all();
      box_entry.visible = true;
      box_entry.no_show_all = true;
    }

    private void init_widgets() {
      entry = new Gtk.Entry();
      button_ok = new Gtk.Button();
      button_cancel = new Gtk.Button();

      entry.has_frame = false;
      entry.width_chars = 10;

      button_ok.add(new Gtk.Image.from_pixbuf(ResourceFactory.instance.ok));
      button_cancel.add(new Gtk.Image.from_pixbuf(ResourceFactory.instance.cancel));

      Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
      box_label = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
      box_entry = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
      box_entry.spacing = 1;

      box_label.pack_start(label);
      box_entry.pack_start(entry);
      box_entry.pack_start(button_ok, false);
      box_entry.pack_start(button_cancel, false);
      box.pack_start(box_label);
      box.pack_start(box_entry);

      box_entry.no_show_all = true;
      box_entry.visible = false;
      this.add(box);
    }

    private void on_cancel() {
      show_label();
    }

    private void on_ok() {
      show_label();
      label_changed(entry.text);
    }

    private bool check_focus() {
      unowned Gtk.Widget w = get_toplevel();
      if(!w.is_toplevel() || !(w is Gtk.Window)) {
        //could not get window for some reason, abort
        Logger.log(LogLevel.ERROR, "Could not get reference to toplevel window");
        return false;
      }
      unowned Gtk.Widget focus_widget = (w as Gtk.Window).get_focus();
      if(focus_widget == null) {
        return false;
      }
      if(focus_widget != entry && focus_widget != button_ok && focus_widget != button_cancel) {
        // other widget focused
        on_cancel();
      }
      return false;
    }

    private bool on_focus_out(Gdk.EventFocus focus) {
      Idle.add(check_focus);
      return false;
    }

    private void init_signals() {
      show_entry.connect(on_show_entry);
      show_label.connect(on_show_label);
      button_press_event.connect((event) => {
        if(!box_entry.visible && event.button == Gdk.BUTTON_PRIMARY) {
          entry.text = label.label;
          show_entry();
          entry.grab_focus();
          return true;
        }
        return false;
      });
      button_cancel.clicked.connect(on_cancel);
      button_ok.clicked.connect(on_ok);
      entry.activate.connect(on_ok);
      entry.key_release_event.connect((event) => {
        if(event.keyval == Gdk.Key.Escape) {
          on_cancel();
          return true;
        }
        return false;
      });
      entry.focus_out_event.connect(on_focus_out);
      button_ok.focus_out_event.connect(on_focus_out);
      button_cancel.focus_out_event.connect(on_focus_out);
    }
  }
}
