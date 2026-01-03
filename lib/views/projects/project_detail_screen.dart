import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/cyber_theme.dart';
import '../../database/app_database.dart';
import '../../providers/project_provider.dart';
import 'widgets/cyber_task_tree.dart';
import 'widgets/cyber_kanban_board.dart';
import 'widgets/task_editor_sheet.dart';
import 'widgets/add_project_sheet.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen>
    with TickerProviderStateMixin {
  bool _isKanbanMode = false;
  late AnimationController _modeTransitionController;
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();

    _modeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0, // Start fully visible
    );

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _modeTransitionController.dispose();
    _headerController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(recursiveTasksProvider(widget.project.id));

    // Trigger animation when switching modes
    ref.listen(recursiveTasksProvider(widget.project.id), (previous, next) {
      // When tasks change, restart the mode transition animation
      if (previous?.hasValue == true && next.hasValue) {
        _modeTransitionController.forward(from: 0);
      }
    });

    return Scaffold(
      backgroundColor: CyberTheme.background,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.8),
                  radius: 1.5,
                  colors: [
                    _priorityColor.withOpacity(0.05),
                    CyberTheme.background,
                    CyberTheme.background,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- ANIMATED HEADER ---
                FadeTransition(
                  opacity: _headerController,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.arrowLeft,
                                  size: 20,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.project.name.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // View Toggle
                            GestureDetector(
                              onTap: () {
                                setState(() => _isKanbanMode = !_isKanbanMode);
                                _modeTransitionController.forward(from: 0);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _priorityColor.withOpacity(0.2),
                                      _priorityColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _priorityColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  _isKanbanMode
                                      ? LucideIcons.list
                                      : LucideIcons.layoutGrid,
                                  color: _priorityColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Menu
                            PopupMenuButton<String>(
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: const Icon(
                                  LucideIcons.moreVertical,
                                  size: 20,
                                  color: Colors.white70,
                                ),
                              ),
                              color: CyberTheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              onSelected: (val) async {
                                if (val == 'edit') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => AddProjectSheet(
                                        projectToEdit: widget.project),
                                  );
                                } else if (val == 'archive') {
                                  await ref
                                      .read(projectActionsProvider)
                                      .archiveProject(
                                    widget.project.id,
                                    !widget.project.isArchived,
                                  );
                                } else if (val == 'delete') {
                                  await ref
                                      .read(projectActionsProvider)
                                      .deleteProject(widget.project.id);
                                  if (context.mounted) Navigator.pop(context);
                                }
                              },
                              itemBuilder: (context) => [
                                _buildMenuItem(
                                  'edit',
                                  "Edit Parameters",
                                  LucideIcons.edit,
                                ),
                                _buildMenuItem(
                                  'archive',
                                  widget.project.isArchived
                                      ? "Unarchive Operation"
                                      : "Archive Operation",
                                  LucideIcons.archive,
                                ),
                                _buildMenuItem(
                                  'delete',
                                  "Terminate Operation",
                                  LucideIcons.trash2,
                                  isDestructive: true,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Metadata Cards
                        if (widget.project.description != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              widget.project.description!,
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                                height: 1.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        Row(
                          children: [
                            _MetadataBadge(
                              icon: LucideIcons.shieldAlert,
                              label: widget.project.priority.toUpperCase(),
                              color: _priorityColor,
                            ),
                            const SizedBox(width: 12),
                            _MetadataBadge(
                              icon: LucideIcons.calendar,
                              label: widget.project.endDate != null
                                  ? DateFormat('MMM dd')
                                  .format(widget.project.endDate!)
                                  : "No Deadline",
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --- CONTENT ---
                Expanded(
                  child: tasksAsync.when(
                    data: (nodes) {
                      if (nodes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.05),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  LucideIcons.target,
                                  size: 56,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "No Objectives Defined",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Add objectives to begin operation",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (_isKanbanMode) {
                        return FadeTransition(
                          opacity: _modeTransitionController,
                          child: CyberKanbanBoard(
                            key: ValueKey('kanban-${nodes.length}'),
                            projectId: widget.project.id,
                            taskNodes: nodes,
                          ),
                        );
                      }

                      return FadeTransition(
                        key: ValueKey('list-${nodes.length}'),
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _modeTransitionController,
                            curve: Curves.easeIn,
                          ),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: nodes.length,
                          itemBuilder: (context, index) {
                            return CyberTaskTree(
                              key: ValueKey('task-${nodes[index].task.id}'),
                              node: nodes[index],
                              onToggleStatus: () {
                                ref
                                    .read(projectActionsProvider)
                                    .toggleTaskStatus(nodes[index].task);
                              },
                            );
                          },
                        ),
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: _priorityColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading objectives...",
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (e, s) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            size: 48,
                            color: CyberTheme.danger,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error: $e",
                            style: GoogleFonts.inter(
                              color: CyberTheme.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _headerController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => TaskEditorSheet(projectId: widget.project.id),
            );
          },
          backgroundColor: _priorityColor,
          elevation: 8,
          label: Text(
            "Add Objective",
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          icon: const Icon(LucideIcons.plus, color: Colors.black, size: 20),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      String value,
      String label,
      IconData icon, {
        bool isDestructive = false,
      }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDestructive ? CyberTheme.danger : Colors.white70,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isDestructive ? CyberTheme.danger : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetadataBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}