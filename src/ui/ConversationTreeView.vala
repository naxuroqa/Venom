/*
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
  public class ConversationTreeView : Gtk.TreeView {
    Gtk.ListStore list_store_messages;

    public ConversationTreeView() {
        list_store_messages = new Gtk.ListStore (1, typeof (Message));

        Gtk.TreeViewColumn name_column = new Gtk.TreeViewColumn();
        Gtk.CellRendererText name_column_cell = new Gtk.CellRendererText();
        name_column_cell.yalign = 0;
        name_column.pack_start(name_column_cell, true);

        Gtk.TreeViewColumn message_column = new Gtk.TreeViewColumn();
        Gtk.CellRendererText message_column_cell = new Gtk.CellRendererText();
        message_column_cell.wrap_mode = Pango.WrapMode.WORD_CHAR;
        message_column.pack_start(message_column_cell, false);
        message_column.expand = true;
        // change wrap width when column size changes
        message_column.notify["width"].connect( () => {message_column_cell.wrap_width = message_column.get_width();});
        
        Gtk.TreeViewColumn time_column = new Gtk.TreeViewColumn();
        Gtk.CellRendererText time_column_cell = new Gtk.CellRendererText();
        time_column_cell.yalign = 0;
        time_column.pack_start(time_column_cell, true);

        name_column.set_cell_data_func(name_column_cell, render_sender_name);
        message_column.set_cell_data_func(message_column_cell, render_message);
        time_column.set_cell_data_func(time_column_cell, render_time);

        set_model (list_store_messages);

        append_column(name_column);
        append_column(message_column);
        append_column(time_column);

        //hide headers
        set_headers_visible(false);
    }
    
    private Message get_message_from_iter(Gtk.TreeIter iter) {
      GLib.Value v;
      model.get_value(iter, 0, out v);
      return v as Message;
    }

    private void render_sender_name (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel tree_model, Gtk.TreeIter iter)
    {
      //TODO move markup into css if possible
      Message m = get_message_from_iter(iter);
      if(m.sender == null)
        (cell as Gtk.CellRendererText).markup = "<span color='#939598'font_weight='bold'>Me</span>";
      else
        (cell as Gtk.CellRendererText).markup = "<b>%s</b>".printf(m.sender.name);
    }

    private void render_message (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel tree_model, Gtk.TreeIter iter)
    {
      Message m = get_message_from_iter(iter);
      (cell as Gtk.CellRendererText).text = "%s".printf(m.message);
    }

    private void render_time (Gtk.CellLayout cell_layout, Gtk.CellRenderer cell, Gtk.TreeModel tree_model, Gtk.TreeIter iter)
    {
      Message m = get_message_from_iter(iter);
      (cell as Gtk.CellRendererText).text = m.time_sent.format("%R");
    }

    public void add_message(Message message) {
      Gtk.TreeIter iter;
      list_store_messages.append (out iter);
      list_store_messages.set (iter, 0, message);
    }

    public void update_message(Message message) {
      //TODO
    }
  }
}
