import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';

class PinSetupDialog extends StatefulWidget {
  const PinSetupDialog({super.key});

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isConfirmStep = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_isConfirmStep) {
      // First step: validate PIN
      if (_pinController.text.length < 4 || _pinController.text.length > 6) {
        setState(() => _errorMessage = 'PIN must be 4-6 digits');
        return;
      }
      setState(() {
        _isConfirmStep = true;
        _errorMessage = null;
      });
    } else {
      // Confirmation step
      if (_pinController.text != _confirmController.text) {
        setState(() => _errorMessage = 'PINs do not match');
        return;
      }
      Navigator.pop(context, _pinController.text);
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CyberTheme.danger.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.lock,
              color: CyberTheme.danger,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _isConfirmStep ? 'CONFIRM PIN' : 'SET UP PIN',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberTheme.danger,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirmStep
                  ? 'Re-enter your PIN to confirm'
                  : 'Create a 4-6 digit PIN',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _isConfirmStep ? _confirmController : _pinController,
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
                if (_isConfirmStep)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isConfirmStep = false;
                          _confirmController.clear();
                          _errorMessage = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('BACK', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_isConfirmStep) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberTheme.danger,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _isConfirmStep ? 'CONFIRM' : 'NEXT',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
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
