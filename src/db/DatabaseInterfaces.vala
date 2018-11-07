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
    public abstract bool   enable_send_typing          { get; set; }
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

  public interface DhtNodeRepository : GLib.Object {
    public abstract void create(DhtNode node);
    public abstract void read(DhtNode node);
    public abstract void update(DhtNode node);
    public abstract void delete (DhtNode node);
    public abstract Gee.Iterable<DhtNode> query_all();
  }

  public interface MessageRepository : GLib.Object {
    public abstract void create(Message message);
    public abstract void update(Message message);
    public abstract Gee.Iterable<Message> query_all_for_contact(IContact contact);
  }

  public interface FriendRequestRepository : GLib.Object {
    public abstract void create(FriendRequest friend_request);
    public abstract void delete (FriendRequest friend_request);
    public abstract Gee.Iterable<FriendRequest> query_all();
  }

  public interface ContactRepository : GLib.Object {
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

  public interface NospamRepository : GLib.Object {
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

  public interface Database : GLib.Object {
  }

  public interface DatabaseStatement : GLib.Object {
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
    public abstract DatabaseStatementBuilder builder();
  }

  public interface DatabaseStatementBuilder : GLib.Object {
    public abstract DatabaseStatementBuilder step() throws DatabaseStatementError;
    public abstract DatabaseStatementBuilder bind_text(string key, string val) throws DatabaseStatementError;
    public abstract DatabaseStatementBuilder bind_int64(string key, int64 val) throws DatabaseStatementError;
    public abstract DatabaseStatementBuilder bind_int(string key, int val) throws DatabaseStatementError;
    public abstract DatabaseStatementBuilder bind_bool(string key, bool val) throws DatabaseStatementError;
    public abstract DatabaseStatementBuilder reset();
  }

  public interface DatabaseFactory : GLib.Object {
    public abstract Database create_database(string path) throws DatabaseError;
    public abstract DatabaseStatementFactory create_statement_factory(Database database);

    public abstract DhtNodeRepository create_node_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError;
    public abstract ContactRepository create_contact_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError;
    public abstract MessageRepository create_message_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError;
    public abstract ISettingsDatabase create_settings_database(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError;
    public abstract FriendRequestRepository create_friend_request_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError;
    public abstract NospamRepository create_nospam_repository(DatabaseStatementFactory factory, Logger logger) throws DatabaseStatementError;
  }

  public interface DatabaseStatementFactory : GLib.Object {
    public abstract DatabaseStatement create_statement(string zSql) throws DatabaseStatementError;
  }
}
