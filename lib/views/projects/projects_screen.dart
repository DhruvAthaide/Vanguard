import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/cyber_theme.dart';
import '../../providers/project_provider.dart';
import 'project_detail_screen.dart';
import 'widgets/add_project_sheet.dart';
import 'widgets/cyber_project_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final filterState = ref.watch(projectFilterProvider);
    final filterCtrl = ref.read(projectFilterProvider.notifier);

    return Scaffold(
      backgroundColor: CyberTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "COMMAND CENTER",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CyberTheme.accent,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Active Operations",
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: CyberTheme.glass,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.plus, color: CyberTheme.accent),
                      onPressed: () {
                         showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const AddProjectSheet(),
                          );
                      },
                    ),
                  )
                ],
              ),
            ),
            
            // --- SEARCH & FILTER BAR ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                   // Search Field
                   Container(
                     width: 200,
                     height: 40,
                     margin: const EdgeInsets.only(right: 12),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.05),
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: Colors.white.withOpacity(0.1)),
                     ),
                     child: TextField(
                       onChanged: filterCtrl.setSearch,
                       style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                       decoration: InputDecoration(
                         hintText: "Search operations...",
                         hintStyle: GoogleFonts.inter(color: Colors.white38),
                         prefixIcon: const Icon(LucideIcons.search, size: 16, color: Colors.white38),
                         border: InputBorder.none,
                         contentPadding: const EdgeInsets.symmetric(vertical: 10),
                       ),
                     ),
                   ),
                   
                   // Filter Chips
                   _FilterChip(
                      label: "All Active",
                      isActive: !filterState.showArchived && filterState.priorityFilter == null,
                      onTap: () {
                        filterCtrl.toggleArchived(); // Reset logic simplified for demo
                      },
                   ),
                   _FilterChip(
                      label: "Critical",
                      isActive: filterState.priorityFilter == 3,
                      onTap: () => filterCtrl.setPriority(filterState.priorityFilter == 3 ? null : 3),
                      color: CyberTheme.danger,
                   ),
                   _FilterChip(
                      label: "Archived",
                      isActive: filterState.showArchived,
                      onTap: filterCtrl.toggleArchived,
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- PROJECT LIST ---
            Expanded(
              child: projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.folder, size: 48, color: Colors.white10),
                          const SizedBox(height: 16),
                          Text("No Matching Operations", style: GoogleFonts.inter(color: Colors.white38)),
                        ],
                      ),
                    );
                  }
                  
                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: CyberProjectCard(
                                project: projects[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: projects[index])),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: CyberTheme.accent)),
                error: (e,s) => Center(child: Text("Error: $e", style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.color = CyberTheme.accent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
             color: isActive ? color : Colors.white.withOpacity(0.1),
             width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
             fontSize: 12,
             fontWeight: FontWeight.w500,
             color: isActive ? color : Colors.white60,
          ),
        ),
      ),
    );
  }
}
