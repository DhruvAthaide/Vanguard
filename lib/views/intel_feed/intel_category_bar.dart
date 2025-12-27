import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../../providers/intel_provider.dart';

class IntelCategoryBar extends ConsumerStatefulWidget {
  const IntelCategoryBar({super.key});

  @override
  ConsumerState<IntelCategoryBar> createState() => _IntelCategoryBarState();
}

class _IntelCategoryBarState extends ConsumerState<IntelCategoryBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
      height: 72,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;

          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                  // Haptic feedback would go here if available
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.8),
                        ],
                      )
                          : null,
                      color: isSelected
                          ? null
                          : Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5)
                            : Colors.white.withOpacity(0.1),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
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
                                          0.3 * _pulseController.value,
                                        ),
                                        blurRadius: 8 * _pulseController.value,
                                        spreadRadius:
                                        2 * _pulseController.value,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.white.withOpacity(0.85),
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}