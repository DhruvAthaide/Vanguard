import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import '../services/qr_data_service.dart'; // Reuse compression/encoding

class StegoService {
  static const String _magicHeader = "VGD\0"; // Identify our payloads

  /// Embeds [message] into [imageBytes] (must be a valid image).
  /// Returns PNG bytes (lossless, required for Stego).
  static Future<Uint8List?> embedData(Uint8List imageBytes, String message, String? password) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return null;

    // 1. Prepare Payload
    // Format: Magic + Length(4 bytes) + Data
    final payloadString = await QrDataService.prepareData(message, password);
    final payloadBytes = utf8.encode(payloadString);
    final lengthBytes = withByteData(payloadBytes.length);
    
    final fullPayload = [
      ...utf8.encode(_magicHeader),
      ...lengthBytes,
      ...payloadBytes
    ];

    // 2. Check Capacity
    final totalPixels = image.width * image.height;
    final maxBytes = (totalPixels * 3) ~/ 8; // 3 channels, 1 bit per channel
    if (fullPayload.length > maxBytes) {
      throw Exception("Message too large for this cover image. Need larger image or shorter message.");
    }

    // 3. Embed (LSB)
    int payloadIndex = 0;
    int bitIndex = 0;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (payloadIndex >= fullPayload.length) break;

        img.Pixel pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Embed in R
        if (payloadIndex < fullPayload.length) {
          r = _setBit(r, fullPayload[payloadIndex], bitIndex);
          bitIndex++;
          if (bitIndex == 8) { bitIndex = 0; payloadIndex++; }
        }
        
        // Embed in G
        if (payloadIndex < fullPayload.length) {
          g = _setBit(g, fullPayload[payloadIndex], bitIndex);
           bitIndex++;
          if (bitIndex == 8) { bitIndex = 0; payloadIndex++; }
        }
        
        // Embed in B
        if (payloadIndex < fullPayload.length) {
          b = _setBit(b, fullPayload[payloadIndex], bitIndex);
           bitIndex++;
          if (bitIndex == 8) { bitIndex = 0; payloadIndex++; }
        }

        image.setPixelRgb(x, y, r, g, b);
      }
      if (payloadIndex >= fullPayload.length) break;
    }

    // 4. Encode as PNG
    return Uint8List.fromList(img.encodePng(image));
  }

  static int _setBit(int channel, int byte, int bitIndex) {
    // Get the bit from the payload byte
    int bit = (byte >> (7 - bitIndex)) & 1;
    // Clear LSB of channel
    int cleared = channel & 0xFE;
    // Set LSB
    return cleared | bit;
  }

  static List<int> withByteData(int length) {
    final bd = ByteData(4);
    bd.setInt32(0, length);
    return bd.buffer.asUint8List();
  }
}
