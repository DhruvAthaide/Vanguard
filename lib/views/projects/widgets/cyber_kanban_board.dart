import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';
import 'task_editor_sheet.dart';

class CyberKanbanBoard extends ConsumerWidget {
  final int projectId;
  final List<TaskNode> taskNodes;

  const CyberKanbanBoard({
    super.key,
    required this.projectId,
    required this.taskNodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Flatten nodes to tasks
    final List<Task> allTasks = [];
    void flatten(List<TaskNode> nodes) {
      for (var node in nodes) {
        allTasks.add(node.task);
        flatten(node.children);
      }
    }
    flatten(taskNodes);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KanbanColumn(
            title: "TO DO",
            statusValues: const ['todo'],
            tasks: allTasks,
            color: Colors.blue,
            projectId: projectId,
          ),
          _KanbanColumn(
            title: "IN PROGRESS",
            statusValues: const ['progress'],
            tasks: allTasks,
            color: CyberTheme.accent,
            projectId: projectId,
          ),
          _KanbanColumn(
            title: "REVIEW",
            statusValues: const ['review'],
            tasks: allTasks,
            color: Colors.orange,
            projectId: projectId,
          ),
          _KanbanColumn(
            title: "DONE",
            statusValues: const ['done'],
            tasks: allTasks,
            color: CyberTheme.success,
            projectId: projectId,
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  final String title;
  final List<String> statusValues;
  final List<Task> tasks;
  final Color color;
  final int projectId;

  const _KanbanColumn({
    required this.title,
    required this.statusValues,
    required this.tasks,
    required this.color,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnTasks =
    tasks.where((t) => statusValues.contains(t.status)).toList();

    return DragTarget<Task>(
      onWillAccept: (data) => true,
      onAccept: (task) {
        // Update status to the first value of this column
        final newStatus = statusValues.first;
        if (task.status != newStatus) {
          ref.read(projectActionsProvider).dao.updateTask(
            task.id,
            TasksCompanion(status: drift.Value(newStatus)),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isHovered
                ? LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            )
                : LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovered ? color : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${columnTasks.length}",
                      style: GoogleFonts.robotoMono(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),

              // List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: columnTasks.length,
                itemBuilder: (context, index) {
                  return _KanbanCard(
                    task: columnTasks[index],
                    color: color,
                  );
                },
              ),

              if (columnTasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    "EMPTY",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  final Color color;

  const _KanbanCard({required this.task, required this.color});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Transform.scale(
        scale: 1.05,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CyberTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)
              ],
            ),
            child: Text(
              task.title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildCardContent(),
      ),
      child: GestureDetector(
        onTap: () {
          // Edit
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) =>
                TaskEditorSheet(projectId: task.projectId, taskToEdit: task),
          );
        },
        child: _buildCardContent(),
      ),
    );
  }

  Widget _buildCardContent() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.threatLevel > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: 8),
                        child: Icon(
                          LucideIcons.flame,
                          size: 14,
                          color: CyberTheme.danger,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (task.deadline != null)
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 11,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Due ${task.deadline!.day}/${task.deadline!.month}",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    _StatusChip(status: task.status, color: color),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  String get _displayStatus {
    switch (status) {
      case 'todo':
        return 'TO DO';
      case 'progress':
        return 'IN PROGRESS';
      case 'review':
        return 'REVIEW';
      case 'done':
        return 'DONE';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        _displayStatus,
        style: GoogleFonts.inter(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}