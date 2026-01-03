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
      height: 48,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          final isHovered = _hoveredIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = category;
                  },
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : (isHovered ? 1.04 : 0.98),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: isSelected || isHovered ? 14 : 10,
                          sigmaY: isSelected || isHovered ? 14 : 10,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CyberTheme.accent,
                                CyberTheme.accent.withOpacity(0.9),
                              ],
                            )
                                : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                CyberTheme.surface.withOpacity(isHovered ? 0.55 : 0.4),
                                CyberTheme.surface.withOpacity(isHovered ? 0.4 : 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? CyberTheme.accent.withOpacity(0.5)
                                  : Colors.white.withOpacity(isHovered ? 0.15 : 0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: CyberTheme.accent.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: CyberTheme.accent.withOpacity(0.12),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ]
                                : isHovered
                                ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
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
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.35 * _pulseController.value,
                                              ),
                                              blurRadius: 8 * _pulseController.value,
                                              spreadRadius: 2 * _pulseController.value,
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
                                        : Colors.white.withOpacity(isHovered ? 0.95 : 0.8),
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
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