/*
 *    DatabaseInterfaces.vala
 *
 *    Copyright (C) 2017  Venom authors and contributors
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
  public interface ISettingsDatabase : Object {
    public abstract bool   enable_dark_theme           { get; set; }
    public abstract bool   enable_animations           { get; set; }
    public abstract bool   enable_logging              { get; set; }
    public abstract bool   enable_urgency_notification { get; set; }
    public abstract bool   enable_tray                 { get; set; }
    public abstract bool   enable_notify               { get; set; }
    public abstract bool   enable_infinite_log         { get; set; }
    public abstract bool   enable_send_typing          { get; set; }
    public abstract int    days_to_log                 { get; set; }
    public abstract bool   enable_proxy                { get; set; }
    public abstract bool   enable_custom_proxy         { get; set; }
    public abstract string custom_proxy_host           { get; set; }
    public abstract int    custom_proxy_port           { get; set; }
    public abstract bool   enable_udp                  { get; set; }
    public abstract bool   enable_ipv6                 { get; set; }
    public abstract bool   enable_local_discovery      { get; set; }
    public abstract bool   enable_hole_punching        { get; set; }
    public abstract bool   enable_compact_contacts     { get; set; }

    public abstract void load();
    public abstract void save();
  }

  public interface IDhtNodeDatabase : Object {
    public abstract void insertDhtNode(string key, string address, uint port, bool isBlocked, string owner, string location);
    public abstract List<IDhtNode> getDhtNodes(IDhtNodeFactory factory);
    public abstract void deleteDhtNode(string key);
  }

  public interface IDhtNodeFactory : Object {
    public abstract IDhtNode createDhtNode(string key, string address, uint port, bool blocked, string owner, string location);
  }

  public interface ILoggedMessage : Object {}

  public interface ILoggedMessageFactory : Object {
    public abstract ILoggedMessage createLoggedMessage(string userId, string contactId, string message, DateTime time, bool outgoing);
  }

  public interface IMessageDatabase : Object {
    public abstract void insertMessage(string userId, string contactId, string message, DateTime time, bool outgoing);
    public abstract List<ILoggedMessage> retrieveMessages(string userId, string contactId, ILoggedMessageFactory messageFactory);
    public abstract void deleteMessagesBefore(DateTime date);
  }

  public interface IContactDatabase : Object {
    public abstract void loadContactData(string userId, IContactData contactData);
    public abstract void saveContactData(string userId, string note, string alias, bool isBlocked, string group);
    public abstract void deleteContactData(string userId);
  }

  public interface IContactData : Object {
    public abstract void saveContactData(string note, string alias, bool isBlocked, string group);
  }

  public errordomain DatabaseStatementError {
    PREPARE,
    STEP,
    INDEX,
    BIND
  }

  public errordomain DatabaseError {
    OPEN,
    QUERY
  }

  public enum DatabaseResult {
    OK,
    DONE,
    ROW,
    ERROR,
    ABORT,
    OTHER
  }

  public interface IDatabase : Object {
  }

  public interface IDatabaseStatement : Object {
    public abstract DatabaseResult step() throws DatabaseStatementError;
    public abstract void bind_text(string key, string val) throws DatabaseStatementError;
    public abstract void bind_int64(string key, int64 val) throws DatabaseStatementError;
    public abstract void bind_int(string key, int val) throws DatabaseStatementError;
    public abstract void bind_bool(string key, bool val) throws DatabaseStatementError;
    public abstract string column_text(int key) throws DatabaseStatementError;
    public abstract int64 column_int64(int key) throws DatabaseStatementError;
    public abstract int column_int(int key) throws DatabaseStatementError;
    public abstract bool column_bool(int key) throws DatabaseStatementError;
    public abstract void reset();
    public abstract IDatabaseStatementBuilder builder();
  }

  public interface IDatabaseStatementBuilder : Object {
    public abstract IDatabaseStatementBuilder step() throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_text(string key, string val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_int64(string key, int64 val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_int(string key, int val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_bool(string key, bool val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder reset();
  }

  public interface IDatabaseFactory : Object {
    public abstract IDatabase createDatabase(string path) throws DatabaseError;
    public abstract IDatabaseStatementFactory createStatementFactory(IDatabase database);

    public abstract IDhtNodeDatabase createNodeDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract IContactDatabase createContactDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract IMessageDatabase createMessageDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract ISettingsDatabase createSettingsDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
  }

  public interface IDatabaseStatementFactory : Object {
    public abstract IDatabaseStatement createStatement(string zSql) throws DatabaseStatementError;
  }
}
