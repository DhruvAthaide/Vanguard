import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';

class PinEntryDialog extends StatefulWidget {
  const PinEntryDialog({super.key});

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_pinController.text.length < 4) {
      setState(() => _errorMessage = 'PIN must be at least 4 digits');
      return;
    }
    Navigator.pop(context, _pinController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CyberTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CyberTheme.danger.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.shieldCheck,
              color: CyberTheme.danger,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'ENTER PIN',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberTheme.danger,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your PIN to unlock the vault',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _pinController,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoMono(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 16,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _handleSubmit(),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                hintStyle: GoogleFonts.robotoMono(
                  fontSize: 32,
                  color: Colors.white24,
                  letterSpacing: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CyberTheme.danger.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CyberTheme.danger.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CyberTheme.danger),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(
                  color: CyberTheme.danger,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('CANCEL', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberTheme.danger,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('UNLOCK', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
