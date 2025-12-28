import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';
import '../../../providers/project_provider.dart';
import 'team_member_selector.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  final int projectId;
  final Task? parentTask;
  final Task? taskToEdit;

  const TaskEditorSheet({
    super.key,
    required this.projectId,
    this.parentTask,
    this.taskToEdit,
  });

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  int? _selectedAssigneeId;
  double _threatLevel = 1.0;
  DateTime? _startDate;
  DateTime? _deadline;
  String _status = 'Yet to Plan';
  late AnimationController _animController;

  final List<String> _statuses = [
    'Yet to Plan',
    'Planning',
    'In Progress',
    'Update Required',
    'On Hold',
    'Completed',
    'DeadEnd'
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description ?? '';
      _selectedAssigneeId = t.assignedMemberId;
      _threatLevel = t.threatLevel.toDouble();
      _startDate = t.startDate;
      _deadline = t.deadline;
      _status = t.status;
    } else {
      _startDate = DateTime.now();
      _deadline = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Color _getThreatColor(double val) {
    switch (val.toInt()) {
      case 0:
        return Colors.blue;
      case 1:
        return CyberTheme.accent;
      case 2:
        return const Color(0xFFFF6B2C);
      case 3:
        return CyberTheme.danger;
      default:
        return Colors.white;
    }
  }

  String _getThreatLabel(double val) {
    switch (val.toInt()) {
      case 0:
        return "LOW";
      case 1:
        return "MEDIUM";
      case 2:
        return "HIGH";
      case 3:
        return "CRITICAL";
      default:
        return "UNKNOWN";
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(teamMembersProvider);
    final isEdit = widget.taskToEdit != null;
    final threatColor = _getThreatColor(_threatLevel);

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutCubic,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CyberTheme.surface.withOpacity(0.95),
                  CyberTheme.surface.withOpacity(0.98),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  threatColor.withOpacity(0.2),
                                  threatColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEdit ? LucideIcons.edit : LucideIcons.target,
                              color: threatColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEdit
                                ? "UPDATE PROTOCOL"
                                : (widget.parentTask != null
                                ? "ADD SUB-ROUTINE"
                                : "NEW OBJECTIVE"),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: threatColor,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.x,
                            color: Colors.white54,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Title
                  _InputField(
                    controller: _titleCtrl,
                    label: "Objective Title",
                    hint: "Enter mission objective",
                    icon: LucideIcons.crosshair,
                    autofocus: !isEdit,
                  ),

                  const SizedBox(height: 20),

                  // Description
                  _InputField(
                    controller: _descCtrl,
                    label: "Tactical Details",
                    hint: "Enter operation details (optional)",
                    icon: LucideIcons.fileText,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 28),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: _DatePicker(
                          label: "START DATE",
                          date: _startDate,
                          color: CyberTheme.accent,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePicker(
                          label: "DEADLINE",
                          date: _deadline,
                          color: CyberTheme.danger,
                          onTap: () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Status Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Text(
                          "CURRENT STATUS",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white54,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.03),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              dropdownColor: CyberTheme.surface,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Icon(
                                    LucideIcons.activity,
                                    size: 20,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 18,
                                ),
                              ),
                              items: _statuses
                                  .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _status = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Threat Level Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "THREAT LEVEL",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    threatColor.withOpacity(0.3),
                                    threatColor.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: threatColor.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                _getThreatLabel(_threatLevel),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: threatColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.03),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: threatColor,
                                inactiveTrackColor:
                                Colors.white.withOpacity(0.1),
                                thumbColor: threatColor,
                                overlayColor: threatColor.withOpacity(0.2),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _threatLevel,
                                min: 0,
                                max: 3,
                                divisions: 3,
                                onChanged: (val) =>
                                    setState(() => _threatLevel = val),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Team Member Selector
                  membersAsync.when(
                    data: (members) {
                      if (members.isEmpty) return const SizedBox.shrink();
                      return TeamMemberSelector(
                        members: members,
                        selectedId: _selectedAssigneeId,
                        onSelected: (id) =>
                            setState(() => _selectedAssigneeId = id),
                      );
                    },
                    loading: () => const SizedBox(height: 60),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      if (isEdit)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(projectActionsProvider)
                                  .dao
                                  .deleteTask(widget.taskToEdit!.id);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: CyberTheme.danger.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    LucideIcons.trash2,
                                    color: CyberTheme.danger,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "ABORT",
                                    style: GoogleFonts.inter(
                                      color: CyberTheme.danger,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (isEdit) const SizedBox(width: 12),
                      Expanded(
                        flex: isEdit ? 2 : 1,
                        child: GestureDetector(
                          onTap: _saveTask,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  threatColor,
                                  threatColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: threatColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  LucideIcons.check,
                                  color: Colors.black,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEdit ? "UPDATE INTEL" : "DEPLOY OBJECTIVE",
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _startDate : _deadline;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: _getThreatColor(_threatLevel),
              onPrimary: Colors.black,
              surface: CyberTheme.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _deadline = picked;
        }
      });
    }
  }

  void _saveTask() {
    if (_titleCtrl.text.isEmpty) return;

    final dao = ref.read(projectActionsProvider).dao;
    final companion = TasksCompanion(
      title: Value(_titleCtrl.text),
      description: Value(_descCtrl.text),
      status: Value(_status),
      threatLevel: Value(_threatLevel.toInt()),
      assignedMemberId: Value(_selectedAssigneeId),
      startDate: Value(_startDate),
      deadline: Value(_deadline),
      projectId: widget.taskToEdit != null
          ? const Value.absent()
          : Value(widget.projectId),
      parentTaskId: widget.parentTask != null
          ? Value(widget.parentTask!.id)
          : (widget.taskToEdit != null
          ? const Value.absent()
          : const Value.absent()),
    );

    if (widget.taskToEdit != null) {
      dao.updateTask(widget.taskToEdit!.id, companion);
    } else {
      dao.createTask(companion);
    }
    Navigator.pop(context);
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool autofocus;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                maxLines: maxLines,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Icon(
                      icon,
                      size: 20,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Color color;
  final VoidCallback onTap;

  const _DatePicker({
    required this.label,
    required this.date,
    this.color = CyberTheme.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                color: color.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white54,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 16, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date != null
                            ? DateFormat('MMM dd').format(date!)
                            : "Select",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}