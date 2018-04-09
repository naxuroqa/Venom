/*
 *    CreateGroupchatWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/create_groupchat_widget.ui")]
  public class CreateGroupchatWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry title;
    [GtkChild] private Gtk.RadioButton type_text;
    [GtkChild] private Gtk.Button create;
    [GtkChild] private Gtk.Revealer title_error_content;
    [GtkChild] private Gtk.Label title_error;

    private ILogger logger;
    private CreateGroupchatViewModel view_model;

    public CreateGroupchatWidget(ILogger logger, CreateGroupchatWidgetListener listener) {
      logger.d("CreateGroupChatWidget created.");
      this.logger = logger;
      this.view_model = new CreateGroupchatViewModel(logger, listener);

      title.bind_property("text", view_model, "title", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("title-error", title_error, "label", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("title-error-visible", title_error_content, "reveal-child", GLib.BindingFlags.SYNC_CREATE);
      //FIXME type binding
      create.clicked.connect(view_model.on_create);
    }

    ~CreateGroupchatWidget() {
      logger.d("CreateGroupChatWidget destroyed.");
    }
  }
}
