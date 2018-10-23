/*
 *    MessageWidget.vala
 *
 *    Copyright (C) 2013-2018 Venom authors and contributors
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/message_widget.ui")]
  public class MessageWidget : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label sender;
    [GtkChild] private Gtk.Image sender_image;
    [GtkChild] private Gtk.Label timestamp;
    [GtkChild] private Gtk.Label message;
    [GtkChild] private Gtk.Image sent;

    private ILogger logger;
    private MessageViewModel view_model;
    private UriTransform uri_transform;
    private PangoTransform pango_transform;
    private ContextStyleBinding dim_binding;

    public MessageWidget(ILogger logger, IMessage message_content, ISettingsDatabase settings) {
      this.logger = logger;
      this.view_model = new MessageViewModel(logger, message_content, settings);
      this.uri_transform = new UriTransform(logger);
      this.pango_transform = new PangoTransform();
      this.dim_binding = new ContextStyleBinding(sent, "dim-label");

      view_model.bind_property("timestamp", timestamp, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("timestamp-tooltip", timestamp, "tooltip-text", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("message", message, "label", GLib.BindingFlags.SYNC_CREATE, uri_transform.transform);
      view_model.bind_property("sender-image", sender_image, "pixbuf", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("sender-color", pango_transform, "color", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("sender-bold", pango_transform, "bold", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("sender", sender, "label", GLib.BindingFlags.SYNC_CREATE, pango_transform.transform);
      view_model.bind_property("sender-sensitive", sender, "sensitive", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("sent-visible", sent, "visible", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("sent-tooltip", sent, "tooltip-text", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("sent-dim", dim_binding, "enable", GLib.BindingFlags.SYNC_CREATE);

      logger.d("MessageWidget created.");
    }

    ~MessageWidget() {
      logger.d("MessageWidget destroyed.");
    }
  }
}
