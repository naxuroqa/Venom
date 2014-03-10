/*
 *    GroupConversationSidebar.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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
  public interface IGroupConversationSidebar : Gtk.Widget {
    public abstract GroupChat groupchat { get; set; }
    public abstract void update_contact(int peernumber, Tox.ChatChange change);
    public abstract Gtk.TreeModel model { get; set; }
  }

  public class GroupConversationSidebar : Gtk.TreeView, IGroupConversationSidebar {

    public enum TreeModelColumn {
      ID,
      NAME,
      COLLATE_KEY
    }

    Gtk.ListStore listmodel;
    public GroupChat groupchat { get; set; }
    public GroupConversationSidebar( GroupChat groupchat ) {
      this.groupchat = groupchat;
      listmodel = new Gtk.ListStore (3, typeof(int), typeof(string), typeof(string));
      Gtk.TreeModelSort sort = new Gtk.TreeModelSort.with_model(listmodel);
      sort.set_sort_func(TreeModelColumn.NAME, sort_name);
      sort.set_sort_column_id(TreeModelColumn.NAME, Gtk.SortType.ASCENDING);
      set_model (sort);

      insert_column_with_attributes (-1, "Name", new Gtk.CellRendererText(),
                                         "text", TreeModelColumn.NAME);
      init_contacts();
    }

    private void init_contacts() {
      listmodel.clear();
      groupchat.peers.foreach ((key, val) => {
        GroupChatContact gcc = val as GroupChatContact;
        add_contact(gcc.group_contact_id, gcc.name);
	    });
    }

    private int sort_name(Gtk.TreeModel model, Gtk.TreeIter a, Gtk.TreeIter b) {
      int ret = 0;
      string string_a, string_b;
      model.get(a, TreeModelColumn.COLLATE_KEY, out string_a, -1);
      model.get(b, TreeModelColumn.COLLATE_KEY, out string_b, -1);
      if(string_a == null || string_b == null) {
        if(string_a == null && string_b == null) {
          return ret;
        }
        ret = (string_b == null) ? 1 : -1;
      } else {
        ret = string_a > string_b ? 1 : -1;
      }
      return ret;
    }

    private void set_contact(Gtk.TreeIter iter, int id, string? name) {
      string name_str = name ?? "<unknown>";
      string collate_key = name_str.casefold().collate_key();
      listmodel.set(iter, TreeModelColumn.ID, id,
                          TreeModelColumn.NAME, name ?? "<unknown>",
                          TreeModelColumn.COLLATE_KEY, collate_key);
    }

    private void add_contact(int peernumber, string? name) {
      Gtk.TreeIter? iter = find_contact(peernumber);
      if(iter == null) {
        listmodel.append (out iter);
      }
	    set_contact(iter, peernumber, name);
    }

    private Gtk.TreeIter? find_contact(int peernumber) {
      Gtk.TreeIter iter;
      if( listmodel.get_iter_first(out iter) ) {
        do {
          GLib.Value val;
          listmodel.get_value(iter, TreeModelColumn.ID, out val);
          if(val.get_int() == peernumber) {
            return iter;
          }
        } while( listmodel.iter_next(ref iter) );
      }

      return null;
    }

    private void update_contact_name(int peernumber, string new_name) {
      Gtk.TreeIter? iter = find_contact(peernumber);
      if(iter != null) {
        set_contact(iter, peernumber, new_name);
      } else {
        stderr.printf("Sidebar could not update peer #%i\n", peernumber);
      }
    }

    private void delete_contact(int peernumber) {
      Gtk.TreeIter? iter = find_contact(peernumber);
      if(iter != null) {
        listmodel.remove(iter);
      } else {
        stderr.printf("Sidebar could not remove peer #%i\n", peernumber);
      }
    }

    public void update_contact(int peernumber, Tox.ChatChange change) {
      if(change == Tox.ChatChange.PEER_ADD) {
        add_contact(peernumber, groupchat.peers.get(peernumber).name);
      } else if(change == Tox.ChatChange.PEER_DEL) {
        delete_contact(peernumber);
      } else if(change == Tox.ChatChange.PEER_NAME) {
        update_contact_name(peernumber, groupchat.peers.get(peernumber).name);
      } else {
        GLib.assert_not_reached();
      }
    }
  }
}
