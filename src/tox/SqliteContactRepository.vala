/*
 *    SqliteContactRepository.vala
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
  public class SqliteContactRepository : ContactRepository, Object {
    private const string CREATE_TABLES = """
      CREATE TABLE IF NOT EXISTS peers (
        id      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        key     TEXT                              NOT NULL UNIQUE
      );
      CREATE TABLE IF NOT EXISTS peer_settings (
        peers_index    INTEGER PRIMARY KEY NOT NULL,
        alias          TEXT                NOT NULL,
        auto_accept_ci INTEGER             NOT NULL,
        auto_accept_ft INTEGER             NOT NULL,
        ft_directory   TEXT                NOT NULL,
        notifications  INTEGER             NOT NULL
      );
    """;

    private enum PeersColumn { ID, KEY }
    private enum PeerSettingsColumn { PEER_KEY, ALIAS, AUTO_ACCEPT_CI, AUTO_ACCEPT_FT, FT_DIRECTORY, NOTIFICATIONS }

    private Logger logger;

    private SqliteStatementFactory statementFactory;

    public SqliteContactRepository(DatabaseStatementFactory statementFactory, Logger logger) throws DatabaseStatementError, DatabaseError {
      this.logger = logger;

      this.statementFactory = (SqliteStatementFactory) statementFactory;
      this.statementFactory.query_database(CREATE_TABLES);

      logger.d("SqliteContactRepository created.");
    }

    public void create(IContact contact) {
      logger.d("ContactRepository create");
      var c = contact as Contact;
      var id = get_id(c);
      if (id >= 0) {
        logger.i("Found contact in database, restoring contact settings");
        c.db_id = id;
        read(contact);
      } else {
        logger.i("Creating contact in database");
        statementFactory.create_statement("INSERT INTO peers (key) VALUES ($KEY);")
          .builder()
          .bind_text("$KEY", c.tox_id)
          .step();
        c.db_id = (int) statementFactory.last_insert_rowid();
        update(contact);
      }
    }

    private int get_id(Contact contact) {
      var key = contact.tox_id;
      var query = statementFactory.query_database(@"SELECT (id) FROM peers WHERE key='$key';");
      if (query.rows != null && query.rows.length >= 1 && query.rows[0].n_columns > 0) {
        return int.parse(query.rows[0].values[0]);
      }
      return -1;
    }

    public void read(IContact contact) {
      logger.d("ContactRepository read");
      var c = contact as Contact;
      var stmt = statementFactory.create_statement("SELECT * FROM peer_settings WHERE peers_index = $PEER_INDEX");
      stmt.bind_int("$PEER_INDEX", c.db_id);

      if (stmt.step() == DatabaseResult.ROW) {
        c.alias = stmt.column_text(PeerSettingsColumn.ALIAS);
        c.auto_conference = stmt.column_bool(PeerSettingsColumn.AUTO_ACCEPT_CI);
        c.auto_filetransfer = stmt.column_bool(PeerSettingsColumn.AUTO_ACCEPT_FT);
        c.auto_location = stmt.column_text(PeerSettingsColumn.FT_DIRECTORY);
        c._show_notifications = stmt.column_bool(PeerSettingsColumn.NOTIFICATIONS);
      } else {
        logger.e("Could not read contact");
      }
    }
    public void update(IContact contact) {
      logger.d("ContactRepository update");
      var c = contact as Contact;
      statementFactory.create_statement(
        """INSERT OR REPLACE INTO peer_settings
             (peers_index, alias, auto_accept_ci, auto_accept_ft, ft_directory, notifications)
           VALUES ($PEER_INDEX, $ALIAS, $AUTO_CI, $AUTO_FT, $FT_DIR, $NOTIFICATIONS);
        """)
        .builder()
        .bind_int("$PEER_INDEX", c.db_id)
        .bind_text("$ALIAS", c.alias)
        .bind_bool("$AUTO_CI", c.auto_conference)
        .bind_bool("$AUTO_FT", c.auto_filetransfer)
        .bind_text("$FT_DIR", c.auto_location)
        .bind_bool("$NOTIFICATIONS", c._show_notifications)
        .step();
    }
    public void delete(IContact contact) {
      logger.d("ContactRepository delete");
      var c = contact as Contact;
      if (c.db_id >= 0) {
        statementFactory.create_statement("DELETE FROM peer_settings WHERE peers_index=$PEER_INDEX;")
        .builder()
        .bind_int("$PEER_INDEX", c.db_id)
        .step();
      }
    }
    ~SqliteContactRepository() {
      logger.d("SqliteContactRepository destroyed.");
    }
  }
}
