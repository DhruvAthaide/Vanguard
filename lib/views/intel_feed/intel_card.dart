import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/intel_item.dart';
import '../../core/theme/cyber_theme.dart';
import '../intel_detail/intel_article_webview.dart';

class IntelCard extends StatefulWidget {
  final IntelItem item;
  final int index;

  const IntelCard({
    super.key,
    required this.item,
    this.index = 0,
  });

  @override
  State<IntelCard> createState() => _IntelCardState();
}

class _IntelCardState extends State<IntelCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    switch (widget.item.category.toLowerCase()) {
      case 'exploits':
        return const Color(0xFFFF3B3B);
      case 'malware':
        return const Color(0xFFFF6B2C);
      case 'mobile security':
        return const Color(0xFF9D4EDD);
      case 'threat intel':
        return const Color(0xFF3B82F6);
      case 'leaks':
        return const Color(0xFFEF4444);
      default:
        return CyberTheme.accent;
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.item.category.toLowerCase()) {
      case 'exploits':
        return Icons.bug_report_rounded;
      case 'malware':
        return Icons.coronavirus_rounded;
      case 'mobile security':
        return Icons.phone_android_rounded;
      case 'threat intel':
        return Icons.psychology_rounded;
      case 'leaks':
        return Icons.water_drop_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _openArticle(context);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0),
          duration: Duration(milliseconds: _isPressed ? 100 : 300),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 20),
            child: Stack(
              children: [
                // Hover Glow Effect
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Shimmer Accent
                if (!_isPressed)
                  AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (_, __) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColor.withOpacity(0.15),
                                Colors.transparent,
                                categoryColor.withOpacity(0.08),
                              ],
                              stops: [
                                (_shimmerAnimation.value - 0.4).clamp(0.0, 1.0),
                                _shimmerAnimation.value.clamp(0.0, 1.0),
                                (_shimmerAnimation.value + 0.4).clamp(0.0, 1.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Main Card with Enhanced Glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _isHovered ? 24 : 18,
                      sigmaY: _isHovered ? 24 : 18,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isHovered
                              ? [
                                  CyberTheme.surface.withOpacity(0.85),
                                  CyberTheme.surface.withOpacity(0.65),
                                ]
                              : [
                                  CyberTheme.surface.withOpacity(0.75),
                                  CyberTheme.surface.withOpacity(0.55),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: _isHovered
                              ? categoryColor.withOpacity(0.4)
                              : Colors.white.withOpacity(0.12),
                          width: _isHovered ? 2.0 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(_isHovered ? 0.2 : 0.12),
                            blurRadius: _isHovered ? 30 : 24,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Animated Left Accent Bar
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: _isHovered ? 6 : 4,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    categoryColor,
                                    categoryColor.withOpacity(0.5),
                                  ],
                                ),
                                boxShadow: _isHovered
                                    ? [
                                        BoxShadow(
                                          color: categoryColor.withOpacity(0.5),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Badge & Arrow
                                Row(
                                  children: [
                                    _buildCategoryBadge(categoryColor),
                                    const Spacer(),
                                    AnimatedRotation(
                                      turns: _isHovered ? 0.0 : -0.125,
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: _isHovered
                                            ? categoryColor
                                            : Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Title
                                Text(
                                  widget.item.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    letterSpacing: -0.4,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Summary
                                Text(
                                  widget.item.summary,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    height: 1.65,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // Footer Meta
                                Row(
                                  children: [
                                    Flexible(
                                      child: _buildMetaChip(
                                        icon: Icons.public,
                                        text: widget.item.source,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildMetaChip(
                                      icon: Icons.schedule_rounded,
                                      text: _timeAgo(widget.item.publishedAt),
                                    ),
                                  ],
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(_isHovered ? 0.6 : 0.4),
          width: _isHovered ? 1.5 : 1.0,
        ),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 15,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            widget.item.category.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              letterSpacing: 1.3,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_isHovered ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(_isHovered ? 0.15 : 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.65)),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openArticle(BuildContext context) {
    if (widget.item.url.isEmpty) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => IntelArticleWebView(
          url: widget.item.url,
          title: widget.item.title,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
