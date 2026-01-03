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
          scale: _isPressed ? 0.97 : (_isHovered ? 1.015 : 1.0),
          duration: Duration(milliseconds: _isPressed ? 100 : 250),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 16),
            child: Stack(
              children: [
                // Hover Glow Effect
                if (_isHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(0.25),
                            blurRadius: 32,
                            spreadRadius: 4,
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
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                categoryColor.withOpacity(0.12),
                                Colors.transparent,
                                categoryColor.withOpacity(0.06),
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

                // Main Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _isHovered ? 20 : 16,
                      sigmaY: _isHovered ? 20 : 16,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: _isHovered
                              ? [
                            CyberTheme.surface.withOpacity(0.85),
                            CyberTheme.surface.withOpacity(0.7),
                          ]
                              : [
                            CyberTheme.surface.withOpacity(0.75),
                            CyberTheme.surface.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _isHovered
                              ? categoryColor.withOpacity(0.35)
                              : Colors.white.withOpacity(0.1),
                          width: _isHovered ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withOpacity(_isHovered ? 0.18 : 0.1),
                            blurRadius: _isHovered ? 24 : 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Animated Left Accent Bar
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 250),
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: _isHovered ? 5 : 3.5,
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
                                    color: categoryColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                                    : null,
                              ),
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Badge & Arrow
                                Row(
                                  children: [
                                    Flexible(
                                      child: _buildCategoryBadge(categoryColor),
                                    ),
                                    const SizedBox(width: 8),
                                    const Spacer(),
                                    AnimatedRotation(
                                      turns: _isHovered ? 0.0 : -0.125,
                                      duration: const Duration(milliseconds: 250),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 18,
                                        color: _isHovered
                                            ? categoryColor
                                            : Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Title
                                Text(
                                  widget.item.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3,
                                    letterSpacing: -0.3,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Summary
                                Text(
                                  widget.item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Colors.white.withOpacity(0.75),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Footer Meta
                                Row(
                                  children: [
                                    Flexible(
                                      child: _buildMetaChip(
                                        icon: Icons.public,
                                        text: widget.item.source,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.35),
            color.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(_isHovered ? 0.5 : 0.35),
          width: _isHovered ? 1.2 : 1.0,
        ),
        boxShadow: _isHovered
            ? [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.item.category.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                letterSpacing: 1.2,
                color: color,
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_isHovered ? 0.1 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(_isHovered ? 0.12 : 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
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
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => IntelArticleWebView(
          url: widget.item.url,
          title: widget.item.title,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
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