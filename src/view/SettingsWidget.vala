/*
 *    SettingsWidget.vala
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
  [GtkTemplate(ui = "/im/tox/venom/ui/settings_widget.ui")]
  public class SettingsWidget : Gtk.Box {
    private ISettingsDatabase settingsDatabase;
    private IDhtNodeDatabase nodeDatabase;
    private ILogger logger;

    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.ListBox sidebar;
    [GtkChild] private Gtk.ListBoxRow row_general;
    [GtkChild] private Gtk.ListBoxRow row_connection;
    [GtkChild] private Gtk.ListBoxRow row_proxy;
    [GtkChild] private Gtk.Widget content_general;
    [GtkChild] private Gtk.Widget content_connection;
    [GtkChild] private Gtk.Widget content_proxy;
    [GtkChild] private Gtk.Switch enable_dark_theme;
    [GtkChild] private Gtk.Switch enable_animations;
    [GtkChild] private Gtk.Switch enable_notify_switch;
    [GtkChild] private Gtk.Switch enable_tray_switch;
    [GtkChild] private Gtk.Switch enable_show_typing;
    [GtkChild] private Gtk.Switch keep_history;
    [GtkChild] private Gtk.Revealer history_revealer;
    [GtkChild] private Gtk.RadioButton history_keep_radio;
    [GtkChild] private Gtk.SpinButton history_delete_spinbutton;
    [GtkChild] private Gtk.ListBox node_list_box;
    [GtkChild] private Gtk.Revealer proxy_revealer;
    [GtkChild] private Gtk.Switch proxy_enabled;
    [GtkChild] private Gtk.RadioButton proxy_system;
    [GtkChild] private Gtk.RadioButton proxy_manual;
    [GtkChild] private Gtk.Revealer proxy_manual_revealer;
    [GtkChild] private Gtk.Entry custom_proxy_host;
    [GtkChild] private Gtk.SpinButton custom_proxy_port;

    private ObservableList dht_nodes;
    private ObservableListModel list_model;

    public SettingsWidget(ISettingsDatabase settingsDatabase, IDhtNodeDatabase nodeDatabase, ILogger logger) {
      logger.d("SettingsWidget created.");
      this.logger = logger;
      this.settingsDatabase = settingsDatabase;
      this.nodeDatabase = nodeDatabase;

      sidebar.select_row(row_general);
      sidebar.row_activated.connect(on_row_activated);

      settingsDatabase.bind_property("enable-dark-theme",   enable_dark_theme,         "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-animations",   enable_animations,         "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-logging",      keep_history,              "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-logging",      history_revealer,          "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("enable-infinite-log", history_keep_radio,        "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("days-to-log",         history_delete_spinbutton, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-send-typing",  enable_show_typing,        "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-urgency-notification", enable_notify_switch, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-tray",         enable_tray_switch,        "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-proxy",        proxy_enabled,             "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-proxy",        proxy_revealer,            "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("enable-custom-proxy", proxy_manual,              "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-custom-proxy", proxy_manual_revealer,     "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("custom-proxy-host",   custom_proxy_host,         "text",   BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("custom-proxy-port",   custom_proxy_port,         "value",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      var dhtNodeFactory = new DhtNodeFactory();
      dht_nodes = new ObservableList();
      dht_nodes.set_list(nodeDatabase.getDhtNodes(dhtNodeFactory));
      list_model = new ObservableListModel(dht_nodes);
      node_list_box.bind_model(list_model, createListboxEntry);
      unmap.connect(() => { node_list_box.bind_model(null, null); });
    }

    ~SettingsWidget() {
      logger.d("SettingsWidget destroyed.");
    }

    private void on_row_activated(Gtk.ListBoxRow row) {
      if (row == row_general) {
        stack.set_visible_child(content_general);
      } else if (row == row_connection) {
        stack.set_visible_child(content_connection);
      } else if (row == row_proxy) {
        stack.set_visible_child(content_proxy);
      }
    }

    private Gtk.Widget createListboxEntry(GLib.Object o) {
      var node = o as IDhtNode;
      var widget = new NodeWidget(logger, node);
      widget.node_changed.connect(on_node_changed);
      return widget;
    }

    private void on_node_changed(IDhtNode node) {
      logger.d("on_node_changed");
      nodeDatabase.insertDhtNode(node.pub_key, node.host, node.port, node.is_blocked, node.maintainer, node.location);
    }
  }
}
