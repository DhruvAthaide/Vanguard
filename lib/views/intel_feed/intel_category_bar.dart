import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/intel_provider.dart';
import '../../core/theme/cyber_theme.dart';

class IntelCategoryBar extends ConsumerStatefulWidget {
  const IntelCategoryBar({super.key});

  @override
  ConsumerState<IntelCategoryBar> createState() => _IntelCategoryBarState();
}

class _IntelCategoryBarState extends ConsumerState<IntelCategoryBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedCategoryProvider);

    final categories = const [
      "All",
      "Exploits",
      "Malware",
      "Mobile Security",
      "Threat Intel",
      "Leaks",
    ];

    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          final isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = category;
                  },
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : (isHovered ? 1.05 : 0.96),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: isSelected || isHovered ? 16 : 12,
                          sigmaY: isSelected || isHovered ? 16 : 12,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      CyberTheme.accent,
                                      CyberTheme.accent.withOpacity(0.85),
                                    ],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      CyberTheme.surface.withOpacity(isHovered ? 0.5 : 0.35),
                                      CyberTheme.surface.withOpacity(isHovered ? 0.35 : 0.25),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? CyberTheme.accent.withOpacity(0.6)
                                  : Colors.white.withOpacity(isHovered ? 0.2 : 0.12),
                              width: isSelected ? 2.0 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: CyberTheme.accent.withOpacity(0.35),
                                      blurRadius: 20,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: CyberTheme.accent.withOpacity(0.15),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : isHovered
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (context, child) {
                                      return Container(
                                        width: 7,
                                        height: 7,
                                        margin: const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.4 * _pulseController.value,
                                              ),
                                              blurRadius: 10 * _pulseController.value,
                                              spreadRadius: 3 * _pulseController.value,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                Text(
                                  category,
                                  style: GoogleFonts.inter(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white.withOpacity(isHovered ? 0.95 : 0.85),
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}