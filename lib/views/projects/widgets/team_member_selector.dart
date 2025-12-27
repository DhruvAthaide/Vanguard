import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/cyber_theme.dart';
import '../../../../database/app_database.dart';

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
        Text("ASSIGN OPERATIVE",
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.5)),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: members.length + 1, // +1 for "Unassigned"
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                 return _AvatarItem(
                   initials: "-",
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

class _AvatarItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? CyberTheme.accent : Colors.white.withOpacity(0.1),
              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isSelected ? CyberTheme.accent : Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
