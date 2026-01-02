import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../providers/intel_provider.dart';
import '../../../services/intel_sources.dart';

class IntelFilterDialog extends ConsumerWidget {
  const IntelFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSources = ref.watch(selectedSourcesProvider);
    final allSources = ref.watch(allSourceUrlsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: CyberTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "INTEL SOURCES",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CyberTheme.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage Active Feeds",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Select All / None
                TextButton(
                  onPressed: () {
                    final allUrls = allSources.toSet();
                    if (selectedSources.length == allSources.length) {
                      ref.read(selectedSourcesProvider.notifier).state = {};
                    } else {
                      ref.read(selectedSourcesProvider.notifier).state = allUrls;
                    }
                  },
                  child: Text(
                    selectedSources.length == allSources.length
                        ? "Deselect All"
                        : "Select All",
                    style: GoogleFonts.inter(color: CyberTheme.accent),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              itemCount: intelSources.length,
              itemBuilder: (context, index) {
                final category = intelSources.keys.elementAt(index);
                final urls = intelSources[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.4),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ...urls.map((url) {
                      final isSelected = selectedSources.contains(url);
                      // Since we don't have titles, extract domain as title
                      final domain = Uri.parse(url).host.replaceFirst('www.', '');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            final newSet = Set<String>.from(selectedSources);
                            if (isSelected) {
                              newSet.remove(url);
                            } else {
                              newSet.add(url);
                            }
                            ref.read(selectedSourcesProvider.notifier).state =
                                newSet;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: isSelected
                                ? CyberTheme.activeDecoration
                                : CyberTheme.glassDecoration.copyWith(
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                  ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? LucideIcons.checkCircle
                                      : LucideIcons.circle,
                                  size: 18,
                                  color: isSelected
                                      ? CyberTheme.accent
                                      : Colors.white.withOpacity(0.2),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    domain, // Use parsed domain as label
                                    style: GoogleFonts.inter(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.6),
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
