import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';

class PinChangeDialog extends StatefulWidget {
  const PinChangeDialog({super.key});

  @override
  State<PinChangeDialog> createState() => _PinChangeDialogState();
}

class _PinChangeDialogState extends State<PinChangeDialog> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  int _step = 0; // 0: old PIN, 1: new PIN, 2: confirm
  String? _errorMessage;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_step == 0) {
      // Verify old PIN
      if (_oldPinController.text.length < 4) {
        setState(() => _errorMessage = 'PIN must be at least 4 digits');
        return;
      }
      setState(() {
        _step = 1;
        _errorMessage = null;
      });
    } else if (_step == 1) {
      // Validate new PIN
      if (_newPinController.text.length < 4 || _newPinController.text.length > 6) {
        setState(() => _errorMessage = 'PIN must be 4-6 digits');
        return;
      }
      setState(() {
        _step = 2;
        _errorMessage = null;
      });
    } else {
      // Confirm new PIN
      if (_newPinController.text != _confirmPinController.text) {
        setState(() => _errorMessage = 'PINs do not match');
        return;
      }
      Navigator.pop(context, {
        'oldPin': _oldPinController.text,
        'newPin': _newPinController.text,
      });
    }
  }

  void _handleBack() {
    setState(() {
      _step--;
      _errorMessage = null;
    });
  }

  String get _title {
    switch (_step) {
      case 0:
        return 'ENTER CURRENT PIN';
      case 1:
        return 'ENTER NEW PIN';
      case 2:
        return 'CONFIRM NEW PIN';
      default:
        return '';
    }
  }

  String get _subtitle {
    switch (_step) {
      case 0:
        return 'Verify your current PIN';
      case 1:
        return 'Create a new 4-6 digit PIN';
      case 2:
        return 'Re-enter your new PIN';
      default:
        return '';
    }
  }

  TextEditingController get _currentController {
    switch (_step) {
      case 0:
        return _oldPinController;
      case 1:
        return _newPinController;
      case 2:
        return _confirmPinController;
      default:
        return _oldPinController;
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
              LucideIcons.keyRound,
              color: CyberTheme.danger,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CyberTheme.danger,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _currentController,
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
              onSubmitted: (_) => _handleNext(),
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
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleBack,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('BACK', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberTheme.danger,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _step == 2 ? 'CHANGE PIN' : 'NEXT',
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
