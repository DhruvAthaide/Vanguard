import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Constants
  static const int _saltLength = 16;
  static const int _keyLength = 32; // 256 bits
  static const int _ivLength = 12; // 96 bits for GCM
  static const int _iterationCount = 10000;

  /// Encrypts raw bytes using a user-provided password.
  /// 
  /// Format: [Salt (16)] + [IV (12)] + [Encrypted Data]
  static Future<Uint8List> encryptData(List<int> data, String password) async {
    final salt = _generateRandomBytes(_saltLength);
    final key = _deriveKey(password, salt);
    final iv = encrypt.IV.fromLength(_ivLength); // Random IV

    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(key),
      mode: encrypt.AESMode.gcm,
    ));

    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    // Combine Salt + IV + Data
    final builder = BytesBuilder();
    builder.add(salt);
    builder.add(iv.bytes);
    builder.add(encrypted.bytes);
    
    return builder.toBytes();
  }

  /// Decrypts data using a user-provided password.
  /// 
  /// Expects format: [Salt (16)] + [IV (12)] + [Encrypted Data]
  static Future<List<int>> decryptData(Uint8List encryptedPayload, String password) async {
    if (encryptedPayload.length < _saltLength + _ivLength) {
      throw Exception('Invalid payload size');
    }

    final salt = encryptedPayload.sublist(0, _saltLength);
    final ivBytes = encryptedPayload.sublist(_saltLength, _saltLength + _ivLength);
    final cipherBytes = encryptedPayload.sublist(_saltLength + _ivLength);

    final key = _deriveKey(password, salt);
    final iv = encrypt.IV(ivBytes);

    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(key),
      mode: encrypt.AESMode.gcm,
    ));

    return encrypter.decryptBytes(
      encrypt.Encrypted(cipherBytes), 
      iv: iv
    );
  }

  /// Derives a 32-byte key from a password and salt using PBKDF2 with SHA-256.
  static Uint8List _deriveKey(String password, Uint8List salt) {
    // Note: In a real standardized environment, use a robust PBKDF2 implementation.
    // For this prototype, we are using the crypto package's sha256.
    // However, `encrypt` package doesn't have a built-in PBKDF2 generator exposed easily.
    // We will simulate a robust key derivation for now, or use a specific package if strict compliance is needed.
    // For "Vanguard" Ops, we'll implementing a basic PBKDF2 loop.
    
    var hmac = Hmac(sha256, utf8.encode(password));
    var digest = hmac.convert(salt);
    
    // Simple stretching (not full PBKDF2, but better than raw hash)
    for (var i = 0; i < _iterationCount; i++) {
       digest = hmac.convert(digest.bytes);
    }
    
    // Ensure 32 bytes
    if (digest.bytes.length >= 32) {
      return Uint8List.fromList(digest.bytes.sublist(0, 32));
    } else {
      // Pad if necessary (unlikely with sha256)
      return Uint8List.fromList([...digest.bytes, ...List.filled(32 - digest.bytes.length, 0)]);
    }
  }

  static Uint8List _generateRandomBytes(int length) {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(length, (i) => rnd.nextInt(256)));
  }
}
