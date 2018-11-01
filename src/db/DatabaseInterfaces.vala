/*
 *    DatabaseInterfaces.vala
 *
 *    Copyright (C) 2017-2018 Venom authors and contributors
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
  public interface ISettingsDatabase : GLib.Object {
    public abstract bool   enable_dark_theme           { get; set; }
    public abstract bool   enable_animations           { get; set; }
    public abstract bool   enable_logging              { get; set; }
    public abstract bool   enable_urgency_notification { get; set; }
    public abstract bool   enable_tray                 { get; set; }
    public abstract bool   enable_tray_minimize        { get; set; }
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
    public abstract bool   enable_notification_sounds  { get; set; }
    public abstract bool   enable_notification_busy    { get; set; }
    public abstract bool   enable_spelling             { get; set; }

    public abstract void load();
    public abstract void save();
  }

  public interface Specification : GLib.Object {}

  public interface IDhtNodeRepository : GLib.Object {
    public abstract void create(IDhtNode node);
    public abstract void read(IDhtNode node);
    public abstract void update(IDhtNode node);
    public abstract void delete (IDhtNode node);
    public abstract Gee.Iterable<IDhtNode> query_all();
  }

  public interface ILoggedMessage : GLib.Object {}

  public interface ILoggedMessageFactory : GLib.Object {
    public abstract ILoggedMessage createLoggedMessage(string userId, string contactId, string message, DateTime time, bool outgoing);
  }

  // public interface IMessageRepository : GLib.Object {
  //   public abstract void create(IMessage message);
  //   public abstract void read(IMessage message);
  //   public abstract void update(IMessage message);
  //   public abstract void delete (IMessage message);
  //   public abstract void delete_with_spec(Specification spec);
  //   public abstract Gee.Iterable<IMessage> query_all();
  //   public abstract Gee.Iterable<IMessage> query(Specification spec);
  // }

  public interface IMessageDatabase : GLib.Object {
    public abstract void insertMessage(string userId, string contactId, string message, DateTime time, bool outgoing);
    public abstract List<ILoggedMessage> retrieveMessages(string userId, string contactId, ILoggedMessageFactory messageFactory);
    public abstract void deleteMessagesBefore(DateTime date);
  }

  public interface IFriendRequestRepository : GLib.Object {
    public abstract void create(FriendRequest friend_request);
    public abstract void delete (FriendRequest friend_request);
    public abstract Gee.Iterable<FriendRequest> query_all();
  }

  public interface IContactRepository : GLib.Object {
    public abstract void create(IContact contact);
    public abstract void read(IContact contact);
    public abstract void update(IContact contact);
    public abstract void delete (IContact contact);
  }

  public class Nospam : GLib.Object {
    public int id { get; set; }
    public int nospam { get; set; }
    public DateTime timestamp { get; set; }
  }

  public interface INospamRepository : GLib.Object {
    public abstract void create(Nospam friend_request);
    public abstract void delete (Nospam friend_request);
    public abstract Gee.Iterable<Nospam> query_all();
  }

  public errordomain DatabaseStatementError {
    PREPARE,
    STEP,
    INDEX,
    BIND
  }

  public errordomain DatabaseError {
    OPEN,
    QUERY,
    EXEC
  }

  public enum DatabaseResult {
    OK,
    DONE,
    ROW,
    ERROR,
    ABORT,
    OTHER
  }

  public interface IDatabase : GLib.Object {
  }

  public interface IDatabaseStatement : GLib.Object {
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

  public interface IDatabaseStatementBuilder : GLib.Object {
    public abstract IDatabaseStatementBuilder step() throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_text(string key, string val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_int64(string key, int64 val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_int(string key, int val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder bind_bool(string key, bool val) throws DatabaseStatementError;
    public abstract IDatabaseStatementBuilder reset();
  }

  public interface IDatabaseFactory : GLib.Object {
    public abstract IDatabase createDatabase(string path) throws DatabaseError;
    public abstract IDatabaseStatementFactory create_statement_factory(IDatabase database);

    public abstract IDhtNodeRepository create_node_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract IContactRepository create_contact_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract IMessageDatabase createMessageDatabase(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract ISettingsDatabase create_settings_database(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract IFriendRequestRepository create_friend_request_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
    public abstract INospamRepository create_nospam_repository(IDatabaseStatementFactory factory, ILogger logger) throws DatabaseStatementError;
  }

  public interface IDatabaseStatementFactory : GLib.Object {
    public abstract IDatabaseStatement create_statement(string zSql) throws DatabaseStatementError;
  }
}
