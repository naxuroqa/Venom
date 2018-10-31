/*
 *    ObservableList.vala
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
  public class ObservableList : GLib.Object {
    public signal void added(GLib.Object item, uint index);
    public signal void removed(GLib.Object item, uint index);
    public signal void changed();

    private Gee.List<GLib.Object> list = new Gee.ArrayList<GLib.Object>();

    public void set_list(GLib.List<GLib.Object> list) {
      this.list.clear();
      foreach (var item in list) {
        this.list.add(item);
      }
    }

    public void set_collection(Gee.Traversable<GLib.Object> iterable) {
      list.clear();
      iterable.@foreach((item) => {
        list.add(item);
        return true;
      });
    }

    public void append(GLib.Object item) {
      var idx = list.size;
      list.add(item);
      added(item, idx);
      changed();
    }

    public void remove(GLib.Object item) {
      var idx = list.index_of(item);
      removed(item, idx);
      list.remove_at(idx);
      changed();
    }

    public uint length() {
      return list.size;
    }

    public Gee.Iterable<GLib.Object> get_all() {
      return list;
    }

    public uint index(GLib.Object item) {
      return (uint) list.index_of(item);
    }

    public GLib.Object nth_data(uint index) {
      return list.@get((int) index);
    }
  }

  public class ObservableListModel : GLib.Object, GLib.ListModel {
    protected ObservableList list;
    public ObservableListModel(ObservableList list) {
      this.list = list;
      list.added.connect(on_added);
      list.removed.connect(on_removed);
    }

    protected virtual void on_added(GLib.Object item, uint index) {
      items_changed(index, 0, 1);
    }

    protected virtual void on_removed(GLib.Object item, uint index) {
      items_changed(index, 1, 0);
    }

    public virtual GLib.Object ? get_item(uint index) {
      return list.nth_data(index) as GLib.Object;
    }

    public virtual GLib.Type get_item_type() {
      return typeof (GLib.Object);
    }

    public virtual uint get_n_items() {
      return list.length();
    }

    public virtual GLib.Object ? get_object(uint index) {
      return get_item(index);
    }
  }

  public class LazyObservableListModel : ObservableListModel {
    private const int NUM_ENTRIES_PER_ITERATION = 10;
    protected ILogger logger;
    private uint index = 0;
    private bool initialized = false;
    public LazyObservableListModel(ILogger logger, ObservableList list, Cancellable? cancellable = null) {
      base(list);
      this.logger = logger;
      initialize.begin(cancellable);
    }

    private async void initialize(Cancellable? cancellable = null) {
      logger.d("LazyObservableListModel init started.");
      while (list.length() > 0 && index < list.length()) {
        if (cancellable != null && cancellable.is_cancelled()) {
          logger.d("LazyObservableListModel init cancelled.");
          return;
        }

        var num_entries = uint.min(list.length(), index + NUM_ENTRIES_PER_ITERATION) - index;
        items_changed(index, 0, num_entries);
        index += num_entries;
        logger.d(@"LazyObservableListModel init $num_entries more entries.");
        Idle.add(initialize.callback);
        yield;
      }
      initialized = true;
      logger.d("LazyObservableListModel init finished.");
    }

    protected override void on_added(GLib.Object item, uint index) {
      if (!initialized) {
        // ignore while not initialized
        return;
      }
      items_changed(index, 0, 1);
    }

    protected override void on_removed(GLib.Object item, uint index) {
      if (!initialized) {
        // ignore while not initialized
        return;
      }
      items_changed(index, 1, 0);
    }

    public override uint get_n_items() {
      return initialized ? list.length() : uint.min(index, list.length());
    }
  }

}
