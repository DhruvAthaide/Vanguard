import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/project_provider.dart';
import '../../database/app_database.dart';

class TaskList extends ConsumerWidget {
  final int projectId;

  const TaskList({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(projectDaoProvider);

    return StreamBuilder<List<Task>>(
      stream: dao.watchTasksForProject(projectId),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "No tasks",
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        return Column(
          children: tasks.map((task) {
            return ListTile(
              leading: StatusIndicator(status: task.status),
              title: Text(task.title),
              subtitle: Text(
                "Assigned: ${task.assignedTo}",
                style: const TextStyle(color: Colors.white60),
              ),
              trailing: Text(
                _formatDate(task.deadline),
                style: const TextStyle(color: Colors.white54),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}";
  }
}

// ─────────────────────────────────────────
// STATUS INDICATOR (MUST BE IN SAME FILE)
// ─────────────────────────────────────────

class StatusIndicator extends StatefulWidget {
  final String status;

  const StatusIndicator({super.key, required this.status});

  @override
  State<StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<StatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.status == 'progress') {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (widget.status) {
      case 'progress':
        color = Colors.orange;
        break;
      case 'done':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    if (widget.status == 'progress') {
      return FadeTransition(
        opacity: _controller,
        child: _dot(color),
      );
    }

    return _dot(color);
  }

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
