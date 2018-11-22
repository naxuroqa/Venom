/*
 *    PhotoboothWindow.vala
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
  public class PhotoboothWindow : Gtk.Window {
    public signal void new_photo(Gdk.Pixbuf pixbuf);
    public int timeout { get; set; }

    private Photobooth photobooth;
    private CropWidget crop_widget;
    private Gtk.Stack stack;
    private Gtk.Button next;
    private Gtk.Button back;
    private Gtk.HeaderBar header_bar;

    public PhotoboothWindow() {
      set_default_size(800, 450);
      photobooth = new Photobooth();
      crop_widget = new CropWidget();
      crop_widget.valign = crop_widget.halign = Gtk.Align.CENTER;

      stack = new Gtk.Stack();
      stack.add(photobooth);
      stack.add(crop_widget);
      stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
      add(stack);

      next = new Gtk.Button.with_label(_("Select"));
      next.get_style_context().add_class("suggested-action");
      next.clicked.connect(on_next);
      next.sensitive = false;
      back = new Gtk.Button.with_label(_("Cancel"));
      back.clicked.connect(on_back);

      header_bar = new Gtk.HeaderBar();
      header_bar.pack_start(back);
      header_bar.pack_end(next);
      set_titlebar(header_bar);

      photobooth.bind_property("timeout", this, "timeout", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      photobooth.new_photo.connect(crop_photo);
    }

    private void crop_photo(Gdk.Pixbuf pixbuf) {
      photobooth.stop();
      crop_widget.pixbuf = pixbuf;
      stack.visible_child = crop_widget;
      next.sensitive = true;
    }

    private void on_back() {
      destroy();
    }

    private void on_next() {
      var pixbuf = crop_widget.get_cropped_picture();
      if (pixbuf != null) {
        new_photo(pixbuf);
      }
    }
  }
}
