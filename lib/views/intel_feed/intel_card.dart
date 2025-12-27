import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/intel_item.dart';
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
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
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

  // ────────────────────────────────────────────────────────────
  // CATEGORY STYLING
  // ────────────────────────────────────────────────────────────

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
        return const Color(0xFF10B981);
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

  // ────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _openArticle(context),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          child: Stack(
            children: [
              // ── SHIMMER ACCENT ────────────────────────────────
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
                              (_shimmerAnimation.value - 0.4)
                                  .clamp(0.0, 1.0),
                              _shimmerAnimation.value.clamp(0.0, 1.0),
                              (_shimmerAnimation.value + 0.4)
                                  .clamp(0.0, 1.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // ── MAIN CARD ─────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.72),
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.52),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: categoryColor.withOpacity(0.12),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // LEFT ACCENT BAR
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  categoryColor,
                                  categoryColor.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // CONTENT
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CATEGORY BADGE
                              Row(
                                children: [
                                  _buildCategoryBadge(categoryColor),
                                  const Spacer(),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color:
                                    Colors.white.withOpacity(0.6),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // TITLE
                              Text(
                                widget.item.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // SUMMARY
                              Text(
                                widget.item.summary,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  height: 1.6,
                                  color:
                                  Colors.white.withOpacity(0.75),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // FOOTER
                              Row(
                                children: [
                                  _buildMetaChip(
                                    icon: Icons.public,
                                    text: widget.item.source,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildMetaChip(
                                    icon: Icons.schedule_rounded,
                                    text: _timeAgo(
                                      widget.item.publishedAt,
                                    ),
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
    );
  }

  // ────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────

  Widget _buildCategoryBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.35),
            color.withOpacity(0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            widget.item.category.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: color,
              fontWeight: FontWeight.bold,
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w500,
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
            child: child,
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
