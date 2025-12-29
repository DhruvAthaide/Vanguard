import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  final FlutterSecureStorage _storage;
  static const _pinKey = 'vault_pin_hash';

  PinService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.unlocked_this_device,
              ),
            );

  /// Hash PIN using SHA-256
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check if a PIN has been set up
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinKey);
    return hash != null;
  }

  /// Set up a new PIN (first time)
  Future<void> setupPin(String pin) async {
    if (pin.length < 4 || pin.length > 6) {
      throw ArgumentError('PIN must be 4-6 digits');
    }
    final hash = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hash);
  }

  /// Verify if the provided PIN matches the stored hash
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    
    final inputHash = _hashPin(pin);
    return inputHash == storedHash;
  }

  /// Change the PIN (requires old PIN verification)
  Future<bool> changePin(String oldPin, String newPin) async {
    final isOldPinValid = await verifyPin(oldPin);
    if (!isOldPinValid) return false;
    
    await setupPin(newPin);
    return true;
  }

  /// Clear the PIN (for testing or reset)
  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }
}
