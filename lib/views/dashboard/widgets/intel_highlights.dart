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
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => _IntelCard(item: item)),
      ],
    );
  }
}

class _IntelCard extends StatefulWidget {
  final IntelItem item;

  const _IntelCard({required this.item});

  @override
  State<_IntelCard> createState() => _IntelCardState();
}

class _IntelCardState extends State<_IntelCard> {
  bool _isPressed = false;

  Color _getCategoryColor() {
    switch (widget.item.category.toLowerCase()) {
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
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CyberTheme.surface.withOpacity(0.6),
                      CyberTheme.surface.withOpacity(0.45),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColor.withOpacity(0.3),
                            categoryColor.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        LucideIcons.alertTriangle,
                        color: categoryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.item.category.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: categoryColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      size: 15,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}