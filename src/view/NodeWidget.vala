/*
 *    NodeWidget.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/node_widget.ui")]
  public class NodeWidget : Gtk.ListBoxRow {
    [GtkChild] private Gtk.Label host;
    [GtkChild] private Gtk.Label public_key;
    [GtkChild] private Gtk.Label maintainer;
    [GtkChild] private Gtk.Label location;
    [GtkChild] private Gtk.Switch enabled;

    public signal void node_changed(DhtNode node);

    private Logger logger;
    private DhtNode node;

    public NodeWidget(Logger logger, DhtNode node) {
      this.logger = logger;
      this.node = node;

      host.label = "%s:%u".printf(node.host,node.port);
      maintainer.label = node.maintainer;
      public_key.label = node.pub_key;
      location.label = emoji_flag(node.location);
      location.tooltip_text = node.location;
      enabled.active = !node.is_blocked;

      enabled.notify["active"].connect(on_active_changed);
      logger.d("NodeWidget created.");
    }

    private string emoji_flag(string location) {
      var country = location.up();
      var ret = "";
      for (int i = 0; i < country.length; i++) {
        string c = ((unichar) (0x1F1A5 + country.@get(i))).to_string();
        ret = ret.concat((string) c);
      }
      return ret;
    }

    private void on_active_changed() {
      node.is_blocked = !enabled.active;
      node_changed(node);
    }

    ~NodeWidget() {
      logger.d("NodeWidget destroyed.");
    }
  }
}
