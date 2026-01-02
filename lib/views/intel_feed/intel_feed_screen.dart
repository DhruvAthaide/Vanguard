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

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
    final parallaxOffset = (_scrollOffset * 0.3).clamp(0.0, 100.0);

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Stack(
            children: [
              // Main Content
              Column(
                children: [
                  const SizedBox(height: 140), // Space for floating header
                  
                  // Category Bar
                  FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: const IntelCategoryBar(),
                  ),

                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        // Invalidate and wait for the new value
                        return await ref.refresh(intelFeedProvider.future);
                      },
                      color: CyberTheme.accent,
                      backgroundColor: CyberTheme.surface,
                      child: loading
                          ? _buildLoadingState()
                          : intel.isEmpty
                              ? _buildEmptyState()
                              : AnimationLimiter(
                                  child: ListView.builder(
                                    // Ensure it's always scrollable for RefreshIndicator to work
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    controller: _scrollController,
                                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                                    itemCount: intel.length,
                                    itemBuilder: (context, index) {
                                      final item = intel[index];

                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(milliseconds: 700),
                                        child: SlideAnimation(
                                          verticalOffset: 60,
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

              // Floating Header with Parallax
              Positioned(
                top: -parallaxOffset,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _headerSlideAnimation,
                  child: FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: _buildFloatingHeader(intel.length),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingHeader(int threatCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      // Use standard glass decoration from theme but slightly modified for the header
      decoration: CyberTheme.glassDecoration.copyWith(
        color: CyberTheme.glass.withOpacity(0.85),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon with glow
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CyberTheme.accent,
                      CyberTheme.accent.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CyberTheme.accent
                          .withOpacity(0.4 + (_pulseController.value * 0.2)),
                      blurRadius: 16 + (_pulseController.value * 10),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.security_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "INTEL FEED",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: CyberTheme.accent,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "$threatCount",
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Active Signals",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.filter),
              color: Colors.white.withOpacity(0.8),
              tooltip: "Filter Sources",
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(CyberTheme.accent),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "Scanning for threats...",
            style: GoogleFonts.inter(
              fontSize: 16,
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
                    padding: const EdgeInsets.all(40),
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
                      size: 80,
                      color: CyberTheme.accent.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "All Clear",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No threats in this category",
                    style: GoogleFonts.inter(
                      fontSize: 15,
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