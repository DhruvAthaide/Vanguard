import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF111827);
  static const Color glass = Color(0xCC111827); // Slightly more opaque for better readability
  static const Color accent = Color(0xFF38BDF8);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  
  static TextStyle get headingMedium => GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);
  static TextStyle get headingSmall => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

  /// Standard Glassmorphic Decoration
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: glass,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.08),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ],
  );

  /// Active/Selected State Decoration (Glowing Border)
  static BoxDecoration get activeDecoration => BoxDecoration(
    color: glass,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: accent.withOpacity(0.5),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.15),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,

      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: accent,
        secondary: accent,
        error: danger,
      ),

      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),

      cardTheme: CardThemeData(
        color: glass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),

      useMaterial3: true,
    );
  }
}
