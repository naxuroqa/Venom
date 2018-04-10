[CCode(cheader_filename = "tox/toxencryptsave.h", cprefix = "Tox", lower_case_cprefix = "tox_")]
namespace ToxEncryptSave {
  /**
   * The size of the salt part of a pass-key.
   */
  public uint32 pass_salt_length();

  /**
   * The size of the salt part of a pass-key.
   */
  public const uint32 PASS_SALT_LENGTH;

  /**
   * The size of the key part of a pass-key.
   */
  public const uint32 PASS_KEY_LENGTH;

  /**
   * The size of the key part of a pass-key.
   */
  public uint32 pass_key_length();

  /**
   * The amount of additional data required to store any encrypted byte array.
   * Encrypting an array of N bytes requires N + {@link pass_encryption_extra_length}
   * bytes in the encrypted byte array.
   */
  public const uint32 PASS_ENCRYPTION_EXTRA_LENGTH;

  /**
   * The amount of additional data required to store any encrypted byte array.
   * Encrypting an array of N bytes requires N + {@link pass_encryption_extra_length}
   * bytes in the encrypted byte array.
   */
  public uint32 pass_encryption_extra_length();

  [CCode(cname = "TOX_ERR_KEY_DERIVATION", cprefix = "TOX_ERR_KEY_DERIVATION_")]
  public enum ErrKeyDerivation {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The crypto lib was unable to derive a key from the given passphrase,
     * which is usually a lack of memory issue.
     */
    FAILED
  }

  [CCode(cname = "TOX_ERR_ENCRYPTION", cprefix = "TOX_ERR_ENCRYPTION_")]
  public enum ErrEncryption {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The crypto lib was unable to derive a key from the given passphrase,
     * which is usually a lack of memory issue. The functions accepting keys
     * do not produce this error.
     */
    KEY_DERIVATION_FAILED,
    /**
     * The encryption itself failed.
     */
    FAILED
  }

  [CCode(cname = "TOX_ERR_DECRYPTION", cprefix = "TOX_ERR_DECRYPTION_")]
  public enum ErrDecryption {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The input data was shorter than {@link pass_encryption_extra_length} bytes
     */
    INVALID_LENGTH,
    /**
     * The input data is missing the magic number (i.e. wasn't created by this
     * module, or is corrupted).
     */
    BAD_FORMAT,
    /**
     * The crypto lib was unable to derive a key from the given passphrase,
     * which is usually a lack of memory issue. The functions accepting keys
     * do not produce this error.
     */
    KEY_DERIVATION_FAILED,
    /**
     * The encrypted byte array could not be decrypted. Either the data was
     * corrupted or the password/key was incorrect.
     */
    FAILED
  }

  [CCode(cname = "tox_pass_encrypt")]
  private static bool _pass_encrypt ([CCode(array_length_type = "size_t")] uint8[] plaintext,
                                     [CCode(array_length_type = "size_t")] uint8[] ? passphrase,
                                     [CCode(array_length = false)] uint8[] ciphertext,
                                     out ErrEncryption error);

  /**
   * Encrypts the given data with the given passphrase.
   *
   * The output array must be at least ``plaintext_len + {@link pass_encryption_extra_length}``
   * bytes long. This delegates to {@link PassKey.PassKey.derive} and
   * {@link PassKey.encrypt}.
   *
   * @param plaintext A byte array of length ``plaintext.length``.
   * @param passphrase The user-provided password. Can be empty.
   *
   * @return ciphertext on success.
   */
  [CCode(cname = "vala_tox_pass_encrypt")]
  public static uint8[] ? pass_encrypt(uint8[] plaintext, uint8[] ? passphrase, out ErrEncryption error) {
    var t = new uint8[plaintext.length + PASS_ENCRYPTION_EXTRA_LENGTH];
    var ret = _pass_encrypt(plaintext, passphrase, t, out error);
    return ret ? t : null;
  }

  [CCode(cname = "tox_pass_decrypt")]
  private static bool _pass_decrypt ([CCode(array_length_type = "size_t")] uint8[] ciphertext,
                                     [CCode(array_length_type = "size_t")] uint8[] ? passphrase,
                                     [CCode(array_length = false)] uint8[] plaintext,
                                     out ErrDecryption error);

  /**
   * Decrypts the given data with the given passphrase.
   *
   * The output array must be at least ``ciphertext.length - {@link pass_encryption_extra_length}``
   * bytes long. This delegates to {@link PassKey.decrypt}.
   *
   * @param ciphertext A byte array of length ``ciphertext.length``.
   * @param passphrase The user-provided password. Can be empty.
   *
   * @return plaintext on success.
   */
  [CCode(cname = "vala_tox_pass_decrypt")]
  public static uint8[] ? pass_decrypt(uint8[] ciphertext, uint8[] ? passphrase, out ErrDecryption error) {
    var t = new uint8[ciphertext.length + PASS_ENCRYPTION_EXTRA_LENGTH];
    var ret = _pass_decrypt(ciphertext, passphrase, t, out error);
    return ret ? t : null;
  }

