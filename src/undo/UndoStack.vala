/*
 *    UndoStack.vala
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
  public interface UndoStack : GLib.Object {
    public abstract bool is_busy { get; protected set; }
    public abstract void offer(UndoCommand command);
    public abstract void clear();
    public abstract GLib.Action create_undo_action(string name);
    public abstract GLib.Action create_redo_action(string name);
  }
}
