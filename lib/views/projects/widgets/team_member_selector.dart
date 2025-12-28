import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';
import '../../../database/app_database.dart';

class TeamMemberSelector extends StatelessWidget {
  final List<TeamMember> members;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const TeamMemberSelector({
    super.key,
    required this.members,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "ASSIGN OPERATIVE",
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: members.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _AvatarItem(
                  initials: "—",
                  name: "None",
                  isSelected: selectedId == null,
                  onTap: () => onSelected(null),
                );
              }
              final member = members[index - 1];
              return _AvatarItem(
                initials: member.initials,
                name: member.name.split(" ").first,
                isSelected: selectedId == member.id,
                onTap: () => onSelected(member.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AvatarItem extends StatefulWidget {
  final String initials;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarItem({
    required this.initials,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AvatarItem> createState() => _AvatarItemState();
}

class _AvatarItemState extends State<_AvatarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_AvatarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 80,
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow effect for selected
                      if (widget.isSelected)
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CyberTheme.accent.withOpacity(
                                  0.3 + (_controller.value * 0.2),
                                ),
                                blurRadius: 16 + (_controller.value * 8),
                                spreadRadius: 2 + (_controller.value * 2),
                              ),
                            ],
                          ),
                        ),

                      // Main Avatar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.isSelected
                                  ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  CyberTheme.accent,
                                  CyberTheme.accent.withOpacity(0.7),
                                ],
                              )
                                  : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: widget.isSelected
                                    ? CyberTheme.accent
                                    .withOpacity(0.5 + (_controller.value * 0.3))
                                    : Colors.white.withOpacity(0.2),
                                width: widget.isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.initials,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: widget.isSelected
                                    ? Colors.black
                                    : Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Checkmark for selected
                      if (widget.isSelected)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CyberTheme.accent,
                                  CyberTheme.accent.withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CyberTheme.background,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: CyberTheme.accent.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Name
                  Text(
                    widget.name,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: widget.isSelected
                          ? CyberTheme.accent
                          : Colors.white.withOpacity(0.6),
                      fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}