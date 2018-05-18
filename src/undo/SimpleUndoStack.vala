/*
 *    SimpleUndoStack.vala
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
  public class SimpleUndoStack : UndoStack, GLib.Object {
    public bool is_busy { get; protected set; }

    private Gee.Deque<UndoCommand> undo_stack;
    private Gee.Deque<UndoCommand> redo_stack;
    private GLib.SimpleAction undo_action;
    private GLib.SimpleAction redo_action;

    public SimpleUndoStack() {
      undo_stack = new Gee.LinkedList<UndoCommand>();
      redo_stack = new Gee.LinkedList<UndoCommand>();
    }

    public virtual void clear() {
      if (undo_action != null && !undo_stack.is_empty) {
        undo_action.set_enabled(false);
      }
      if (redo_action != null && !redo_stack.is_empty) {
        redo_action.set_enabled(false);
      }
      undo_stack.clear();
      redo_stack.clear();
    }

    public virtual void offer(UndoCommand command) {
      is_busy = true;
      if (command.run_on_init()) {
        command.redo();
      }

      if (undo_action != null && undo_stack.is_empty) {
        undo_action.set_enabled(true);
      }

      if (!redo_stack.is_empty || undo_stack.is_empty || !undo_stack.peek_tail().try_merge(command)) {
        undo_stack.offer_tail(command);
      }

      if (redo_action != null && !redo_stack.is_empty) {
        redo_action.set_enabled(false);
      }
      redo_stack.clear();
      is_busy = false;
    }

    private void undo() {
      is_busy = true;
      var command = undo_stack.poll_tail();
      if (undo_action != null && undo_stack.is_empty) {
        undo_action.set_enabled(false);
      }

      command.undo();
      if (redo_action != null && redo_stack.is_empty) {
        redo_action.set_enabled(true);
      }
      redo_stack.offer_tail(command);
      is_busy = false;
    }

    private void redo() {
      is_busy = true;
      var command = redo_stack.poll_tail();
      if (redo_action != null && redo_stack.is_empty) {
        redo_action.set_enabled(false);
      }

      command.redo();
      if (undo_action != null && undo_stack.is_empty) {
        undo_action.set_enabled(true);
      }
      undo_stack.offer_tail(command);
      is_busy = false;
    }

    public virtual GLib.Action create_undo_action(string name) {
      if (undo_action == null) {
        undo_action = new GLib.SimpleAction(name, null);
        undo_action.activate.connect(undo);
        undo_action.set_enabled(!undo_stack.is_empty);
      }
      return undo_action;
    }

    public virtual GLib.Action create_redo_action(string name) {
      if (redo_action == null) {
        redo_action = new GLib.SimpleAction(name, null);
        redo_action.activate.connect(redo);
        redo_action.set_enabled(!redo_stack.is_empty);
      }
      return redo_action;
    }
  }
}
