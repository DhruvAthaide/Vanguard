import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanguard/core/theme/cyber_theme.dart';
import 'package:vanguard/features/deaddrop/services/qr_data_service.dart';

class DeadDropScannerScreen extends StatefulWidget {
  const DeadDropScannerScreen({super.key});

  @override
  State<DeadDropScannerScreen> createState() => _DeadDropScannerScreenState();
}

class _DeadDropScannerScreenState extends State<DeadDropScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawData = barcodes.first.rawValue;
    if (rawData == null) return;

    setState(() => _isProcessing = true);
    
    // We pause to prevent multiple detections while processing
    // Note: mobile_scanner 5.x controller.stop() might be needed or just ignore events
    await _controller.stop(); 

    if (mounted) {
      _processPayload(rawData);
    }
  }

  Future<void> _processPayload(String rawData) async {
    // 1. Try to decode without password first (in case it's not encrypted or just compressed)
    try {
      // If it looks like base64, try our service
      // If it's plain text, QrDataService might fail or return garbage, but let's try
      
      // Prompt for password immediately if we assume it's encrypted? 
      // Or try to decompress. QrDataService.decodeData tries to decrypt if we pass a key.
      
      // Let's ask user for password if they know it's encrypted, 
      // OR we can try with empty password (null)
      
      // For UX: Show a dialog with "Decrypt" option
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _PayloadActionDialog(
          rawData: rawData,
          onReset: () {
             Navigator.pop(ctx);
             _resetScanner();
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: CyberTheme.danger),
        );
        _resetScanner();
      }
    }
  }

  void _resetScanner() {
    setState(() => _isProcessing = false);
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: CyberTheme.accent,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Align QR Code within frame",
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero)
      ..addRect(_getCutOutRect(rect));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  Rect _getCutOutRect(Rect rect) {
    return Rect.fromCenter(
      center: rect.center,
      width: cutOutSize,
      height: cutOutSize,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final _cutOutRect = _getCutOutRect(rect);

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRect(_cutOutRect, backgroundPaint..blendMode = BlendMode.dstOut)
      ..restore();

    canvas.drawPath(
      Path()
        ..moveTo(_cutOutRect.left, _cutOutRect.top + borderLength)
        ..lineTo(_cutOutRect.left, _cutOutRect.top + borderRadius)
        ..quadraticBezierTo(_cutOutRect.left, _cutOutRect.top, _cutOutRect.left + borderRadius, _cutOutRect.top)
        ..lineTo(_cutOutRect.left + borderLength, _cutOutRect.top)
        ..moveTo(_cutOutRect.right - borderLength, _cutOutRect.top)
        ..lineTo(_cutOutRect.right - borderRadius, _cutOutRect.top)
        ..quadraticBezierTo(_cutOutRect.right, _cutOutRect.top, _cutOutRect.right, _cutOutRect.top + borderRadius)
        ..lineTo(_cutOutRect.right, _cutOutRect.top + borderLength)
        ..moveTo(_cutOutRect.right, _cutOutRect.bottom - borderLength)
        ..lineTo(_cutOutRect.right, _cutOutRect.bottom - borderRadius)
        ..quadraticBezierTo(_cutOutRect.right, _cutOutRect.bottom, _cutOutRect.right - borderRadius, _cutOutRect.bottom)
        ..lineTo(_cutOutRect.right - borderLength, _cutOutRect.bottom)
        ..moveTo(_cutOutRect.left + borderLength, _cutOutRect.bottom)
        ..lineTo(_cutOutRect.left + borderRadius, _cutOutRect.bottom)
        ..quadraticBezierTo(_cutOutRect.left, _cutOutRect.bottom, _cutOutRect.left, _cutOutRect.bottom - borderRadius)
        ..lineTo(_cutOutRect.left, _cutOutRect.bottom - borderLength),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}

class _PayloadActionDialog extends StatefulWidget {
  final String rawData;
  final VoidCallback onReset;

  const _PayloadActionDialog({required this.rawData, required this.onReset});

  @override
  State<_PayloadActionDialog> createState() => _PayloadActionDialogState();
}

class _PayloadActionDialogState extends State<_PayloadActionDialog> {
  final _passwordCtrl = TextEditingController();
  String? _decryptedData;
  bool _error = false;
  bool _isDecrypting = false;

  void _tryDecrypt() async {
    setState(() { _isDecrypting = true; _error = false; });
    try {
      // Decode
      final data = await QrDataService.decodeData(
        widget.rawData,
        _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
      );
      setState(() => _decryptedData = data);
    } catch (e) {
      setState(() => _error = true);
    } finally {
      setState(() => _isDecrypting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If decrypted successfully, show content
    if (_decryptedData != null) {
      return AlertDialog(
        backgroundColor: CyberTheme.surface,
        title: const Text("Decrypted Intel", style: TextStyle(color: Colors.white)),
         content: SingleChildScrollView(
           child: Text(
             _decryptedData!, 
             style: GoogleFonts.inter(color: Colors.white70),
           ),
         ),
         actions: [
           TextButton(
             onPressed: () {
               Clipboard.setData(ClipboardData(text: _decryptedData!));
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
             },
             child: const Text("COPY"),
           ),
           TextButton(
             onPressed: widget.onReset,
             child: const Text("CLOSE"),
           ),
         ],
      );
    }

    // Otherwise show password prompt
    return AlertDialog(
      backgroundColor: CyberTheme.surface,
      title: const Text("Incoming Dead Drop", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Enter decryption key if required:", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.black26,
              hintText: "Password (Optional)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              errorText: _error ? "Decryption failed. Wrong key?" : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Raw Size: ${widget.rawData.length} chars",
            style: const TextStyle(fontSize: 10, color: Colors.white30),
          ),
        ],
      ),
      actions: [
        TextButton(
           onPressed: widget.onReset,
           child: const Text("CANCEL"),
        ),
        ElevatedButton(
          onPressed: _isDecrypting ? null : _tryDecrypt,
          style: ElevatedButton.styleFrom(backgroundColor: CyberTheme.accent),
          child: _isDecrypting 
             ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
             : const Text("DECRYPT", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
