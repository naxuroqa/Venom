/*
 *    SettingsWidget.vala
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
  [GtkTemplate(ui = "/chat/tox/venom/ui/settings_widget.ui")]
  public class SettingsWidget : Gtk.Box {
    private ISettingsDatabase settingsDatabase;
    private IDhtNodeDatabase nodeDatabase;
    private ILogger logger;

    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.ListBox sidebar;
    [GtkChild] private Gtk.ListBox node_list_box;

    [GtkChild] private Gtk.Switch enable_dark_theme;
    [GtkChild] private Gtk.Switch enable_animations;
    [GtkChild] private Gtk.Switch enable_compact_contacts;
    [GtkChild] private Gtk.Switch enable_spelling;

    [GtkChild] private Gtk.Switch enable_tray_switch;
    [GtkChild] private Gtk.Revealer tray_revealer;
    [GtkChild] private Gtk.Switch enable_minimize_switch;

    [GtkChild] private Gtk.Switch enable_notify_switch;
    [GtkChild] private Gtk.Revealer notify_revealer;
    [GtkChild] private Gtk.Switch enable_notify_sounds_switch;
    [GtkChild] private Gtk.Switch enable_notify_busy_switch;

    [GtkChild] private Gtk.Switch enable_show_typing;

    [GtkChild] private Gtk.Switch keep_history;
    [GtkChild] private Gtk.Revealer history_revealer;
    [GtkChild] private Gtk.RadioButton history_keep_radio;
    [GtkChild] private Gtk.SpinButton history_delete_spinbutton;

    [GtkChild] private Gtk.Switch enable_udp;
    [GtkChild] private Gtk.Switch enable_ipv6;
    [GtkChild] private Gtk.Switch enable_local_discovery;
    [GtkChild] private Gtk.Switch enable_hole_punching;

    [GtkChild] private Gtk.Switch proxy_enabled;
    [GtkChild] private Gtk.Revealer proxy_revealer;
    [GtkChild] private Gtk.Revealer proxy_manual_revealer;
    [GtkChild] private Gtk.RadioButton proxy_manual;
    [GtkChild] private Gtk.Entry custom_proxy_host;
    [GtkChild] private Gtk.SpinButton custom_proxy_port;

    private ObservableList dht_nodes;
    private ObservableListModel list_model;
    private StackIndexTransform stack_transform;

    public SettingsWidget(ILogger logger, ApplicationWindow? app_window, ISettingsDatabase settingsDatabase, IDhtNodeDatabase nodeDatabase) {
      logger.d("SettingsWidget created.");
      this.logger = logger;
      this.settingsDatabase = settingsDatabase;
      this.nodeDatabase = nodeDatabase;

      if (app_window != null) {
        app_window.reset_header_bar();
        app_window.header_bar.title = _("Preferences");
      }

      stack_transform = new StackIndexTransform(stack);
      sidebar.select_row(sidebar.get_row_at_index(0));
      sidebar.row_selected.connect(stack_transform.transform_list_box_row);

      settingsDatabase.bind_property("enable-dark-theme",       enable_dark_theme,       "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-animations",       enable_animations,       "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-compact-contacts", enable_compact_contacts, "active",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-spelling",         enable_spelling,         "active",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settingsDatabase.bind_property("enable-tray",          enable_tray_switch,     "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-tray",          tray_revealer,          "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("enable-tray-minimize", enable_minimize_switch, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settingsDatabase.bind_property("enable-urgency-notification", enable_notify_switch,        "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-urgency-notification", notify_revealer,             "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("enable-notification-sounds",  enable_notify_sounds_switch, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-notification-busy",    enable_notify_busy_switch,   "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settingsDatabase.bind_property("enable-send-typing", enable_show_typing, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settingsDatabase.bind_property("enable-logging",      keep_history,              "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-logging",      history_revealer,          "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("enable-infinite-log", history_keep_radio,        "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("days-to-log",         history_delete_spinbutton, "value", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settingsDatabase.bind_property("enable-udp",             enable_udp,             "active",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-ipv6",            enable_ipv6,            "active",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-local-discovery", enable_local_discovery, "active",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-hole-punching",   enable_hole_punching,   "active",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      settingsDatabase.bind_property("enable-proxy",        proxy_enabled,         "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-proxy",        proxy_revealer,        "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("enable-custom-proxy", proxy_manual,          "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("enable-custom-proxy", proxy_manual_revealer, "reveal-child", BindingFlags.SYNC_CREATE);
      settingsDatabase.bind_property("custom-proxy-host",   custom_proxy_host,     "text",   BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
      settingsDatabase.bind_property("custom-proxy-port",   custom_proxy_port,     "value",  BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

      var dhtNodeFactory = new DhtNodeFactory();
      dht_nodes = new ObservableList();
      dht_nodes.set_list(nodeDatabase.getDhtNodes(dhtNodeFactory));
      list_model = new ObservableListModel(dht_nodes);
      var creator = new SettingsDhtNodeCreator(logger, this);
      node_list_box.bind_model(list_model, creator.create_dht_node);
    }

    ~SettingsWidget() {
      logger.d("SettingsWidget destroyed.");
    }

    public void on_node_changed(IDhtNode node) {
      logger.d("on_node_changed");
      nodeDatabase.insertDhtNode(node.pub_key, node.host, node.port, node.is_blocked, node.maintainer, node.location);
    }

    private class SettingsDhtNodeCreator {
      private unowned ILogger logger;
      private unowned SettingsWidget settings_widget;
      public SettingsDhtNodeCreator(ILogger logger, SettingsWidget settings_widget) {
        this.logger = logger;
        this.settings_widget = settings_widget;
      }

      public Gtk.Widget create_dht_node(GLib.Object o) {
        var node = o as IDhtNode;
        var widget = new NodeWidget(logger, node);
        widget.node_changed.connect(settings_widget.on_node_changed);
        return widget;
      }
    }
  }
}
