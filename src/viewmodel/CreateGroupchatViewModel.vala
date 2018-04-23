/*
 *    CreateGroupchatViewModel.vala
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
  public class CreateGroupchatViewModel : GLib.Object {
    public string title { get; set; }
    public GroupchatType group_chat_type { get; set; }
    public bool title_error_visible { get; set; }
    public string title_error { get; set; }
    public signal void leave_view();

    private ILogger logger;
    private CreateGroupchatWidgetListener listener;

    public CreateGroupchatViewModel(ILogger logger, CreateGroupchatWidgetListener listener) {
      logger.d("CreateGroupchatViewModel created.");
      this.logger = logger;
      this.listener = listener;

      group_chat_type = GroupchatType.TEXT;
      notify["title"].connect(() => { title_error_visible = false; });
    }

    private void show_error(string message) {
      title_error_visible = true;
      title_error = message;
    }

    public void on_create() {
      logger.d("on_create");
      if (listener == null) {
        return;
      }
      try {
        listener.on_create_groupchat(title, group_chat_type);
      } catch (Error e) {
        show_error("Could not create conference: " + e.message);
        return;
      }
      logger.d("on_create successful");
      leave_view();
    }

    ~CreateGroupchatViewModel() {
      logger.d("CreateGroupchatViewModel destroyed.");
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
