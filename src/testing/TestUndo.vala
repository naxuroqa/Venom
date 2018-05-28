/*
 *    TestUndo.vala
 *
 *    Copyright (C) 2018  Venom authors and contributors
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

using Mock;
using Testing;
using Undo;

public class MockCommand : UndoCommand, GLib.Object {
  public void redo() {
    mock().actual_call(this, "redo");
  }
  public void undo() {
    mock().actual_call(this, "undo");
  }
  public bool run_on_init() {
    return mock().actual_call(this, "run_on_init").get_bool();
  }
  public bool try_merge(UndoCommand command) {
    var args = Arguments.builder()
                   .object(command)
                   .create();
    return mock().actual_call(this, "try_merge", args).get_bool();
  }
}

public class TestUndo : UnitTest {
  private UndoStack undo_stack;
  public TestUndo() {
    add_func("/test_undo_stack_init", test_undo_stack_init);
    add_func("/test_undo_stack_add_command", test_undo_stack_add_command);
    add_func("/test_undo_stack_add_command_undo", test_undo_stack_add_command_undo);
    add_func("/test_undo_stack_add_command_undo_redo", test_undo_stack_add_command_undo_redo);
    add_func("/test_undo_stack_add_multi_commands", test_undo_stack_add_multi_commands);
    add_func("/test_undo_stack_add_command_clears_redo", test_undo_stack_add_command_clears_redo);
    add_func("/test_undo_stack_run_init_false", test_undo_stack_run_init_false);
    add_func("/test_undo_stack_run_init_true", test_undo_stack_run_init_true);
    add_func("/test_undo_stack_merge", test_undo_stack_merge);
    add_func("/test_undo_stack_merge_false", test_undo_stack_merge_false);
  }

  public override void set_up() throws Error {
    undo_stack = new SimpleUndoStack();
  }

  private void test_undo_stack_init() throws Error {
    Assert.assert_not_null(undo_stack);
    Assert.assert_false(undo_stack.is_busy);

    var undo_action = undo_stack.create_undo_action("undo");
    Assert.assert_not_null(undo_action);
    Assert.assert_equals<string>("undo", undo_action.name);
    Assert.assert_false(undo_action.enabled);

    var redo_action = undo_stack.create_redo_action("redo");
    Assert.assert_not_null(redo_action);
    Assert.assert_equals<string>("redo", redo_action.name);
    Assert.assert_false(redo_action.enabled);
  }

  private void test_undo_stack_add_command() throws Error {
    var command = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.offer(command);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_stack.clear();

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);
  }

  private void test_undo_stack_add_command_undo() throws Error {
    var command = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.offer(command);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_action.activate(null);

    Assert.assert_true(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.clear();

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);
  }

  private void test_undo_stack_add_command_undo_redo() throws Error {
    var command = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.offer(command);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_action.activate(null);

    Assert.assert_true(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    redo_action.activate(null);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_stack.clear();

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);
  }

  private void test_undo_stack_add_multi_commands() throws Error {
    var command = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.offer(command);
    undo_stack.offer(command);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_action.activate(null);

    Assert.assert_true(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_action.activate(null);

    Assert.assert_true(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    redo_action.activate(null);

    Assert.assert_true(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    redo_action.activate(null);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);

    undo_stack.clear();

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);
  }

  private void test_undo_stack_add_command_clears_redo() throws Error {
    var command = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    Assert.assert_false(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.offer(command);
    undo_action.activate(null);

    Assert.assert_true(redo_action.enabled);
    Assert.assert_false(undo_action.enabled);

    undo_stack.offer(command);

    Assert.assert_false(redo_action.enabled);
    Assert.assert_true(undo_action.enabled);
  }

  private void test_undo_stack_run_init_false() throws Error {
    var command = new MockCommand();
    undo_stack.offer(command);

    verify(command, "run_on_init");
    mock().verify_no_more_interactions(command);
  }

  private void test_undo_stack_run_init_true() throws Error {
    var command = new MockCommand();
    when(command, "run_on_init").set_bool(true);

    undo_stack.offer(command);

    verify(command, "redo");
    verify(command, "run_on_init");
    mock().verify_no_more_interactions(command);
  }

  private void test_undo_stack_merge() throws Error {
    var command = new MockCommand();
    var command2 = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    when(command, "try_merge", args().object(command2).create())
        .set_bool(true);

    undo_stack.offer(command);
    undo_stack.offer(command2);

    Assert.assert_true(undo_action.enabled);
    Assert.assert_false(redo_action.enabled);

    verify(command, "run_on_init");
    verify(command, "try_merge", args().object(command2).create());
    mock().verify_no_more_interactions(command);

    verify(command2, "run_on_init");
    mock().verify_no_more_interactions(command2);

    undo_action.activate(null);
    Assert.assert_false(undo_action.enabled);
    Assert.assert_true(redo_action.enabled);
  }

  private void test_undo_stack_merge_false() throws Error {
    var command = new MockCommand();
    var command2 = new MockCommand();
    var undo_action = undo_stack.create_undo_action("undo");
    var redo_action = undo_stack.create_redo_action("redo");

    undo_stack.offer(command);
    undo_stack.offer(command2);

    Assert.assert_true(undo_action.enabled);
    Assert.assert_false(redo_action.enabled);

    verify(command, "run_on_init");
    verify(command, "try_merge", args().object(command2).create());
    mock().verify_no_more_interactions(command);

    verify(command2, "run_on_init");
    mock().verify_no_more_interactions(command2);

    undo_action.activate(null);
    Assert.assert_true(undo_action.enabled);
    Assert.assert_true(redo_action.enabled);
  }

  private static void main(string[] args) {
    Test.init(ref args);
    var test = new TestUndo();
    assert(test != null);
    Test.run();
  }
}
