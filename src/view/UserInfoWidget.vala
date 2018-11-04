/*
 *    UserInfoWidget.vala
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
  [GtkTemplate(ui = "/com/github/naxuroqa/venom/ui/user_info_widget.ui")]
  public class UserInfoWidget : Gtk.Box {
    [GtkChild] private Gtk.Entry entry_username;
    [GtkChild] private Gtk.Entry entry_statusmessage;
    [GtkChild] private Gtk.Image avatar;
    [GtkChild] private Gtk.Label label_id;
    [GtkChild] private Gtk.Button reset_avatar;
    [GtkChild] private Gtk.FileChooserButton filechooser;
    [GtkChild] private Gtk.FlowBox avatars;
    [GtkChild] private Gtk.Button apply;

    [GtkChild] private Gtk.ToggleButton toggle_advanced;
    [GtkChild] private Gtk.Image toggle_arrow;
    [GtkChild] private Gtk.Revealer revealer_advanced;
    [GtkChild] private Gtk.Button button_nospam;
    [GtkChild] private Gtk.Entry entry_nospam;
    [GtkChild] private Gtk.ListBox listbox_nospam;

    private Logger logger;
    private UserInfoViewModel view_model;
    private ObservableList nospams;
    private ObservableListModel nospams_model;
    private ContextStyleBinding toggle_arrow_binding;
    private NospamRepository nospam_repository;

    public UserInfoWidget(Logger logger, ApplicationWindow app_window, NospamRepository nospam_repository, UserInfo user_info, UserInfoViewListener listener) {
      logger.d("UserInfoWidget created.");
      this.logger = logger;
      this.nospam_repository = nospam_repository;
      this.view_model = new UserInfoViewModel(logger, nospam_repository, user_info, listener);

      app_window.reset_header_bar();
      view_model.bind_property("username", app_window.header_bar, "title", GLib.BindingFlags.SYNC_CREATE);
      view_model.bind_property("statusmessage", app_window.header_bar, "subtitle", GLib.BindingFlags.SYNC_CREATE);

      view_model.bind_property("username", entry_username, "text", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("statusmessage", entry_statusmessage, "text", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("avatar", avatar, "pixbuf", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      view_model.bind_property("tox-id", label_id, "label", GLib.BindingFlags.SYNC_CREATE);

      view_model.bind_property("tox-nospam", entry_nospam, "text", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
      entry_nospam.icon_press.connect(view_model.on_random_nospam);

      toggle_advanced.bind_property("active", revealer_advanced, "reveal_child", GLib.BindingFlags.SYNC_CREATE);
      toggle_arrow_binding = new ContextStyleBinding(toggle_arrow, "flip");
      toggle_advanced.bind_property("active", toggle_arrow_binding, "enable", GLib.BindingFlags.SYNC_CREATE);
      button_nospam.clicked.connect(view_model.on_set_nospam_clicked);

      listbox_nospam.row_activated.connect((row) => { ((NospamEntry) row).on_row_clicked(); });

      nospams = new ObservableList();
      reset_nospam_model();
      view_model.reset_nospams.connect(reset_nospam_model);

      var avatar_creator = new AvatarChildCreator(logger);
      avatars.bind_model(view_model.get_avatars_model(), avatar_creator.create);
      avatars.child_activated.connect(on_flowbox_activated);

      var imagefilter = new Gtk.FileFilter();
      imagefilter.set_filter_name(_("Images"));
      imagefilter.add_mime_type("image/*");
      filechooser.add_filter(imagefilter);

      filechooser.file_set.connect(on_file_set);
      reset_avatar.clicked.connect(on_file_reset);
      apply.clicked.connect(view_model.on_apply_clicked);
    }

    private void reset_nospam_model() {
      var nospam_traversable = nospam_repository.query_all()
        .order_by((a, b) => {
          return ((Nospam)b).timestamp.compare(((Nospam)a).timestamp);
        });
      nospams.set_collection(nospam_traversable);
      nospams_model = new ObservableListModel(nospams);
      var nospam_creator = new NospamEntryCreator(logger, view_model);
      listbox_nospam.bind_model(nospams_model, nospam_creator.create);
    }

    private void on_flowbox_activated(Gtk.FlowBoxChild child) {
      view_model.set_file((child as AvatarChild).file);
    }

    private void on_file_set() {
      view_model.set_file(filechooser.get_file());
      avatars.unselect_all();
    }

    private void on_file_reset() {
      view_model.reset_file();
      filechooser.unselect_all();
      avatars.unselect_all();
    }

    ~UserInfoWidget() {
      logger.d("UserInfoWidget destroyed.");
    }

    private class NospamEntryCreator {
      private unowned Logger logger;
      private unowned UserInfoViewModel vm;
      public NospamEntryCreator(Logger logger, UserInfoViewModel vm) {
        this.logger = logger;
        this.vm = vm;
      }

      public Gtk.Widget create(GLib.Object o) {
        var e = new NospamEntry(logger, o as Nospam);
        e.remove_clicked.connect(vm.on_remove_nospam_clicked);
        e.row_activated.connect(vm.on_select_nospam);
        return e;
      }
    }

    private class AvatarChild : Gtk.FlowBoxChild {
      public File file { get; set; }

      private Logger logger;
      public AvatarChild(Logger logger, GLib.File file) {
        this.logger = logger;
        this.file = file;

        var pixbuf = new Gdk.Pixbuf.from_file_at_scale(file.get_path(), 48, 48, true);
        add(new Gtk.Image.from_pixbuf(pixbuf));
        show_all();
        logger.d("AvatarChild created.");
      }

      ~AvatarChild() {
        logger.d("AvatarChild destroyed.");
      }
    }

    private class AvatarChildCreator {
      private Logger logger;
      public AvatarChildCreator(Logger logger) {
        this.logger = logger;
      }
      public Gtk.Widget create(GLib.Object o) {
        return new AvatarChild(logger, o as GLib.File);
      }
    }
  }
}
