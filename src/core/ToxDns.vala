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
    public delegate string? pin_request_delegate(string? tox_dns_id = null);
    public string default_host { get; set; default = "";}
    public string? authority_user {get; private set; default = null;}

    private static GLib.Regex _tox_dns_record_regex;
    public static GLib.Regex tox_dns_record_regex {
      get {
        if(_tox_dns_record_regex == null) {
          try {
            _tox_dns_record_regex = new GLib.Regex("^v=(?P<v>[^\\W;]+);(id=(?P<id>[^\\W;]+)|pub=(?P<pub>[^\\W;]+);check=(?P<check>[^\\W;]+))");
          } catch (GLib.Error e) {
            Logger.log(LogLevel.FATAL, "Error creating tox dns regex: " + e.message);
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
          //TODO support message pin and xname (ignored for now)
            _tox_uri_regex = new GLib.Regex("^((?P<scheme>tox):/*)?((?P<tox_id>[[:xdigit:]]{%i})|(?P<authority_user>[[:digit:][:alpha:]]+)(@(?P<authority_host>[[:digit:][:alpha:]]+(\\.[[:digit:][:alpha:]]+)+))?)".printf(Tox.FRIEND_ADDRESS_SIZE * 2));
          } catch (GLib.Error e) {
            Logger.log(LogLevel.FATAL, "Error creating tox uri regex: " + e.message);
          }
        }
        return _tox_uri_regex;
      }
    }

    public string? resolve_id(string tox_uri, pin_request_delegate pin_request) {
      string hostname = null, tox_dns_id = null;
      authority_user = null;

      GLib.MatchInfo info = null;
      if(tox_uri_regex == null || !tox_uri_regex.match(tox_uri, 0, out info)) {
        Logger.log(LogLevel.ERROR, "Invalid tox uri");
        return null;
      }

      authority_user = info.fetch_named("authority_user");
      if(authority_user == null) {
        // must be tox://<tox_id> in this case
        return info.fetch_named("tox_id");
      }

      string authority_host = info.fetch_named("authority_host") ?? default_host;
      hostname = authority_user + "._tox." + authority_host;
      tox_dns_id = authority_user + "@" + authority_host;
      string record = null;
      try {
        record = lookup_dns_record(hostname);
      } catch (GLib.Error e) {
        Logger.log(LogLevel.ERROR, "Error resolving name: " + e.message);
        return null;
      }

      return get_id_from_dns_record(tox_dns_id, record, pin_request);
    }

    private string? get_id_from_dns_record(string tox_dns_id, string dns_record, pin_request_delegate pin_request) {
      GLib.MatchInfo info = null;
      if(tox_dns_record_regex != null && tox_dns_record_regex.match(dns_record, 0, out info)) {
        string v = info.fetch_named("v");
        switch(v) {
          case "tox1":
            string id = info.fetch_named("id");
            Logger.log(LogLevel.INFO, "tox 1 ID found: " + id);
            return id;
          case "tox2":
            string pub = info.fetch_named("pub");
            string check = info.fetch_named("check");
            Logger.log(LogLevel.INFO, "tox 2 ID found: " + pub + " " + check);
            string pin = pin_request(tox_dns_id);
            if(pin == null || pin == "") {
              Logger.log(LogLevel.INFO, "No pin privided, aborting...");
              return null;
            }
            string decoded = pub + Venom.Tools.bin_to_hexstring(Base64.decode(pin + "==")) + check;
            Logger.log(LogLevel.INFO, "decoded: " + decoded);
            return decoded;
          default:
            assert_not_reached();
        }
      } else {
        Logger.log(LogLevel.INFO, "Invalid record");
      }
      return null;
    }

    private string? lookup_dns_record(string hostname) throws GLib.Error {
#if ENABLE_DJBDNS
      DJBDns.AllocatedString answer = DJBDns.AllocatedString();
      DJBDns.AllocatedString fqdn = {hostname, hostname.length, 0};
      int ret = DJBDns.dns_txt(out answer, fqdn);
      if(ret == 0) {
        return answer.s[0:answer.len];
      }
#else
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
#endif
      return null;
    }
  }
}
