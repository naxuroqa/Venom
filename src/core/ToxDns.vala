/*
 *    ToxDns.vala
 *
 *    Copyright (C) 2013-2014  Venom authors and contributors
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

//TODO make asynchronous
namespace Venom {
  public class ToxDns : GLib.Object{
    public delegate string? pin_request_delegate();

    private static GLib.Regex _tox_dns_record_regex;
    public static GLib.Regex tox_dns_record_regex {
      get {
        if(_tox_dns_record_regex == null) {
          try {
            _tox_dns_record_regex = new GLib.Regex("^v=(?P<v>[^\\W;]+);(id=(?P<id>[^\\W;])|pub=(?P<pub>[^\\W;]+);check=(?P<check>[^\\W;]+))");
          } catch (GLib.Error e) {
            stderr.printf("Error creating tox dns regex: %s\n", e.message);
          }
        }
        return _tox_dns_record_regex;
      }
    }

    private static GLib.Regex _tox_uri_regex;
    public static GLib.Regex tox_uri_regex {
      get {
        if(_tox_uri_regex == null) {
          try {
            _tox_uri_regex = new GLib.Regex("^(tox://)?(?P<uri>.+@.+\\.[^\\W?#]+)");
          } catch (GLib.Error e) {
            stderr.printf("Error creating tox uri regex: %s\n", e.message);
          }
        }
        return _tox_uri_regex;
      }
    }

    public string? resolve_id(string tox_uri, pin_request_delegate pin_request) {
      string hostname = hostname_from_tox_uri(tox_uri);
      if(hostname == null) {
        return null;
      }
      string record = null;
      try {
        record = lookup_dns_record(hostname);
      } catch (GLib.Error e) {
        stderr.printf("Error resolving name: %s\n", e.message);
        return null;
      }

      return get_id_from_dns_record(record, pin_request);
    }

    public static string? hostname_from_tox_uri(string tox_uri) {
      GLib.MatchInfo info = null;
      if(tox_uri_regex != null && tox_uri_regex.match(tox_uri, 0, out info)) {
        return info.fetch_named("uri").replace("@", "._tox.");
      } else {
        stderr.printf("Invalid tox uri\n");
      }
      return null;
    }

    private string? get_id_from_dns_record(string dns_record, pin_request_delegate pin_request) {
      GLib.MatchInfo info = null;
      if(tox_dns_record_regex != null && tox_dns_record_regex.match(dns_record, 0, out info)) {
        string v = info.fetch_named("v");
        switch(v) {
          case "tox1":
            string id = info.fetch_named("id");
            stdout.printf("tox 1 ID found: %s\n", id);
            return id;
          case "tox2":
            string pub = info.fetch_named("pub");
            string check = info.fetch_named("check");
            stdout.printf("tox 2 ID found: %s %s\n", pub, check);
            string pin = pin_request();
            if(pin == null || pin == "") {
              stderr.printf("No pin privided, aborting...\n");
              return null;
            }
            string decoded = pub + Venom.Tools.bin_to_hexstring(Base64.decode(pin + "==")) + check;
            stdout.printf("decoded: %s\n", decoded);
            return decoded;
          default:
            assert_not_reached();
        }
      } else {
        stderr.printf("Invalid record\n");
      }
      return null;
    }

    private string? lookup_dns_record(string hostname) throws GLib.Error {
      GLib.Resolver resolver = GLib.Resolver.get_default();
      GLib.List<GLib.Variant> records = resolver.lookup_records(hostname, GLib.ResolverRecordType.TXT);
      if( records.length() > 0 ) {
        VariantIter it;
        string s;
        records.data.get("(as)", out it);
        if(it.next("s", out s)) {
          return s;
        }
      }
      return null;
    }
  }
}
