/*
 *    TestToxAdapterFiletransferListener.vala
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

using Venom;
using Mock;
using Testing;

public class TestToxAdapterFiletransferListener : UnitTest {
  private ObservableList transfers;
  private Logger logger;
  private NotificationListener notification_listener;
  private ToxSession session;
  private ToxAdapterFiletransferListenerImpl listener;
  private FileTransfer transfer;
  private GLib.HashTable<IContact, ObservableList> conversations;
  private IContact contact;

  public TestToxAdapterFiletransferListener() {
    add_func("test_init", test_init);
    add_func("test_attach", test_attach);
    add_func("test_start_transfer", test_start_transfer);
    add_func("test_remove_transfer", test_remove_transfer);
    add_func("test_remove_exception", test_remove_exception);
  }

  public override void set_up() throws Error {
    transfers = new ObservableList();
    logger = new MockLogger();
    notification_listener = new MockNotificationListener();
    session = new MockToxSession();
    transfer = new MockFiletransfer();
    conversations = new GLib.HashTable<IContact, ObservableList>(null, null);
    contact = new MockContact();

    listener = new ToxAdapterFiletransferListenerImpl(logger, transfers, conversations, notification_listener);
  }

  private void test_init() throws Error {
    Assert.assert_not_null(listener);
  }

  private void test_attach() throws Error {
    Assert.assert_not_null(listener);
    listener.attach_to_session(session);

    mock().verify(session, "set_filetransfer_listener", args().object(listener).create());
  }

  private void test_start_transfer() throws Error {
    Assert.assert_not_null(listener);

    mock().when(transfer, "get_friend_number").then_return_int(1);
    mock().when(transfer, "get_file_number").then_return_int(2);

    listener.attach_to_session(session);
    listener.start_transfer(transfer);

    mock().verify(transfer, "get_friend_number");
    mock().verify(transfer, "get_file_number");
    mock().verify(session, "file_control", args().uint(1).uint(2).int(ToxCore.FileControl.RESUME).create());
    mock().verify(transfer, "set_state", args().int(FileTransferState.RUNNING).create());

    mock().verify_no_more_interactions(transfer);
  }

  private void test_remove_transfer() throws Error {
    session.get_friends().set(1, contact);
    var conversation = new ObservableList();
    conversation.append(transfer);
    conversations.set(contact, conversation);

    when(transfer, "get_state").then_return_int(FileTransferState.CANCEL);
    when(transfer, "get_friend_number").then_return_int(1);

    transfers.append(transfer);

    listener.attach_to_session(session);
    listener.remove_transfer(transfer);
    Assert.assert_true(transfers.length() == 0);
  }

  private void test_remove_exception() throws Error {
    session.get_friends().set(2, contact);
    var conversation = new ObservableList();
    conversation.append(transfer);
    conversations.set(contact, conversation);
    when(transfer, "get_friend_number").then_return_int(2);

    mock().when(session, "file_control", args().uint(2).uint(0).int(ToxCore.FileControl.CANCEL).create())
        .then_throw(new ToxError.GENERIC("this should be caught"));

    transfers.append(transfer);
    listener.attach_to_session(session);
    try {
      listener.remove_transfer(transfer);
    } catch (Error e) {
      Assert.assert_true(transfers.length() == 0);
      return;
    }
    Assert.fail();
  }

  private static void main(string[] args) {
    Test.init(ref args);
    var test = new TestToxAdapterFiletransferListener();
    test.run();
  }
}
