/*
 *    SqliteSettingsDatabase.vala
 *
 *    Copyright (C) 2013-2017  Venom authors and contributors
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
  public class SqliteSettingsDatabase : ISettingsDatabase, Object {
    public bool enable_dark_theme           { get; set; default = false; }
    public bool enable_logging              { get; set; default = false; }
    public bool enable_urgency_notification { get; set; default = true; }
    public bool enable_tray                 { get; set; default = false; }
    public bool enable_notify               { get; set; default = false; }
    public bool enable_infinite_log         { get; set; default = true; }
    public bool enable_send_typing          { get; set; default = false; }
    public int  days_to_log                 { get; set; default = 180; }

    private const string CREATE_TABLE_SETTINGS = """
      CREATE TABLE IF NOT EXISTS Settings (
        id                   INTEGER PRIMARY KEY NOT NULL DEFAULT 0,
        darktheme            INTEGER             NOT NULL,
        logging              INTEGER             NOT NULL,
        urgencynotification  INTEGER             NOT NULL,
        tray                 INTEGER             NOT NULL,
        notify               INTEGER             NOT NULL,
        infinitelog          INTEGER             NOT NULL,
        sendtyping           INTEGER             NOT NULL,
        daystolog            INTEGER             NOT NULL
      );
    """;

    private enum SettingsColumn {
      ID,
      DARKTHEME,
      LOGGING,
      URGENCYNOTIFICATIONS,
      TRAY,
      NOTIFY,
      INFINITELOG,
      SENDTYPING,
      DAYSTOLOG
    }

    private const string TABLE_ID = "$ID";
    private const string TABLE_DARKTHEME = "$DARKTHEME";
    private const string TABLE_LOGGING = "$LOGGING";
    private const string TABLE_URGENCYNOTIFICATIONS = "$URGENCYNOTIFICATIONS";
    private const string TABLE_TRAY = "$TRAY";
    private const string TABLE_NOTIFY = "$NOTIFY";
    private const string TABLE_INFINITELOG = "$INFINITELOG";
    private const string TABLE_SENDTYPING = "$SENDTYPING";
    private const string TABLE_DAYSTOLOG = "$DAYSTOLOG";

    private static string STATEMENT_INSERT_SETTINGS =
      "INSERT OR REPLACE INTO Settings (id, darktheme, logging, urgencynotification, tray, notify, infinitelog, sendtyping, daystolog)" +
      " VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s);"
          .printf(TABLE_ID, TABLE_DARKTHEME, TABLE_LOGGING, TABLE_URGENCYNOTIFICATIONS, TABLE_TRAY, TABLE_NOTIFY, TABLE_INFINITELOG, TABLE_SENDTYPING, TABLE_DAYSTOLOG);
    private static string STATEMENT_SELECT_SETTINGS = "SELECT * FROM Settings WHERE id = 0";

    private IDatabaseStatement insertStatement;
    private IDatabaseStatement selectStatement;

    private ILogger logger;

    private bool initialized = false;

    public SqliteSettingsDatabase(IDatabaseStatementFactory statementFactory, ILogger logger) throws DatabaseStatementError {

      this.logger = logger;

      statementFactory
          .createStatement(CREATE_TABLE_SETTINGS)
          .step();

      insertStatement = statementFactory.createStatement(STATEMENT_INSERT_SETTINGS);
      selectStatement = statementFactory.createStatement(STATEMENT_SELECT_SETTINGS);
      logger.d("SqliteSettingsDatabase created.");
    }

    ~SqliteSettingsDatabase() {
      save();
      logger.d("SqliteSettingsDatabase destroyed.");
    }

    public void load() {
      if (initialized) {
        save();
      }
      initialized = true;

      try {
        if (selectStatement.step() == DatabaseResult.ROW) {
          enable_dark_theme = selectStatement.column_bool(SettingsColumn.DARKTHEME);
          enable_logging = selectStatement.column_bool(SettingsColumn.LOGGING);
          enable_urgency_notification = selectStatement.column_bool(SettingsColumn.URGENCYNOTIFICATIONS);
          enable_tray = selectStatement.column_bool(SettingsColumn.TRAY);
          enable_notify = selectStatement.column_bool(SettingsColumn.NOTIFY);
          enable_infinite_log = selectStatement.column_bool(SettingsColumn.INFINITELOG);
          enable_send_typing = selectStatement.column_bool(SettingsColumn.SENDTYPING);
          days_to_log = selectStatement.column_int(SettingsColumn.DAYSTOLOG);
        } else {
          logger.i("No settings entry found.");
        }
      } catch (DatabaseStatementError e) {
        logger.e("Could not retrieve settings from database: " + e.message);
      } finally {
        selectStatement.reset();
      }
    }

    public void save() {
      try {
        insertStatement.builder()
            .bind_int( TABLE_ID, 0)
            .bind_bool(TABLE_DARKTHEME, enable_dark_theme)
            .bind_bool(TABLE_LOGGING, enable_logging)
            .bind_bool(TABLE_URGENCYNOTIFICATIONS, enable_urgency_notification)
            .bind_bool(TABLE_TRAY, enable_tray)
            .bind_bool(TABLE_NOTIFY, enable_notify)
            .bind_bool(TABLE_INFINITELOG, enable_infinite_log)
            .bind_bool(TABLE_SENDTYPING, enable_send_typing)
            .bind_int( TABLE_DAYSTOLOG, days_to_log)
            .step();
      } catch (DatabaseStatementError e) {
        logger.e("Could not insert settings into database: " + e.message);
      } finally {
        insertStatement.reset();
      }
    }
  }
}
