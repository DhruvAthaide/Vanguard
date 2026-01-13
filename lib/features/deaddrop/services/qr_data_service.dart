import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../../../core/security/encryption_service.dart';

class QrDataService {
  /// Compresses and Encrypts data for QR transmission.
  /// If [password] is provided, data is encrypted.
  /// Data is always GZIP compressed to save space.
  static Future<String> prepareData(String data, String? password) async {
    List<int> bytes = utf8.encode(data);
    
    // 1. Compress
    final gzipper = GZipEncoder();
    List<int> compressed = gzipper.encode(bytes) ?? [];
    
    // 2. Encrypt (Optional)
    if (password != null && password.isNotEmpty) {
      compressed = await EncryptionService.encryptData(compressed, password);
    }
    
    // 3. Base64 Encode for Alphanumeric QR Mode
    return base64Encode(compressed);
  }

  /// Reverses [prepareData].
  static Future<String> decodeData(String base64Data, String? password) async {
    try {
      // 1. Base64 Decode
      List<int> bytes = base64Decode(base64Data);
      
      // 2. Decrypt (If needed)
      // Note: If data is encrypted, the user must provide the password.
      // If we try to GZip decode encrypted data it will fail, so we assume flow control handles this.
      if (password != null && password.isNotEmpty) {
        bytes = await EncryptionService.decryptData(Uint8List.fromList(bytes), password);
      }
      
      // 3. Decompress
      final unzipper = GZipDecoder();
      final decompressed = unzipper.decodeBytes(bytes);
      
      return utf8.decode(decompressed);
    } catch (e) {
      throw Exception('Failed to decode payload. Wrong password or corrupted data.');
    }
  }
}
