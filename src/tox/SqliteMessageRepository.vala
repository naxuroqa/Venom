/*
 *    MessageRepository.vala
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
  public class SqliteMessageRepository : MessageRepository, Object {
    private enum MessageColumn { ID, PEERS_INDEX, MESSAGE, STATE, IS_ACTION, TIMESTAMP, TYPE }

    private const string CREATE_TABLE_HISTORY = """
      CREATE TABLE IF NOT EXISTS messages (
        id          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        peers_index INTEGER                           NOT NULL,
        message     TEXT                              NOT NULL,
        state       INTEGER                           NOT NULL,
        is_action   INTEGER                           NOT NULL,
        timestamp   INT64                             NOT NULL,
        type        INTEGER                           NOT NULL
      );
      """;

    private Logger logger;
    private SqliteStatementFactory statement_factory;
    private unowned GLib.HashTable<uint32, IContact> contacts;

    public SqliteMessageRepository(DatabaseStatementFactory statement_factory, Logger logger) throws DatabaseStatementError {
      this.statement_factory = (SqliteStatementFactory) statement_factory;
      this.logger = logger;

      statement_factory
          .create_statement(CREATE_TABLE_HISTORY)
          .step();

      logger.d("SqliteMessageRepository created.");
    }
    ~SqliteMessageRepository() {
      logger.d("SqliteMessageRepository destroyed.");
    }
    private int get_peers_index(string tox_id) {
      var stmt = statement_factory.create_statement(@"SELECT (id) FROM peers WHERE key='$tox_id';");
      if (stmt.step() == DatabaseResult.ROW) {
        return stmt.column_int(0);
      }
      return -1;
    }
    public void set_contacts(GLib.HashTable<uint32, IContact> contacts) {
      this.contacts = contacts;
    }
    public void create(Message message) {
      var m = (ToxMessage) message;
      var peers_index = get_peers_index(m.contact.get_id());
      statement_factory.create_statement(
        """
        INSERT INTO messages (peers_index, message, state, is_action, timestamp, type)
        VALUES ($PEERS_INDEX, $MESSAGE, $STATE, $IS_ACTION, $TIMESTAMP, $TYPE);
        """).builder()
        .bind_int("$PEERS_INDEX", peers_index)
        .bind_text("$MESSAGE", message.message)
        .bind_int("$STATE", message.state)
        .bind_bool("$IS_ACTION", message.is_action)
        .bind_int64("$TIMESTAMP", message.timestamp.to_unix())
        .bind_int("$TYPE", message.sender)
        .step();
      message.id = (int) statement_factory.last_insert_rowid();
    }
    public void update(Message message) {
      statement_factory.create_statement(
        """
        UPDATE messages
        SET message = $MESSAGE,
            state = $STATE,
            is_action = $IS_ACTION,
            timestamp = $TIMESTAMP,
            type = $TYPE
        WHERE id = $ID;
        """).builder()
        .bind_int("$ID", message.id)
        .bind_text("$MESSAGE", message.message)
        .bind_int("$STATE", message.state)
        .bind_bool("$IS_ACTION", message.is_action)
        .bind_int64("$TIMESTAMP", message.timestamp.to_unix())
        .bind_int("$TYPE", message.sender)
        .step();
    }
    public Gee.Iterable<Message> query_all_for_contact(IContact contact) {
      var id = contact.get_id();
      var stmt = statement_factory.create_statement(
        """
        SELECT * FROM (
          SELECT messages.id, peers_index, message, state, is_action, timestamp, type
          FROM messages
          LEFT JOIN peers on peers.id = messages.peers_index
          WHERE peers.key = $KEY
          ORDER BY messages.id DESC LIMIT 50
        )
        ORDER BY id ASC;
        """);
      stmt.bind_text("$KEY", id);
      var result = new Gee.LinkedList<Message>();
      while(stmt.step() == DatabaseResult.ROW) {
        var msg_id = stmt.column_int(MessageColumn.ID);
        var peers_index = stmt.column_int(MessageColumn.PEERS_INDEX);
        var message = stmt.column_text(MessageColumn.MESSAGE);
        var state = (TransmissionState) stmt.column_int(MessageColumn.STATE);
        var is_action = stmt.column_bool(MessageColumn.IS_ACTION);
        var timestamp = new DateTime.from_unix_local(stmt.column_int64(MessageColumn.TIMESTAMP));
        var type = (MessageSender) stmt.column_int(MessageColumn.TYPE);
        var msg = new ToxMessage(contact, type, message, timestamp);
        msg.id = msg_id;
        msg.peers_index = peers_index;
        msg.is_action = is_action;
        msg.state = state;
        result.add(msg);
      }
      return result;
    }
  }
}
