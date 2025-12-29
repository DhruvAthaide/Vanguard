import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';

class CyberNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavDestination> destinations;

  const CyberNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  State<CyberNavBar> createState() => _CyberNavBarState();
}

class _CyberNavBarState extends State<CyberNavBar>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CyberTheme.surface.withOpacity(0.85),
                  CyberTheme.surface.withOpacity(0.65),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: CyberTheme.accent.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                widget.destinations.length,
                (index) => _NavItem(
                  destination: widget.destinations[index],
                  isSelected: widget.selectedIndex == index,
                  isHovered: _hoveredIndex == index,
                  glowAnimation: _glowController,
                  onTap: () => widget.onDestinationSelected(index),
                  onHover: (hovering) {
                    setState(() {
                      _hoveredIndex = hovering ? index : null;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final NavDestination destination;
  final bool isSelected;
  final bool isHovered;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;
  final Function(bool) onHover;

  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.isHovered,
    required this.glowAnimation,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with glow
                AnimatedBuilder(
                  animation: widget.glowAnimation,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: widget.isSelected
                            ? LinearGradient(
                                colors: [
                                  CyberTheme.accent.withOpacity(0.3),
                                  CyberTheme.accent.withOpacity(0.1),
                                ],
                              )
                            : null,
                        boxShadow: widget.isSelected
                            ? [
                                BoxShadow(
                                  color: CyberTheme.accent.withOpacity(
                                    0.4 + (widget.glowAnimation.value * 0.2),
                                  ),
                                  blurRadius: 15 + (widget.glowAnimation.value * 5),
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.destination.icon,
                        size: 22,
                        color: widget.isSelected
                            ? CyberTheme.accent
                            : widget.isHovered
                                ? Colors.white.withOpacity(0.9)
                                : Colors.white.withOpacity(0.6),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 3),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: widget.isSelected
                        ? CyberTheme.accent
                        : widget.isHovered
                            ? Colors.white.withOpacity(0.9)
                            : Colors.white.withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                  child: Text(widget.destination.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavDestination {
  final IconData icon;
  final String label;

  const NavDestination({
    required this.icon,
    required this.label,
  });
}
