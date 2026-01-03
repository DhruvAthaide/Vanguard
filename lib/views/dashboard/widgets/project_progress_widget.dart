import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';

class ProjectProgressWidget extends StatelessWidget {
  final List<Project> projects;

  const ProjectProgressWidget({
    super.key,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Active Operations",
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        ...projects.map((project) => _ProjectCard(project: project)),
      ],
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isPressed = false;

  Color _getPriorityColor() {
    switch (widget.project.priority.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.project.endDate != null
        ? widget.project.endDate!.difference(DateTime.now()).inDays
        : null;
    final daysTotal = widget.project.endDate != null
        ? widget.project.endDate!.difference(widget.project.startDate).inDays
        : null;
    final progress = daysTotal != null && daysTotal > 0
        ? ((daysTotal - (daysRemaining ?? 0)) / daysTotal).clamp(0.0, 1.0)
        : 0.0;

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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CyberTheme.surface.withOpacity(0.65),
                      CyberTheme.surface.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getPriorityColor().withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            widget.project.name,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _getPriorityColor(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation(_getPriorityColor()),
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          daysRemaining != null
                              ? daysRemaining > 0
                              ? "$daysRemaining days left"
                              : "Overdue"
                              : "No deadline",
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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