/*
 *    TestToxCore.vala
 *
 *    Copyright (C) 2017 Venom authors and contributors
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

namespace TestToxCore {

  private static void testToxVersion() {
    assert(ToxCore.Version.major() == ToxCore.Version.MAJOR);
    assert(ToxCore.Version.minor() == ToxCore.Version.MINOR);
    assert(ToxCore.Version.patch() == ToxCore.Version.PATCH);
    assert(ToxCore.Version.is_compatible(ToxCore.Version.MAJOR, ToxCore.Version.MINOR, ToxCore.Version.PATCH));
  }

  private static void testToxOptions() {
    var e = ToxCore.ErrOptionsNew.OK;
    var options = new ToxCore.Options(ref e);
    var default_options = new ToxCore.Options(ref e);
    default_options.default ();
    assert(options != null);
    assert(default_options != null);

    assert(options.ipv6_enabled == default_options.ipv6_enabled);
    assert(options.udp_enabled == default_options.udp_enabled);
    assert(options.local_discovery_enabled == default_options.local_discovery_enabled);
    assert(options.proxy_type == default_options.proxy_type);
    assert(options.proxy_host == default_options.proxy_host);
    assert(options.start_port == default_options.start_port);
    assert(options.end_port == default_options.end_port);
    assert(options.tcp_port == default_options.tcp_port);
  }

  private static void testToxCoreSession() {
    var e = ToxCore.ErrOptionsNew.OK;
    var options = new ToxCore.Options(ref e);
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    assert(error == ToxCore.ErrNew.OK);
    tox = new ToxCore.Tox(options, ref error);
    assert(error == ToxCore.ErrNew.OK);
  }

  private static void testToxSaveData() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var savedata = tox.get_savedata();
    assert(savedata != null);
    assert(savedata.length > 0);
  }

  private static void testToxUserStatus() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var user_status = ToxCore.UserStatus.AWAY;
    tox.user_status = user_status;
    assert(tox.user_status == user_status);
  }

  private static void testToxPersistentUserStatus() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var user_status = ToxCore.UserStatus.BUSY;
    tox.user_status = user_status;
    tox = new ToxCore.Tox(null, ref error);
    assert(tox.user_status != user_status);
  }

  private static void testToxStatusMessage() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var message = "message";
    var setStatusError = ToxCore.ErrSetInfo.OK;
    assert(tox.self_set_status_message(message, ref setStatusError));
    assert(tox.self_get_status_message() == message);
  }

  private static void testToxName() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var name = "test";
    var setNameError = ToxCore.ErrSetInfo.OK;
    assert(tox.self_set_name(name, ref setNameError));
    assert(tox.self_get_name() == name);
  }

  private static void testToxConnection() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    assert(tox.self_get_connection_status() == ToxCore.Tox.Connection.NONE);
  }

  private static void testToxPersistentAddress() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var address = tox.self_get_address();
    assert(equals(tox.self_get_address(), address));
    tox = new ToxCore.Tox(null, ref error);
    assert(!equals(tox.self_get_address(), address));
  }

  private static void testToxBootstrapNull() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var bootstrapError = ToxCore.ErrBootstrap.OK;
    string s = null;
    assert(!tox.bootstrap(s, 0, {}, ref bootstrapError));
    assert(bootstrapError == ToxCore.ErrBootstrap.NULL);
  }

  private static void testToxBootstrapBadPort() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var bootstrapError = ToxCore.ErrBootstrap.OK;
    var pubkey = new uint8[ToxCore.public_key_size()];
    assert(!tox.bootstrap("", 0, pubkey, ref bootstrapError));
    assert(bootstrapError == ToxCore.ErrBootstrap.BAD_PORT);
  }

  private static void testToxBootstrapBadHost() {
    var error = ToxCore.ErrNew.OK;
    var tox = new ToxCore.Tox(null, ref error);
    var bootstrapError = ToxCore.ErrBootstrap.OK;
    var pubkey = new uint8[ToxCore.public_key_size()];
    assert(!tox.bootstrap("", 1, pubkey, ref bootstrapError));
    assert(bootstrapError == ToxCore.ErrBootstrap.BAD_HOST);
  }

  private static bool equals(uint8[] a, uint8[] b) {
    return (a != null && b != null && a.length == b.length && Memory.cmp(a, b, a.length) == 0);
  }

  private static void main(string[] args) {
    Test.init(ref args);
    Test.add_func("/test_tox_version", testToxVersion);
    Test.add_func("/test_tox_options", testToxOptions);
    Test.add_func("/test_tox_core_session", testToxCoreSession);
    Test.add_func("/test_tox_save_data", testToxSaveData);
    Test.add_func("/test_tox_persistent_user_status", testToxPersistentUserStatus);
    Test.add_func("/test_tox_user_status", testToxUserStatus);
    Test.add_func("/test_tox_status_message", testToxStatusMessage);
    Test.add_func("/test_tox_name", testToxName);
    Test.add_func("/test_tox_connection", testToxConnection);
    Test.add_func("/test_tox_persistent_address", testToxPersistentAddress);
    Test.add_func("/test_tox_bootstrap_null", testToxBootstrapNull);
    Test.add_func("/test_tox_bootstrap_bad_port", testToxBootstrapBadPort);
    Test.add_func("/test_tox_bootstrap_bad_host", testToxBootstrapBadHost);
    Test.run();
  }
}
