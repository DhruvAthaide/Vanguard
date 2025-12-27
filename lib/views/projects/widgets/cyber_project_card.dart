import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../providers/project_provider.dart';

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

class _CyberProjectCardState extends ConsumerState<CyberProjectCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2));
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.project.priority == 'critical' && !widget.project.isArchived) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _priorityColor {
    switch (widget.project.priority) {
      case 'critical': return CyberTheme.danger;
      case 'high': return Colors.orange;
      case 'medium': return CyberTheme.accent;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // We listen to the recursive task logic to compute progress
    // Note: efficiency-wise, computing this for every card in the list might be heavy if lists are huge.
    // Ideally this is pre-computed in the DB or Provider. For now, we do it here.
    final tasksNodesAsync = ref.watch(recursiveTasksProvider(widget.project.id));

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final glowOpacity = widget.project.priority == 'critical' ? _pulseAnimation.value : 1.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: CyberTheme.glass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _priorityColor.withOpacity(0.3 * glowOpacity),
                width: 1,
              ),
              boxShadow: widget.project.priority == 'critical' ? [
                BoxShadow(
                   color: _priorityColor.withOpacity(0.2 * glowOpacity),
                   blurRadius: 12,
                   spreadRadius: 2,
                )
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.project.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.project.isArchived)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text("ARCHIVED", style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
                    )
                  else
                    Icon(LucideIcons.activity, size: 16, color: _priorityColor),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.project.description != null)
                Text(
                  widget.project.description!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 16),
              
              // Heatmap / Progress
              tasksNodesAsync.when(
                  data: (nodes) {
                    // Flatten to count
                    int total = 0;
                    int done = 0;
                    
                    void recurse(List<TaskNode> list) {
                       for(var node in list) {
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
                             Text("$done/$total TASKS", style: GoogleFonts.robotoMono(fontSize: 10, color: Colors.white54)),
                             Text("${(percent*100).toInt()}%", style: GoogleFonts.robotoMono(fontSize: 10, color: _priorityColor)),
                           ],
                         ),
                         const SizedBox(height: 6),
                         ClipRRect(
                           borderRadius: BorderRadius.circular(2),
                           child: LinearProgressIndicator(
                             value: percent,
                             backgroundColor: Colors.white.withOpacity(0.1),
                             color: _priorityColor,
                             minHeight: 4,
                           ),
                         ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(color: CyberTheme.accent, minHeight: 2),
                  error: (e, s) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: 12),
              
              // Footer
              Row(
                children: [
                   Icon(LucideIcons.calendar, size: 12, color: Colors.white38),
                   const SizedBox(width: 4),
                   Text(
                     widget.project.endDate != null ? DateFormat('MMM dd').format(widget.project.endDate!) : "No Deadline",
                     style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                   ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
