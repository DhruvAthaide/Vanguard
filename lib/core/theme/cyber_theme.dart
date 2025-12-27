import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  static const Color background = Color(0xFF0B0F14);
  static const Color surface = Color(0xFF111827);
  static const Color glass = Color(0xAA111827);
  static const Color accent = Color(0xFF38BDF8);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,

      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: accent,
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
        ),
      ),

      useMaterial3: true,
    );
  }
}
