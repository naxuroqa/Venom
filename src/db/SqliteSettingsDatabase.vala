/*
 *    SqliteSettingsDatabase.vala
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
  public class SqliteSettingsDatabase : ISettingsDatabase, Object {
    public bool   enable_dark_theme           { get; set; default = false; }
    public bool   enable_animations           { get; set; default = true; }
    public bool   enable_logging              { get; set; default = false; }
    public bool   enable_urgency_notification { get; set; default = true; }
    public bool   enable_tray                 { get; set; default = false; }
    public bool   enable_tray_minimize        { get; set; default = false; }
    public bool   enable_notify               { get; set; default = false; }
    public bool   enable_send_typing          { get; set; default = false; }
    public bool   enable_proxy                { get; set; default = true; }
    public bool   enable_custom_proxy         { get; set; default = false; }
    public string custom_proxy_host           { get; set; default = "localhost"; }
    public int    custom_proxy_port           { get; set; default = 9150; }
    public bool   enable_udp                  { get; set; default = true; }
    public bool   enable_ipv6                 { get; set; default = true; }
    public bool   enable_local_discovery      { get; set; default = true; }
    public bool   enable_hole_punching        { get; set; default = true; }
    public bool   enable_compact_contacts     { get; set; default = false; }
    public bool   enable_notification_sounds  { get; set; default = true; }
    public bool   enable_notification_busy    { get; set; default = false; }
    public bool   enable_spelling             { get; set; default = true; }

    private const string CREATE_TABLE_SETTINGS = """
      CREATE TABLE IF NOT EXISTS Settings (
        id                   INTEGER PRIMARY KEY NOT NULL,
        key                  TEXT                NOT NULL,
        value                                    NOT NULL
      );
    """;

    private enum SettingsColumn {
      ID,
      KEY,
      VALUE
    }

    private const string TABLE_ID = "$ID";
    private const string TABLE_KEY = "$KEY";
    private const string TABLE_VALUE = "$VALUE";

    private static string STATEMENT_INSERT_SETTINGS =
      "INSERT OR REPLACE INTO Settings (id, key, value)"
      + " VALUES (%s, %s, %s);".printf(TABLE_ID, TABLE_KEY, TABLE_VALUE);

    private static string STATEMENT_SELECT_SETTINGS = "SELECT * FROM Settings WHERE id = (%s)".printf(TABLE_ID);

    private DatabaseStatement insertStatement;
    private DatabaseStatement selectStatement;

    private Logger logger;

    public SqliteSettingsDatabase(DatabaseStatementFactory statementFactory, Logger logger) throws DatabaseStatementError {

      this.logger = logger;

      statementFactory
          .create_statement(CREATE_TABLE_SETTINGS)
          .step();

      insertStatement = statementFactory.create_statement(STATEMENT_INSERT_SETTINGS);
      selectStatement = statementFactory.create_statement(STATEMENT_SELECT_SETTINGS);
      logger.d("SqliteSettingsDatabase created.");
    }

    ~SqliteSettingsDatabase() {
      logger.d("SqliteSettingsDatabase destroyed.");
    }

    public void load() {
      logger.d("SqliteSettingsDatabase load.");
      var props = get_class().list_properties();
      selectStatement.reset();
      try {
        foreach (var p in props) {
          var type = p.value_type;
          selectStatement.bind_int(TABLE_ID, (int) p.name.hash());
          if (selectStatement.step() == DatabaseResult.ROW) {
            var val = Value(type);
            if (type == Type.BOOLEAN) {
              val.set_boolean(selectStatement.column_bool(SettingsColumn.VALUE));
            } else if (type == Type.INT) {
              val.set_int(selectStatement.column_int(SettingsColumn.VALUE));
            } else if (type == Type.STRING) {
              val.set_string(selectStatement.column_text(SettingsColumn.VALUE));
            } else {
              logger.e(@"Unsupported type $(type.name()) for property $(p.name).");
              selectStatement.reset();
              continue;
            }
            set_property(p.name, val);
          } else {
            logger.i(@"No settings entry for property $(p.name) found.");
          }
          selectStatement.reset();
        }
      } catch (DatabaseStatementError e) {
        logger.e("Could not retrieve settings from database: " + e.message);
      }
    }

    public void save() {
      logger.d("SqliteSettingsDatabase save.");
      var props = get_class().list_properties();
      try {
        insertStatement.reset();
        foreach (var p in props) {
          var type = p.value_type;
          insertStatement.bind_int(TABLE_ID, (int) p.name.hash());
          insertStatement.bind_text(TABLE_KEY, p.name);
          var val = Value(type);
          get_property(p.name, ref val);
          if (type == Type.BOOLEAN) {
            insertStatement.bind_bool(TABLE_VALUE, val.get_boolean());
          } else if (type == Type.INT) {
            insertStatement.bind_int(TABLE_VALUE, val.get_int());
          } else if (type == Type.STRING) {
            insertStatement.bind_text(TABLE_VALUE, val.get_string());
          } else {
            logger.e(@"Unsupported type $(type.name()) for property $(p.name).");
            insertStatement.reset();
            continue;
          }
          insertStatement.step();
          insertStatement.reset();
        }
      } catch (DatabaseStatementError e) {
        logger.e("Could not retrieve settings from database: " + e.message);
        insertStatement.reset();
      }
    }
  }
}
