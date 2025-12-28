import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../database/app_database.dart';

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

class _TimelineProjectBarState extends State<TimelineProjectBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  
  bool get _isOverdue {
    final now = DateTime.now();
    final end = widget.project.endDate;
    // Assume if no endDate, not overdue. Project status logic is simplified here.
    // If 'Completed' -> not overdue.
    // We don't have explicit project status (Task has status), so let's rely on date.
    // If end < now -> Overdue.
    return end != null && end.isBefore(now); 
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Position
    final startOffset = widget.project.startDate.difference(widget.minDate).inDays * widget.pxPerDay;
    final durationDays = (widget.project.endDate ?? widget.project.startDate.add(const Duration(days: 1))).difference(widget.project.startDate).inDays;
    final width = (durationDays < 1 ? 1 : durationDays) * widget.pxPerDay;

    final color = _getPriorityColor(widget.project.priority);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.only(left: startOffset < 0 ? 0 : startOffset, top: 4, bottom: 4),
        width: width,
        height: 32, // Fixed height for bars
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
                border: _isOverdue 
                    ? Border.all(color: CyberTheme.danger.withOpacity(_controller.value), width: 2)
                    : Border.all(color: Colors.white12),
                boxShadow: [
                   if (_isOverdue)
                      BoxShadow(color: CyberTheme.danger.withOpacity(0.4 * _controller.value), blurRadius: 8, spreadRadius: 1)
                ]
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: child,
            );
          },
          child: Text(
            widget.project.name,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical': return CyberTheme.danger; // Deep Red
      case 'high': return const Color(0xFFD32F2F); // Red
      case 'medium': return Colors.orange;
      case 'low': return Colors.green; // Forest Green-ish
      default: return CyberTheme.accent;
    }
  }
}
