import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';

class CyberProjectCard extends ConsumerStatefulWidget {
  final Project project;
  final VoidCallback onTap;

  const CyberProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  ConsumerState<CyberProjectCard> createState() => _CyberProjectCardState();
}

class _CyberProjectCardState extends ConsumerState<CyberProjectCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.project.priority == 'critical' && !widget.project.isArchived) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color get _priorityColor {
    switch (widget.project.priority) {
      case 'critical':
        return CyberTheme.danger;
      case 'high':
        return const Color(0xFFFF6B2C);
      case 'medium':
        return CyberTheme.accent;
      default:
        return CyberTheme.success;
    }
  }

  IconData get _priorityIcon {
    switch (widget.project.priority) {
      case 'critical':
        return LucideIcons.alertTriangle;
      case 'high':
        return LucideIcons.flame;
      case 'medium':
        return LucideIcons.zap;
      default:
        return LucideIcons.checkCircle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksNodesAsync = ref.watch(recursiveTasksProvider(widget.project.id));

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final glowOpacity = widget.project.priority == 'critical'
                ? _pulseAnimation.value
                : 1.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Stack(
                children: [
                  // Shimmer effect for critical items
                  if (widget.project.priority == 'critical' &&
                      !widget.project.isArchived)
                    AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _priorityColor.withOpacity(0.1),
                                  Colors.transparent,
                                  _priorityColor.withOpacity(0.05),
                                ],
                                stops: [
                                  (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                                  _shimmerController.value.clamp(0.0, 1.0),
                                  (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // Main card with glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _priorityColor.withOpacity(0.3 * glowOpacity),
                            width: 1.5,
                          ),
                          boxShadow: widget.project.priority == 'critical' &&
                              !widget.project.isArchived
                              ? [
                            BoxShadow(
                              color: _priorityColor
                                  .withOpacity(0.2 * glowOpacity),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                              : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Stack(
            children: [
              // Accent bar on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _priorityColor,
                        _priorityColor.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _priorityColor.withOpacity(0.25),
                                      _priorityColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _priorityColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  _priorityIcon,
                                  size: 16,
                                  color: _priorityColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.project.name.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (widget.project.isArchived)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.archive,
                                  size: 10,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "ARCHIVED",
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _priorityColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _priorityColor.withOpacity(
                                        0.5 * _pulseAnimation.value,
                                      ),
                                      blurRadius: 8 * _pulseAnimation.value,
                                      spreadRadius: 2 * _pulseAnimation.value,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    if (widget.project.description != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          widget.project.description!,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.65),
                            height: 1.5,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Progress Section
                    tasksNodesAsync.when(
                      data: (nodes) {
                        int total = 0;
                        int done = 0;

                        void recurse(List<TaskNode> list) {
                          for (var node in list) {
                            total++;
                            if (node.task.status == 'done') done++;
                            recurse(node.children);
                          }
                        }

                        recurse(nodes);

                        double percent = total == 0 ? 0 : done / total;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      LucideIcons.target,
                                      size: 12,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$done/$total OBJECTIVES",
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.6),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _priorityColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "${(percent * 100).toInt()}%",
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 11,
                                      color: _priorityColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Stack(
                              children: [
                                // Background
                                Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                // Progress
                                FractionallySizedBox(
                                  widthFactor: percent,
                                  child: Container(
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          _priorityColor,
                                          _priorityColor.withOpacity(0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _priorityColor.withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                      loading: () => SizedBox(
                        height: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            color: _priorityColor,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      error: (e, s) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 16),

                    // Footer
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.project.endDate != null
                                    ? DateFormat('MMM dd').format(
                                  widget.project.endDate!,
                                )
                                    : "No Deadline",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _priorityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _priorityColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.project.priority.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: _priorityColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}