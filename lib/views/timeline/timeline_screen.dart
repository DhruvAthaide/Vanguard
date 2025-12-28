import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../core/theme/cyber_theme.dart';
import '../../providers/project_provider.dart';
import '../projects/project_detail_screen.dart';
import 'widgets/timeline_header.dart';
import 'widgets/timeline_project_bar.dart';
import 'widgets/timeline_legend.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen>
    with TickerProviderStateMixin {
  double _pxPerDay = 24.0;
  final double _headerWidth = 180.0;

  late AnimationController _headerController;
  late AnimationController _glowController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      backgroundColor: CyberTheme.background,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        -0.5 + (_glowController.value * 0.3),
                        -0.8 + (_glowController.value * 0.2),
                      ),
                      radius: 1.5,
                      colors: [
                        CyberTheme.accent.withOpacity(0.03),
                        CyberTheme.background,
                        CyberTheme.background,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Animated Header
                SlideTransition(
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        children: [
                          // Title Section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnimatedBuilder(
                                  animation: _glowController,
                                  builder: (context, child) {
                                    return ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: [
                                            CyberTheme.accent,
                                            CyberTheme.accent.withOpacity(
                                              0.7 + (_glowController.value * 0.3),
                                            ),
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        "MISSION TIMELINE",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 2.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Operation Schedule",
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1.0,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Zoom Controls
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.04),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ZoomButton(
                                      icon: LucideIcons.minus,
                                      onPressed: () {
                                        setState(() {
                                          _pxPerDay = (_pxPerDay - 4).clamp(8.0, 48.0);
                                        });
                                      },
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                    _ZoomButton(
                                      icon: LucideIcons.plus,
                                      onPressed: () {
                                        setState(() {
                                          _pxPerDay = (_pxPerDay + 4).clamp(8.0, 48.0);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Timeline Content
                Expanded(
                  child: projectsAsync.when(
                    data: (projects) {
                      if (projects.isEmpty) {
                        return Center(
                          child: FadeTransition(
                            opacity: _headerFadeAnimation,
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
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Icon(
                                    LucideIcons.calendar,
                                    size: 56,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  "No Operations Scheduled",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Create operations to track their timeline",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Calculate date bounds
                      DateTime minDate = DateTime.now();
                      DateTime maxDate = DateTime.now().add(const Duration(days: 30));

                      for (var p in projects) {
                        if (p.startDate.isBefore(minDate)) minDate = p.startDate;
                        if (p.endDate != null && p.endDate!.isAfter(maxDate)) {
                          maxDate = p.endDate!;
                        }
                      }

                      minDate = minDate.subtract(const Duration(days: 7));
                      maxDate = maxDate.add(const Duration(days: 30));

                      final totalDays = maxDate.difference(minDate).inDays;
                      final totalWidth = totalDays * _pxPerDay;
                      final todayOffset =
                          DateTime.now().difference(minDate).inDays * _pxPerDay;

                      return FadeTransition(
                        opacity: _headerFadeAnimation,
                        child: Stack(
                          children: [
                            _LinkedScrollBody(
                              headerWidth: _headerWidth,
                              projects: projects,
                              minDate: minDate,
                              maxDate: maxDate,
                              pxPerDay: _pxPerDay,
                              totalWidth: totalWidth,
                              todayOffset: todayOffset,
                            ),

                            // Floating Legend
                            const Positioned(
                              bottom: 24,
                              left: 0,
                              right: 0,
                              child: Center(child: TimelineLegend()),
                            ),
                          ],
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                CyberTheme.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading timeline...",
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
                            style: GoogleFonts.inter(color: CyberTheme.danger),
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
    );
  }
}

class _ZoomButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_ZoomButton> createState() => _ZoomButtonState();
}

class _ZoomButtonState extends State<_ZoomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            widget.icon,
            color: Colors.white70,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _LinkedScrollBody extends StatefulWidget {
  final double headerWidth;
  final List<dynamic> projects;
  final DateTime minDate;
  final DateTime maxDate;
  final double pxPerDay;
  final double totalWidth;
  final double todayOffset;

  const _LinkedScrollBody({
    required this.headerWidth,
    required this.projects,
    required this.minDate,
    required this.maxDate,
    required this.pxPerDay,
    required this.totalWidth,
    required this.todayOffset,
  });

  @override
  State<_LinkedScrollBody> createState() => _LinkedScrollBodyState();
}

class _LinkedScrollBodyState extends State<_LinkedScrollBody> {
  final ScrollController _verticalCtrl = ScrollController();
  final ScrollController _horizontalCtrl = ScrollController();

  @override
  void dispose() {
    _verticalCtrl.dispose();
    _horizontalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _verticalCtrl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pinned Left Column (Project Names)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: widget.headerWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
                  ),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Header space
                    Container(
                      height: 50,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Text(
                        "OPERATIONS",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: CyberTheme.accent,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    // Project names
                    ...widget.projects.asMap().entries.map((entry) {
                      final index = entry.key;
                      final project = entry.value;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(-20 * (1 - value), 0),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(project.priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.85),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable Timeline Area
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalCtrl,
              child: SizedBox(
                width: widget.totalWidth,
                child: Stack(
                  children: [
                    // Week Grid Background
                    Positioned.fill(
                      child: Row(
                        children: List.generate(
                          (widget.totalWidth / (widget.pxPerDay * 7)).ceil(),
                              (i) => Container(
                            width: widget.pxPerDay * 7,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.white.withOpacity(0.03),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Header
                        TimelineHeader(
                          minDate: widget.minDate,
                          maxDate: widget.maxDate,
                          pxPerDay: widget.pxPerDay,
                          totalWidth: widget.totalWidth,
                        ),

                        // Project Bars
                        ...widget.projects.asMap().entries.map((entry) {
                          final index = entry.key;
                          final project = entry.value;

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 400 + (index * 50)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(30 * (1 - value), 0),
                                  child: child,
                                ),
                              );
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                ),
                              ),
                              child: TimelineProjectBar(
                                project: project,
                                minDate: widget.minDate,
                                pxPerDay: widget.pxPerDay,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                          ProjectDetailScreen(project: project),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                    // Today Line with glow
                    Positioned(
                      left: widget.todayOffset,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.cyanAccent.withOpacity(0.8),
                              Colors.cyanAccent.withOpacity(0.4),
                              Colors.cyanAccent.withOpacity(0.1),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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