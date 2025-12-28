import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';

class TimelineProjectBar extends StatefulWidget {
  final Project project;
  final DateTime minDate;
  final double pxPerDay;
  final VoidCallback onTap;

  const TimelineProjectBar({
    super.key,
    required this.project,
    required this.minDate,
    required this.pxPerDay,
    required this.onTap,
  });

  @override
  State<TimelineProjectBar> createState() => _TimelineProjectBarState();
}

class _TimelineProjectBarState extends State<TimelineProjectBar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _isOverdue {
    final now = DateTime.now();
    final end = widget.project.endDate;
    return end != null && end.isBefore(now) && !widget.project.isArchived;
  }

  bool get _isUpcoming {
    final now = DateTime.now();
    return widget.project.startDate.isAfter(now);
  }

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

    if (_isOverdue || widget.project.priority == 'critical') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startOffset =
        widget.project.startDate.difference(widget.minDate).inDays *
            widget.pxPerDay;
    final durationDays = (widget.project.endDate ??
        widget.project.startDate.add(const Duration(days: 1)))
        .difference(widget.project.startDate)
        .inDays;
    final width = (durationDays < 1 ? 1 : durationDays) * widget.pxPerDay;

    final color = _getPriorityColor(widget.project.priority);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            margin: EdgeInsets.only(
              left: startOffset < 0 ? 0 : startOffset,
              top: 8,
              bottom: 8,
            ),
            width: width,
            height: 32,
            child: Stack(
              children: [
                // Shimmer effect for critical/overdue
                if (_isOverdue || widget.project.priority == 'critical')
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                color.withOpacity(0.15),
                                Colors.transparent,
                                color.withOpacity(0.1),
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

                // Main bar with glassmorphism
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glowOpacity = _isOverdue ||
                        widget.project.priority == 'critical'
                        ? _pulseController.value
                        : 1.0;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _isUpcoming
                                  ? [
                                color.withOpacity(0.3),
                                color.withOpacity(0.15),
                              ]
                                  : [
                                color.withOpacity(0.7),
                                color.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isOverdue
                                  ? CyberTheme.danger.withOpacity(
                                0.5 + (glowOpacity * 0.3),
                              )
                                  : color.withOpacity(
                                _isHovered ? 0.8 : 0.4,
                              ),
                              width: _isOverdue ? 2 : 1.5,
                            ),
                            boxShadow: [
                              if (_isOverdue || widget.project.priority == 'critical')
                                BoxShadow(
                                  color: color.withOpacity(0.3 * glowOpacity),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      // Accent bar on left
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color,
                                color.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            // Status indicator
                            if (_isOverdue)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  LucideIcons.alertTriangle,
                                  size: 14,
                                  color: CyberTheme.danger,
                                ),
                              )
                            else if (_isUpcoming)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  LucideIcons.clock,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              )
                            else if (widget.project.priority == 'critical')
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    LucideIcons.flame,
                                    size: 14,
                                    color: color,
                                  ),
                                ),

                            // Project name
                            Expanded(
                              child: Text(
                                widget.project.name,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _isUpcoming
                                      ? Colors.white.withOpacity(0.6)
                                      : Colors.white,
                                  letterSpacing: 0.3,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),

                            // Archive badge
                            if (widget.project.isArchived)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ARCHIVED',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.5),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return CyberTheme.danger;
      case 'high':
        return const Color(0xFFFF6B2C);
      case 'medium':
        return CyberTheme.accent;
      case 'low':
        return CyberTheme.success;
      default:
        return CyberTheme.accent;
    }
  }
}