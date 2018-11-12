/*
 *    Profile.vala
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

 errordomain ErrorEncryption {
     CREATE,
     ENCRYPT,
     DECRYPT
 }

namespace Venom {
  public class Profile : GLib.Object {
    public string name { get; set; }
    public string dir { get; set; }
    public string toxfile { get; set; }
    public string windowstatefile { get; set; }
    public string dbfile { get; set; }
    public string accelsfile { get; set; }
    public bool is_encrypted { get; set; }
    public ToxEncryptSave.PassKey? pass_key = null;

    public Profile(string path, string username) {
      name = username;
      dir = path;
      toxfile = Path.build_filename(dir, name + ".tox");
      windowstatefile = Path.build_filename(dir, name + ".json");
      dbfile = Path.build_filename(dir, name + ".db");
      accelsfile = Path.build_filename(dir, name + ".accels");
      is_encrypted = false;
    }

    public uint8[] ? load_sessiondata() throws Error {
      if (!FileUtils.test(toxfile, FileTest.EXISTS)) {
        return null;
      }

      uint8[] data;
      FileUtils.get_data(toxfile, out data);

      if (pass_key != null) {
        return decrypt(data);
      }
      return data;
    }

    public string get_db_key() {
      if (pass_key == null) {
        return "";
      }
      unowned uint8[] data = (uint8[]) pass_key;
      data.length = 64;
      return Tools.bin_to_hexstring(data[32:64]);
    }

    public void save_sessiondata(uint8[] sessiondata) throws Error {
      if (pass_key != null) {
        ToxEncryptSave.ErrEncryption err;
        var data = pass_key.encrypt(sessiondata, out err);
        if (err != ToxEncryptSave.ErrEncryption.OK) {
          throw new ErrorEncryption.ENCRYPT("Failed to encrypt data: " + err.to_string());
        }
        FileUtils.set_data(toxfile, data);
      } else {
        FileUtils.set_data(toxfile, sessiondata);
      }
    }

    public bool test_is_encrypted() {
      var file = File.new_for_path(toxfile);
      uint8[] contents;
      try {
        file.load_contents(null, out contents, null);
      } catch (Error e) {
        return false;
      }
      return ToxEncryptSave.is_data_encrypted(contents);
    }

    private uint8[] decrypt(uint8[] data) throws Error {
      ToxEncryptSave.ErrDecryption err_decrypt;
      var plain = pass_key.decrypt(data, out err_decrypt);
      if (err_decrypt != ToxEncryptSave.ErrDecryption.OK) {
        throw new ErrorEncryption.DECRYPT("Decryption failed: " + err_decrypt.to_string());
      }
      return plain;
    }

    public uint8[] load(string password) throws Error {
      var data = load_sessiondata();
      if (is_encrypted) {
        ToxEncryptSave.ErrGetSalt err_salt;
        var salt = ToxEncryptSave.get_salt(data, out err_salt);
        if (err_salt != ToxEncryptSave.ErrGetSalt.OK) {
          throw new ErrorEncryption.DECRYPT("Retrieving salt failed: " + err_salt.to_string());
        }

        ToxEncryptSave.ErrKeyDerivation err_deriv;
        pass_key = new ToxEncryptSave.PassKey.derive_with_salt(password.data, salt, out err_deriv);
        if (err_deriv != ToxEncryptSave.ErrKeyDerivation.OK || pass_key == null) {
          throw new ErrorEncryption.DECRYPT("PassKey derivation failed: " + err_deriv.to_string());
        }

        try {
          return decrypt(data);
        } catch (Error e) {
          pass_key = null;
          throw e;
        }
      }
      return data;
    }

    public bool is_sane() {
      var baseprof = GLib.Path.build_filename(dir, name);
      return exists(baseprof + ".tox") && exists(baseprof + ".db");
    }

    public static Profile create(string path, string username, string password) throws Error {
      var profile = new Profile(path, username);

      if (password.length > 0) {
        ToxEncryptSave.ErrKeyDerivation err;
        profile.pass_key = new ToxEncryptSave.PassKey.derive(password.data, out err);
        if (err != ToxEncryptSave.ErrKeyDerivation.OK) {
          throw new ErrorEncryption.CREATE("PassKey derivation failed: " + err.to_string());
        }
        profile.is_encrypted = true;
      }

      return profile;
    }

    public static bool is_username_available(string path, string username) {
      var baseprof = GLib.Path.build_filename(path, username);
      return (!exists(baseprof + ".tox") && !exists(baseprof + ".db")
          && !exists(baseprof + ".json") && !exists(baseprof + ".accels"));
    }

    private static bool exists(string path) {
      return GLib.FileUtils.test(path, GLib.FileTest.EXISTS);
    }

    public static Gee.Iterable<Profile> scan_profiles(Logger logger, string directory) {
      var profiles = new Gee.LinkedList<Profile>();
      try {
        var dir = Dir.open(directory, 0);
        string? name = null;

        while ((name = dir.read_name()) != null) {
          var path = Path.build_filename(directory, name);
          if (name.has_suffix(".tox") && FileUtils.test(path, FileTest.IS_REGULAR)) {
            var profile = new Profile(directory, name.substring(0, name.last_index_of(".tox")));
            profile.is_encrypted = profile.test_is_encrypted();
            profiles.add(profile);
          }
        }
      } catch (FileError e) {
        logger.w("When scanning profiles: " + e.message);
      }
      return profiles;
    }
  }
}
