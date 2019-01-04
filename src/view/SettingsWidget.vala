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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/settings_widget.ui")]
  public class SettingsWidget : Gtk.Box {
    private ISettingsDatabase settingsDatabase;
    private DhtNodeRepository node_repository;
    private Logger logger;

    [GtkChild] private Gtk.Stack stack;
    [GtkChild] private Gtk.ListBox sidebar;

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

    [GtkChild] private Gtk.Revealer audio_in_revealer;
    [GtkChild] private Gtk.Revealer audio_out_revealer;
    [GtkChild] private Gtk.Revealer video_in_revealer;

    [GtkChild] private Gtk.Switch audio_in_switch;
    [GtkChild] private Gtk.Switch audio_out_switch;
    [GtkChild] private Gtk.Switch video_in_switch;

    [GtkChild] private Gtk.ComboBoxText audio_in_combo;
    [GtkChild] private Gtk.ComboBoxText audio_out_combo;
    [GtkChild] private Gtk.ComboBoxText video_in_combo;

    [GtkChild] private Gtk.Button audio_out_test;

    [GtkChild] private Gtk.LevelBar audio_in_level;
    [GtkChild] private Gtk.Box video_in_preview;

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

    [GtkChild] private Gtk.ListBox node_list_box;
    [GtkChild] private Gtk.Button update_nodes;

    private ObservableList dht_nodes;
    private ObservableListModel list_model;
    private StackIndexTransform stack_transform;

    private Gee.List<Gst.Device> audio_in_devices;
    private Gee.List<Gst.Device> audio_out_devices;
    private Gee.List<Gst.Device> video_in_devices;

    private AudioInPipeline audio_in_pipeline;
    private VideoInPipeline video_in_pipeline;

    public SettingsWidget(Logger logger, ApplicationWindow? app_window, ISettingsDatabase settingsDatabase, DhtNodeRepository node_repository) {
      logger.d("SettingsWidget created.");
      this.logger = logger;
      this.settingsDatabase = settingsDatabase;
      this.node_repository = node_repository;

      if (app_window != null) {
        app_window.reset_header_bar();
        app_window.header_bar.title = _("Preferences");
      }

      stack_transform = new StackIndexTransform(stack);
      stack.notify["visible-child-name"].connect(on_stack_page_change);
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

      settingsDatabase.bind_property("enable-logging", keep_history, "active", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

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

      audio_in_switch.bind_property("active", audio_in_revealer, "reveal-child", BindingFlags.SYNC_CREATE);
      audio_out_switch.bind_property("active", audio_out_revealer, "reveal-child", BindingFlags.SYNC_CREATE);
      video_in_switch.bind_property("active", video_in_revealer, "reveal-child", BindingFlags.SYNC_CREATE);

      audio_out_test.clicked.connect(start_audio_out_test);

      audio_in_devices = get_devices("Audio/Source");
      audio_out_devices = get_devices("Audio/Sink");
      video_in_devices = get_devices("Video/Source");
      init_av_combo_with_devices(audio_in_combo, audio_in_devices);
      init_av_combo_with_devices(audio_out_combo, audio_out_devices);
      init_av_combo_with_devices(video_in_combo, video_in_devices);

      if (audio_in_devices.is_empty) {
        audio_in_switch.active = false;
        audio_in_switch.sensitive = false;
      }

      if (audio_out_devices.is_empty) {
        audio_out_switch.active = false;
        audio_out_switch.sensitive = false;
      }

      if (video_in_devices.is_empty) {
        video_in_switch.active = false;
        video_in_switch.sensitive = false;
      }

      update_nodes.clicked.connect(update_nodes_from_web);

      dht_nodes = new ObservableList();
      reset_node_list();
    }

    private void on_stack_page_change() {
      if (stack.visible_child_name == "av") {
        start_video_in_test();
        start_audio_in_test();
      } else {
        if (video_in_pipeline != null) {
          video_in_pipeline.stop();
        }
        if (audio_in_pipeline != null) {
          audio_in_pipeline.stop();
        }
      }
    }

    private class GstTestDialog : Gtk.Dialog {
      private Gtk.Widget sink;
      private Gst.Pipeline pipeline;
      public GstTestDialog(Gst.Pipeline pipeline) {
        set_default_size(640, 480);
        this.pipeline = pipeline;
        var sink_element = pipeline.get_by_name("sink");
        sink_element.get("widget", out sink);

        var button_close = (Gtk.Button) add_button(_("Close"), 0);
        button_close.clicked.connect(() => close);

        get_content_area().pack_start(sink);

        pipeline.set_state(Gst.State.PLAYING);
      }
    }

    private Gee.List<Gst.Device> get_devices(string filter) {
      var devices = new Gee.ArrayList<Gst.Device>();
      var monitor = new Gst.DeviceMonitor();
      monitor.add_filter(filter, null);
      monitor.start();
      foreach (var d in monitor.get_devices()) {
        var device_class = d.properties.get_string("device.class");
        if (device_class != "monitor") {
          devices.add(d);
        }
      }
      monitor.stop();
      return devices;
    }

    private void init_av_combo_with_devices(Gtk.ComboBoxText combobox, Gee.List<Gst.Device> devices) {
      combobox.remove_all();
      combobox.append_text(_("Default"));
      foreach (var d in devices) {
        combobox.append_text(d.display_name);
      }
      combobox.active = 0;
    }

    private void start_audio_in_test() {
      var source_device = audio_in_devices.@get(int.max(0, audio_in_combo.get_active() - 1));
      if (audio_in_pipeline == null) {
        audio_in_pipeline = new AudioInPipeline();
        audio_in_pipeline.bind_property("level", audio_in_level, "value", BindingFlags.SYNC_CREATE);
      }
      audio_in_pipeline.start();
    }

    private void start_audio_out_test() {
      var pipeline = (Gst.Pipeline) Gst.parse_launch("audiotestsrc ! tee name=t ! queue ! audioresample ! audioconvert name=ac"
                                                          + " t. ! queue ! audioconvert ! monoscope ! videoconvert ! gtksink name=sink");
      {
        var audioconvert = pipeline.get_by_name("ac");
        var sink_device = audio_out_devices.@get(int.max(0, audio_out_combo.active - 1));
        var sink = sink_device.create_element(null);
        pipeline.add(sink);
        audioconvert.link(sink);
        sink.@ref();
      }

      var test_dialog = new GstTestDialog(pipeline);
      test_dialog.show_all();
      test_dialog.run();
      test_dialog.close();
      pipeline.set_state(Gst.State.NULL);
    }

    private void start_video_in_test() {
      if (video_in_pipeline == null) {
        video_in_pipeline = new VideoInPipeline();

        var get_widget = video_in_pipeline.create_gtk_widget();

        video_in_preview.pack_start(get_widget);
        video_in_preview.show_all();
      }
      video_in_pipeline.start();
    }
    ~SettingsWidget() {
      logger.d("SettingsWidget destroyed.");

      if (video_in_pipeline != null) {
        video_in_pipeline.stop();
      }
      if (audio_in_pipeline != null) {
        audio_in_pipeline.stop();
      }
    }

    private void update_nodes_from_web() {
      logger.d("update_nodes_from_web");
      var updater = new JsonWebDhtNodeUpdater(logger);
      foreach (var node in updater.get_dht_nodes()) {
        node_repository.create(node);
      }
      reset_node_list();
    }

    private void reset_node_list() {
      dht_nodes.set_collection(Compat.order_by<DhtNode>(node_repository.query_all(), (a, b) => {
        return strcmp(a.location, b.location);
      }));
      list_model = new ObservableListModel(dht_nodes);
      var creator = new SettingsDhtNodeCreator(logger, this);
      node_list_box.bind_model(list_model, creator.create_dht_node);
    }

    public void on_node_changed(DhtNode node) {
      logger.d("on_node_changed");
      node_repository.update(node);
    }

    private class SettingsDhtNodeCreator {
      private unowned Logger logger;
      private unowned SettingsWidget settings_widget;
      public SettingsDhtNodeCreator(Logger logger, SettingsWidget settings_widget) {
        this.logger = logger;
        this.settings_widget = settings_widget;
      }

      public Gtk.Widget create_dht_node(GLib.Object o) {
        var node = o as DhtNode;
        var widget = new NodeWidget(logger, node);
        widget.node_changed.connect(settings_widget.on_node_changed);
        return widget;
      }
    }
  }
}
