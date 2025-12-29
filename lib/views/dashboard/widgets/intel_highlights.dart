import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../models/intel_item.dart';

class IntelHighlights extends StatelessWidget {
  final List<IntelItem> items;

  const IntelHighlights({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Threats",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _IntelCard(item: item)),
      ],
    );
  }
}

class _IntelCard extends StatelessWidget {
  final IntelItem item;

  const _IntelCard({required this.item});

  Color _getCategoryColor() {
    switch (item.category.toLowerCase()) {
      case 'exploits':
        return const Color(0xFFFF3B3B);
      case 'malware':
        return const Color(0xFFFF6B2C);
      case 'mobile security':
        return const Color(0xFF9D4EDD);
      case 'threat intel':
        return const Color(0xFF3B82F6);
      case 'leaks':
        return const Color(0xFFEF4444);
      default:
        return CyberTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CyberTheme.surface.withOpacity(0.65),
                  CyberTheme.surface.withOpacity(0.45),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getCategoryColor().withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor().withOpacity(0.3),
                        _getCategoryColor().withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.alertTriangle,
                    color: _getCategoryColor(),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _getCategoryColor(),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Colors.white.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
