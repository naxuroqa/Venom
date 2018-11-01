/*
 *    SqliteNospamRepository.vala
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
  public class SqliteNospamRepository : INospamRepository, Object {
    private const string CREATE_TABLE_NOSPAMS = """
      CREATE TABLE IF NOT EXISTS nospams (
        id        INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nospam    INTEGER                           NOT NULL,
        timestamp INT64                             NOT NULL
      );
    """;

    private enum NospamColumn { ID, NOSPAM, TIMESTAMP }

    private ILogger logger;
    private SqliteStatementFactory statement_factory;

    public SqliteNospamRepository(IDatabaseStatementFactory statement_factory, ILogger logger) throws DatabaseStatementError {
      this.logger = logger;
      this.statement_factory = (SqliteStatementFactory) statement_factory;

      statement_factory
          .create_statement(CREATE_TABLE_NOSPAMS)
          .step();

      logger.d("SqliteNospamRepository created.");
    }

    ~SqliteNospamRepository() {
      logger.d("SqliteNospamRepository destroyed.");
    }
    public void create(Nospam nospam) {
      statement_factory.create_statement(
        """
        INSERT INTO nospams (nospam, timestamp)
        VALUES ($NOSPAM, $TIMESTAMP);
        """).builder()
          .bind_int("$NOSPAM", nospam.nospam)
          .bind_int64("$TIMESTAMP", nospam.timestamp.to_unix())
          .step();
      nospam.id = (int) statement_factory.last_insert_rowid();
    }
    public void delete (Nospam nospam) {
      statement_factory.create_statement(
        """
        DELETE FROM nospams
        WHERE id=$ID;
        """).builder()
          .bind_int("$ID", nospam.id)
          .step();
    }
    public Gee.Iterable<Nospam> query_all() {
      var list = new Gee.LinkedList<Nospam>();
      var query_stmt = statement_factory.create_statement("SELECT * FROM nospams;");
      while (query_stmt.step() == DatabaseResult.ROW) {
        var nospam = new Nospam();
        nospam.id = query_stmt.column_int(NospamColumn.ID);
        nospam.nospam = query_stmt.column_int(NospamColumn.NOSPAM);
        nospam.timestamp = new DateTime.from_unix_local(query_stmt.column_int64(NospamColumn.TIMESTAMP));
        list.add(nospam);
      }
      return list;
    }
  }
}