  /**
   * This type represents a pass-key.
   *
   * A pass-key and a password are two different concepts: a password is given
   * by the user in plain text. A pass-key is the generated symmetric key used
   * for encryption and decryption. It is derived from a salt and the user-
   * provided password.
   */
  [CCode(cname = "Tox_Pass_Key", destroy_function = "tox_pass_key_free", cprefix = "tox_pass_key_", has_type_id = false)]
  [Compact]
  public class PassKey {
    /**
     * Generates a secret symmetric key from the given passphrase.
     *
     * Be sure to not compromise the key! Only keep it in memory, do not write
     * it to disk.
     *
     * Note that this function is not deterministic; to derive the same key from
     * a password, you also must know the random salt that was used. A
     * deterministic version of this function is {@link PassKey.PassKey.derive_with_salt}.
     *
     * @since 0.2.0
     *
     * @param passphrase The user-provided password. Can be empty.
     */
    [Version(since = "0.2.0")]
    [CCode(cname = "tox_pass_key_derive")]
    public PassKey.derive(uint8[] passphrase, out ErrKeyDerivation error);

    /**
     * Same as above, except use the given salt for deterministic key derivation.
     *
     * @param passphrase The user-provided password. Can be empty.
     * @param salt An array of at least {@link pass_salt_length} bytes.
     *
     * @since 0.2.0
     *
     * @return true on success.
     */
    [Version(since = "0.2.0")]
    [CCode(cname = "tox_pass_key_derive_with_salt")]
    public PassKey.derive_with_salt(uint8[] passphrase, [CCode(array_length = false)] uint8[] salt, out ErrKeyDerivation error);

    [CCode(cname = "tox_pass_key_encrypt")]
    private bool _encrypt(uint8[] plaintext, [CCode(array_length = false)] uint8[] ciphertext, out ErrEncryption error);

    /**
     * Encrypt a plain text with a key produced by {@link PassKey.PassKey.derive} or {@link PassKey.PassKey.derive_with_salt}.
     *
     * The output array must be at least ``plaintext.length + {@link pass_encryption_extra_length}``
     * bytes long.
     *
     * @param plaintext A byte array of length ``plaintext.length``.
     *
     * @return ciphertext on success.
     */
    [CCode(cname = "vala_tox_pass_key_encrypt")]
    public uint8[] ? encrypt(uint8[] plaintext, out ErrEncryption error) {
      var t = new uint8[plaintext.length + PASS_ENCRYPTION_EXTRA_LENGTH];
      var ret = _encrypt(plaintext, t, out error);
      return ret ? t : null;
    }

    [CCode(cname = "tox_pass_key_decrypt")]
    private bool _decrypt(uint8[] ciphertext, [CCode(array_length = false)] uint8[] plaintext, out ErrDecryption error);

    /**
     * This is the inverse of {@link PassKey.encrypt}, also using only keys produced by
     * {@link PassKey.PassKey.derive} or {@link PassKey.PassKey.derive_with_salt}.
     *
     * @param ciphertext A byte array of length ``ciphertext.length``.
     *
     * @return plaintext on success.
     */
    [CCode(cname = "vala_tox_pass_key_decrypt")]
    public uint8[] ? decrypt(uint8[] ciphertext, out ErrDecryption error) {
      var t = new uint8[ciphertext.length + PASS_ENCRYPTION_EXTRA_LENGTH];
      var ret = _decrypt(ciphertext, t, out error);
      return ret ? t : null;
    }
  }

  [CCode(cname = "TOX_ERR_GET_SALT", cprefix = "TOX_ERR_GET_SALT_")]
  public enum ErrGetSalt {
    /**
     * The function returned successfully.
     */
    OK,
    /**
     * One of the arguments to the function was NULL when it was not expected.
     */
    NULL,
    /**
     * The input data is missing the magic number (i.e. wasn't created by this
     * module, or is corrupted).
     */
    BAD_FORMAT,
  }

  [CCode(cname = "tox_get_salt")]
  private static bool _get_salt([CCode(array_length = false)] uint8[] ciphertext, [CCode(array_length = false)] uint8[] salt, out ErrGetSalt error);

  /**
   * Retrieves the salt used to encrypt the given data.
   *
   * The retrieved salt can then be passed to {@link PassKey.PassKey.derive_with_salt} to
   * produce the same key as was previously used. Any data encrypted with this
   * module can be used as input.
   *
   * The cipher text must be at least {@link pass_encryption_extra_length} bytes in length.
   * The salt must be {@link pass_salt_length} bytes in length.
   * If the passed byte arrays are smaller than required, the behaviour is
   * undefined.
   *
   * If the cipher text pointer or the salt is NULL, this function returns null.
   *
   * Success does not say anything about the validity of the data, only that
   * data of the appropriate size was copied.
   *
   * @return true on success.
   */
  [CCode(cname = "vala_tox_get_salt")]
  public static uint8[] ? get_salt(uint8[] ciphertext, out ErrGetSalt error) {
    var t = new uint8[PASS_SALT_LENGTH];
    var ret = _get_salt(ciphertext, t, out error);
    return ret ? t : null;
  }

  /**
   * Determines whether or not the given data is encrypted by this module.
   *
   * It does this check by verifying that the magic number is the one put in
   * place by the encryption functions.
   *
   * The data must be at least {@link pass_encryption_extra_length} bytes in length.
   * If the passed byte array is smaller than required, the behaviour is
   * undefined.
   *
   * If the data pointer is NULL, the behaviour is undefined
   *
   * @return true if the data is encrypted by this module.
   */
  public bool is_data_encrypted([CCode(array_length = false)] uint8[] data);
}
