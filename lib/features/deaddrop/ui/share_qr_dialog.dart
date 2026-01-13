import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:vanguard/core/theme/cyber_theme.dart';
import '../services/qr_data_service.dart';

class ShareQrDialog extends StatefulWidget {
  final String dataToShare;
  final String title;

  const ShareQrDialog({
    super.key,
    required this.dataToShare,
    required this.title,
  });

  @override
  State<ShareQrDialog> createState() => _ShareQrDialogState();
}

class _ShareQrDialogState extends State<ShareQrDialog> {
  final _passwordController = TextEditingController();
  String? _generatedPayload;
  bool _isGenerating = false;
  bool _showQr = false;

  Future<void> _generate() async {
    setState(() => _isGenerating = true);
    try {
      final payload = await QrDataService.prepareData(
        widget.dataToShare,
        _passwordController.text.isEmpty ? null : _passwordController.text,
      );
      
      if (mounted) {
        setState(() {
          _generatedPayload = payload;
          _showQr = true;
          _isGenerating = false;
        });
      }
    } catch (e) {
       // handle error
       setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CyberTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CyberTheme.accent.withOpacity(0.3)),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dead Drop: QR share', style: CyberTheme.headingMedium),
            const SizedBox(height: 8),
            Text(widget.title, style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            
            if (!_showQr) ...[
               TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Encryption Key (Optional)',
                  prefixIcon: const Icon(LucideIcons.lock, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.black26,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generate,
                icon: _isGenerating 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(LucideIcons.qrCode),
                label: const Text('GENERATE CODE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CyberTheme.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: _generatedPayload!,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan using Vanguard Scanner\nLength: ${_generatedPayload!.length} chars',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 16),
               SizedBox(
                 width: double.infinity,
                 child: OutlinedButton(
                   onPressed: () {
                     Clipboard.setData(ClipboardData(text: _generatedPayload!));
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied payload")));
                   },
                   child: const Text('COPY PAYLOAD STRING'),
                 ),
               ),
              const SizedBox(height: 8),
              SizedBox(
                 width: double.infinity,
                 child: TextButton(
                  onPressed: () => setState(() => _showQr = false),
                  child: const Text('Generate New'),
                 ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
