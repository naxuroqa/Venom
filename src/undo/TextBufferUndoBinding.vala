/*
 *    TextBufferEditCommand.vala
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

namespace Undo {
  public abstract class TextBufferEditCommand : UndoCommand, GLib.Object {
    protected unowned Gtk.TextBuffer buffer;
    protected string text;
    protected int start;
    protected int end;

    public abstract void redo();
    public abstract void undo();
    public abstract bool try_merge(UndoCommand command);

    public virtual bool run_on_init() {
      return false;
    }

    protected void place_cursor(int position) {
      Gtk.TextIter iter;
      buffer.get_iter_at_offset(out iter, position);
      buffer.place_cursor(iter);
    }

    protected void insert_section() {
      Gtk.TextIter iter_start;
      buffer.get_iter_at_offset(out iter_start, start);
      buffer.begin_user_action();
      buffer.insert(ref iter_start, text, -1);
      buffer.end_user_action();
    }

    protected void delete_section() {
      Gtk.TextIter iter_start;
      Gtk.TextIter iter_end;

      buffer.get_iter_at_offset(out iter_start, start);
      buffer.get_iter_at_offset(out iter_end, end);
      buffer.begin_user_action();
      buffer.delete (ref iter_start, ref iter_end);
      buffer.end_user_action();
    }
  }

  public class DeleteRangeCommand : TextBufferEditCommand {
    public DeleteRangeCommand(Gtk.TextBuffer buffer, ref Gtk.TextIter start, ref Gtk.TextIter end) {
      this.buffer = buffer;
      this.text = buffer.get_slice(start, end, true);
      this.start = start.get_offset();
      this.end = end.get_offset();
    }

    public override bool try_merge(UndoCommand command) {
      if (command is DeleteRangeCommand) {
        var c = command as DeleteRangeCommand;
        if (c.buffer == buffer && (c.end - c.start == 1)) {
          if (c.end == start) {
            text = c.text + text;
            start = c.start;
            end = start + text.char_count();
            return true;
          } else if (end == c.start) {
            text += c.text;
            end = start + text.char_count();
            return true;
          }
        }
      }
      return false;
    }

    public override void redo() {
      delete_section();
      place_cursor(start);
    }

    public override void undo() {
      insert_section();
      place_cursor(end);
    }
  }

  public class InsertTextCommand : TextBufferEditCommand {
    public InsertTextCommand(Gtk.TextBuffer buffer, ref Gtk.TextIter pos, string text, int length) {
      this.buffer = buffer;
      this.text = text.substring(0, length);
      this.start = pos.get_offset();
      this.end = start + this.text.char_count();
    }

    public override bool try_merge(UndoCommand command) {
      if (command is InsertTextCommand) {
        var c = command as InsertTextCommand;
        if (c.buffer == buffer && (c.end - c.start == 1)) {
          if (c.start == start) {
            text = c.text + text;
            end = start + text.char_count();
            return true;
          } else if (c.start == end && !c.text.get_char().isspace()) {
            text += c.text;
            end = start + text.char_count();
            return true;
          }
        }
      }
      return false;
    }

    public override void redo() {
      insert_section();
      place_cursor(end);
    }

    public override void undo() {
      delete_section();
      place_cursor(start);
    }
  }

  public class TextBufferUndoBinding : GLib.Object {
    public Gtk.TextBuffer buffer { get; set; }
    public UndoStack undo_stack { get; set; }
    public GLib.Action undo_action { get; set; }
    public GLib.Action redo_action { get; set; }

    public TextBufferUndoBinding() {
      this.undo_stack = new SimpleUndoStack();
      this.undo_action = undo_stack.create_undo_action("undo");
      this.redo_action = undo_stack.create_redo_action("redo");
    }

    public void add_actions_to(GLib.ActionMap action_map) {
      action_map.add_action(undo_action);
      action_map.add_action(redo_action);
    }

    public void bind_buffer(Gtk.TextBuffer buffer) {
      this.buffer = buffer;
      buffer.insert_text.connect(on_buffer_insert_text);
      buffer.delete_range.connect(on_buffer_delete_range);
    }

    public void clear() {
      undo_stack.clear();
    }

    public void populate_popup(Gtk.Menu menu) {
      var separator = new Gtk.SeparatorMenuItem();
      separator.show();
      menu.prepend(separator);
      var redo = new Gtk.MenuItem.with_mnemonic(_("_Redo"));
      redo_action.bind_property("enabled", redo, "sensitive", BindingFlags.SYNC_CREATE);
      redo.activate.connect(() => { redo_action.activate(null); });
      redo.show();
      menu.prepend(redo);
      var undo = new Gtk.MenuItem.with_mnemonic(_("_Undo"));
      undo_action.bind_property("enabled", undo, "sensitive", BindingFlags.SYNC_CREATE);
      undo.activate.connect(() => { undo_action.activate(null); });
      undo.show();
      menu.prepend(undo);
    }

    private void on_buffer_insert_text(ref Gtk.TextIter pos, string text, int len) {
      if (!undo_stack.is_busy) {
        undo_stack.offer(new InsertTextCommand(buffer, ref pos, text, len));
      }
    }

    private void on_buffer_delete_range(ref Gtk.TextIter start, ref Gtk.TextIter end) {
      if (!undo_stack.is_busy) {
        undo_stack.offer(new DeleteRangeCommand(buffer, ref start, ref end));
      }
    }
  }
}
