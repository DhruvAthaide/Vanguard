import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/cyber_theme.dart';
import '../../providers/project_provider.dart';
import '../../providers/intel_provider.dart';
import '../projects/widgets/add_project_sheet.dart';
import '../shell/app_shell.dart';
import 'widgets/stats_card.dart';
import 'widgets/project_progress_widget.dart';
import 'widgets/intel_highlights.dart';
import 'widgets/quick_actions.dart';
import '../timeline/timeline_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _glowController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
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
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
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
    final intelAsync = ref.watch(intelFeedProvider);

    return Scaffold(
      backgroundColor: CyberTheme.background,
      body: Stack(
        children: [
          // Animated gradient background
          Positioned.fill(
            child: RepaintBoundary(
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
                          CyberTheme.accent.withOpacity(0.04),
                          CyberTheme.background,
                          CyberTheme.background,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _headerSlideAnimation,
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                                    "VANGUARD",
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 2.2,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Mission Overview",
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getGreeting(),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Stats Cards
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: projectsAsync.when(
                        data: (projects) {
                          final activeProjects = projects.where((p) => !p.isArchived).length;

                          return Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  icon: LucideIcons.layers,
                                  label: "Active Ops",
                                  value: activeProjects.toString(),
                                  color: CyberTheme.accent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: intelAsync.when(
                                  data: (intel) => StatsCard(
                                    icon: LucideIcons.alertTriangle,
                                    label: "Threats",
                                    value: intel.length.toString(),
                                    color: CyberTheme.danger,
                                  ),
                                  loading: () => const StatsCard(
                                    icon: LucideIcons.alertTriangle,
                                    label: "Threats",
                                    value: "...",
                                    color: CyberTheme.danger,
                                  ),
                                  error: (_, __) => const StatsCard(
                                    icon: LucideIcons.alertTriangle,
                                    label: "Threats",
                                    value: "0",
                                    color: CyberTheme.danger,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Quick Actions
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: QuickActions(
                        onCreateProject: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AddProjectSheet(),
                          );
                        },
                        onViewTimeline: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const TimelineScreen(),
                              transitionsBuilder:
                                  (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        onViewIntel: () {
                          appShellKey.currentState?.switchTab(1);
                        },
                        onViewVault: () {
                          appShellKey.currentState?.switchTab(3);
                        },
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Project Progress
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: projectsAsync.when(
                        data: (projects) {
                          final activeProjects = projects.where((p) => !p.isArchived).toList();
                          if (activeProjects.isEmpty) return const SizedBox.shrink();
                          return ProjectProgressWidget(projects: activeProjects.take(3).toList());
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Intel Highlights
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: intelAsync.when(
                        data: (intel) {
                          if (intel.isEmpty) return const SizedBox.shrink();
                          return IntelHighlights(items: intel.take(3).toList());
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning, Commander";
    if (hour < 17) return "Good afternoon, Commander";
    return "Good evening, Commander";
  }
}