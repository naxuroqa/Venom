/*
 *    CreateGroupchatWidget.vala
 *
 *    Copyright (C) 2013-2017  Venom authors and contributors
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
    [GtkChild]
    private Gtk.Entry title;
    [GtkChild]
    private Gtk.RadioButton type;
    [GtkChild]
    private Gtk.Button create;

    private ILogger logger;
    private CreateGroupchatWidgetListener listener;

    public CreateGroupchatWidget(ILogger logger, CreateGroupchatWidgetListener listener) {
      logger.d("CreateGroupChatWidget created.");
      this.logger = logger;
      this.listener = listener;

      create.clicked.connect(on_create);
    }

    private void on_create() {
      logger.d("on_create");
      if (listener == null) {
        return;
      }
      try {
        var type = this.type.active ? GroupchatType.TEXT : GroupchatType.AV;
        listener.on_create_groupchat(title.text, type);
      } catch (Error e) {
        logger.e("Could not create groupchat: " + e.message);
        return;
      }
      logger.d("on_create successful");
    }

    ~CreateGroupchatWidget() {
      logger.d("CreateGroupChatWidget destroyed.");
    }
  }

  public enum GroupchatType {
    TEXT,
    AV
  }

  public interface CreateGroupchatWidgetListener : GLib.Object {
    public abstract void on_create_groupchat(string title, GroupchatType type) throws Error;
  }
}
