import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/cyber_theme.dart';

class TimelineLegend extends StatelessWidget {
  const TimelineLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
         color: CyberTheme.surface,
         borderRadius: BorderRadius.circular(20),
         border: Border.all(color: Colors.white12),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           _LegendItem(color: CyberTheme.danger, label: "Critical"),
           const SizedBox(width: 12),
           _LegendItem(color: Colors.orange, label: "Medium"),
           const SizedBox(width: 12),
           _LegendItem(color: Colors.green, label: "Low"),
           const SizedBox(width: 12),
           Container(width: 2, height: 12, color: Colors.cyanAccent),
           const SizedBox(width: 4),
           Text("Today", style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
         Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
         const SizedBox(width: 4),
         Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
      ],
    );
  }
}
