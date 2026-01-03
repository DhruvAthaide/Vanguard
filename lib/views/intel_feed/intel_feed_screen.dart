import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/intel_provider.dart';
import '../../core/theme/cyber_theme.dart';
import 'intel_card.dart';
import 'intel_category_bar.dart';
import 'widgets/intel_filter_dialog.dart';
import 'widgets/threat_map.dart';

class IntelFeedScreen extends ConsumerStatefulWidget {
  const IntelFeedScreen({super.key});

  @override
  ConsumerState<IntelFeedScreen> createState() => _IntelFeedScreenState();
}

class _IntelFeedScreenState extends ConsumerState<IntelFeedScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _pulseController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  final ScrollController _scrollController = ScrollController();

  double _scrollOffset = 0.0;
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _pulseController = AnimationController(
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
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intel = ref.watch(filteredIntelProvider);
    final loading = ref.watch(intelFeedProvider).isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: CyberTheme.background, // Fallback color
        ),
        child: Stack(
          children: [
            // Optimized Background
            RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CyberTheme.background,
                      CyberTheme.background.withOpacity(0.85),
                      CyberTheme.surface.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            SafeArea(
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _headerFadeAnimation,
                child: SlideTransition(
                  position: _headerSlideAnimation,
                  child: _buildFloatingHeader(intel.length),
                ),
              ),

              // Category Bar
              FadeTransition(
                opacity: _headerFadeAnimation,
                child: const IntelCategoryBar(),
              ),

              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    return await ref.refresh(intelFeedProvider.future);
                  },
                  color: CyberTheme.accent,
                  backgroundColor: CyberTheme.surface,
                  child: loading
                      ? _buildLoadingState()
                      : intel.isEmpty
                      ? _buildEmptyState()
                      : _isMapView
                          ? ThreatMapWidget(items: intel)
                          : AnimationLimiter(
                              child: ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                itemCount: intel.length,
                                itemBuilder: (context, index) {
                                  final item = intel[index];
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 600),
                                    child: SlideAnimation(
                                      verticalOffset: 50,
                                      curve: Curves.easeOutCubic,
                                      child: FadeInAnimation(
                                        curve: Curves.easeOut,
                                        child: IntelCard(
                                          item: item,
                                          index: index,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingHeader(int threatCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: CyberTheme.glassDecoration.copyWith(
        color: CyberTheme.glass.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          // Icon with glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CyberTheme.accent,
                      CyberTheme.accent.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: CyberTheme.accent
                          .withOpacity(0.35 + (_pulseController.value * 0.15)),
                      blurRadius: 14 + (_pulseController.value * 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.black,
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "INTEL FEED",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: CyberTheme.accent,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      "$threatCount",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        "Active Signals",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.65),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // View Toggle & Filter
          Row(
            children: [
              // Premium View Toggle
              Container(
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CyberTheme.accent.withOpacity(0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn(
                      icon: LucideIcons.list,
                      label: "Feed",
                      isActive: !_isMapView,
                      onTap: () => setState(() => _isMapView = false),
                    ),
                    const SizedBox(width: 4),
                    _buildToggleBtn(
                      icon: LucideIcons.globe,
                      label: "Map", 
                      isActive: _isMapView,
                      onTap: () => setState(() => _isMapView = true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Filter Button
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CyberTheme.accent.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(LucideIcons.filter, size: 18),
                  color: CyberTheme.accent.withOpacity(0.8),
                  tooltip: "Filter Sources",
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const IntelFilterDialog(),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? CyberTheme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? CyberTheme.accent.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? CyberTheme.accent : Colors.white.withOpacity(0.5),
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CyberTheme.accent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(CyberTheme.accent),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Scanning for threats...",
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(36),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          CyberTheme.accent.withOpacity(0.15),
                          CyberTheme.accent.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 72,
                      color: CyberTheme.accent.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "All Clear",
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No threats in this category",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}