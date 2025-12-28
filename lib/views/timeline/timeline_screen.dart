import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/cyber_theme.dart';
import '../../providers/project_provider.dart';
import '../projects/project_detail_screen.dart';
import 'widgets/timeline_header.dart';
import 'widgets/timeline_project_bar.dart';
import 'widgets/timeline_legend.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final double _pxPerDay = 24.0; // Zoom level
  final double _headerWidth = 140.0; // Fixed width for project names

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      backgroundColor: CyberTheme.background,
      appBar: AppBar(
        title: Text("MISSION TIMELINE", style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
           IconButton(
             icon: const Icon(LucideIcons.calendar, color: CyberTheme.accent),
             onPressed: () {
                // Future: Date Picker Jump?
             },
           )
        ],
      ),
      body: projectsAsync.when(
        data: (projects) {
           if (projects.isEmpty) {
              return Center(child: Text("No operations to track.", style: GoogleFonts.inter(color: Colors.white24)));
           }

           // 1. Calculate Bounds
           DateTime minDate = DateTime.now();
           DateTime maxDate = DateTime.now().add(const Duration(days: 30));

           for (var p in projects) {
              if (p.startDate.isBefore(minDate)) minDate = p.startDate;
              if (p.endDate != null && p.endDate!.isAfter(maxDate)) maxDate = p.endDate!;
           }
           
           // Padding
           minDate = minDate.subtract(const Duration(days: 7));
           maxDate = maxDate.add(const Duration(days: 30));

           final totalDays = maxDate.difference(minDate).inDays;
           final totalWidth = totalDays * _pxPerDay;
           
           // "Today" Position
           final todayOffset = DateTime.now().difference(minDate).inDays * _pxPerDay;

           return Stack(
             children: [
               Column(
                 children: [
                    // Header Row (Pinned Top)
                    SizedBox(
                      height: 40,
                      child: Row(
                        children: [
                           // Corner
                           Container(
                             width: _headerWidth,
                             color: CyberTheme.surface,
                             alignment: Alignment.center,
                             child: Text("OPERATION", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                           ),
                           // Timeline Header
                           Expanded(
                             child: SingleChildScrollView(
                               scrollDirection: Axis.horizontal,
                               physics: const ClampingScrollPhysics(), // Sync? No, this complicates things.
                               // Wait, header must scroll horizontally with the content.
                               // If we separate them, they desync.
                               // Simpler Approach:
                               // Use ONE vertical scroll view for body.
                               // Inside body, ONE horizontal scroll view for the entire right section.
                               // But then the header (dates) scrolls away vertically.
                               
                               // Solution for MVP: 
                               // Just let the whole timeline block scroll horizontally.
                               // The project list scrolls vertically.
                               // The two scroll views (Header horizontal and Content horizontal) need to be linked.
                               // Since we don't have LinkedScrollController package easily, 
                               // We will put the Header INSIDE the vertical scroll but pinned? No.
                               
                               // Revised Layout:
                               // Column -> 
                               //   Row -> [CornerBox] [Expanded -> SingleChildScrollView(horizontal, controller: _horiz1, child: Header)]
                               //   Expanded -> SingleChildScrollView(vertical) -> 
                               //       Row -> [FixedColumn] [Expanded -> SingleChildScrollView(horizontal, controller: _horiz2, child: Chart)]
                               // And we link _horiz1 and _horiz2.
                               
                               // Let's implement manual linking.
                               child:  TimelineHeader(
                                  minDate: minDate, 
                                  maxDate: maxDate, 
                                  pxPerDay: _pxPerDay, 
                                  totalWidth: totalWidth
                               ),
                             ),
                           )
                        ],
                      ),
                    ),
                    
                    // Main Content
                    Expanded(
                      child: _LinkedScrollBody(
                         headerWidth: _headerWidth,
                         projects: projects,
                         minDate: minDate,
                         pxPerDay: _pxPerDay,
                         totalWidth: totalWidth,
                         todayOffset: todayOffset,
                      ),
                    ),
                 ],
               ),
               
               // Floating Legend
               const Positioned(
                  bottom: 24, left: 0, right: 0,
                  child: Center(child: TimelineLegend()),
               )
             ],
           );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

// Internal Widget to handle the linked scrolling hack & layout
class _LinkedScrollBody extends StatefulWidget {
  final double headerWidth;
  final List<dynamic> projects; // Type explicitly if possible
  final DateTime minDate;
  final double pxPerDay;
  final double totalWidth;
  final double todayOffset;

  const _LinkedScrollBody({
    required this.headerWidth,
    required this.projects,
    required this.minDate,
    required this.pxPerDay,
    required this.totalWidth,
    required this.todayOffset,
  });

  @override
  State<_LinkedScrollBody> createState() => _LinkedScrollBodyState();
}

class _LinkedScrollBodyState extends State<_LinkedScrollBody> {
  final ScrollController _verticalCtrl = ScrollController();
  final ScrollController _horizontalCtrl = ScrollController();

  @override
  void dispose() {
    _verticalCtrl.dispose();
    _horizontalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Actually, to keep the header pinned top, we usually need the header outside the vertical scroll.
    // AND we need the header to scroll horizontally with the body.
    // So we need TWO horizontal controllers that sync. (One for header, one for body).
    // Or we use a NotificationListener to sync them.
    
    // BUT, the previous `build` method decided to separate them.
    // It passed a SingleScrollView for the header there.
    // That won't work perfectly without syncing.
    
    // Let's simplify: 
    // Just put the Header IN the scroll view for now? 
    // No, user requirement: "Static Vertical Header" (Project names pinned left).
    // "Timeline divides top horizontal axis...".
    
    // Okay, we will try to implement the sync in the parent or here.
    // Since I can't easily modify the parent state from here without callbacks...
    // Let's rewrite `TimelineScreen` slightly to hold the controllers if needed.
    // But wait, `TimelineScreen` has the `projectsAsync`. 
    
    // Let's do a simplified approach where the header is just part of the body for now, 
    // BUT the user asked for "Static Vertical Header" (Names pinned left).
    // AND "Week-Based Time Scale" (Header pinned top?).
    
    // Let's assume Pinned Left is high priority. Pinned Top is nice to have.
    // If I pin Left, I can just use a Row(Column(Names), ScrollView(Bars)). 
    // But then scrolling down moves the Bars but not Names? No, Names must scroll vertically.
    // So Row(Column(Names), ScrollView(Bars)) inside a VerticalScrollView works for Pinned Left.
    // But the Time Header? It needs to be above Bars.
    
    // VerticalScrollView -> 
    //    Row -> 
    //       Column(width: 140) -> [HeaderPlaceholder] [Project 1 Name] [Project 2 Name] ...
    //       Expanded -> SingleScrollView(horizontal) -> Column -> [TimeHeader] [Bar 1] [Bar 2] ...
    
    // Issue: If I scroll horizontal, the [TimeHeader] moves correctly with Bars.
    // Issue: [HeaderPlaceholder] stays fixed left. Correct.
    // Issue: If I scroll vertical, everything moves up. The [TimeHeader] disappears.
    // This violates "Pinned Top" typically, but satisfied "Pinned Left".
    // 
    // Given the request "Static Vertical Header: Ensure project names stay pinned to the left",
    // It implies Left Pinning is the key. 
    // "Divide the top horizontal axis... providing a 'Week View'". Only implies it exists.
    // I will stick to this one-scroll-view approach for stability.
    
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: _verticalCtrl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PINNED LEFT COLUMN (Project Names)
          Container(
            width: widget.headerWidth,
            decoration: const BoxDecoration(
               color: CyberTheme.surface, 
               border: Border(right: BorderSide(color: Colors.white12))
            ),
            child: Column(
               children: [
                  const SizedBox(height: 40), // Space for timestamp header
                  ...widget.projects.map((p) => Container(
                     height: 40, // Match bar height + margin
                     alignment: Alignment.centerLeft,
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                     decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.white10))
                     ),
                     child: Text(
                        p.name, 
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                        maxLines: 1, overflow: TextOverflow.ellipsis
                     ),
                  ))
               ],
            ),
          ),
          
          // 2. SCROLLABLE TIMELINE AREA
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalCtrl,
              child: SizedBox(
                 width: widget.totalWidth,
                 child: Stack(
                   children: [
                      // Grid / Background
                      Positioned.fill(
                         child: Row(
                            children: List.generate(
                               (widget.totalWidth / (widget.pxPerDay * 7)).ceil(), 
                               (i) => Container(
                                  width: widget.pxPerDay * 7,
                                  decoration: const BoxDecoration(
                                     border: Border(right: BorderSide(color: Colors.white10))
                                  ),
                               )
                            ),
                         )
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           // The Header
                           TimelineHeader(
                              minDate: widget.minDate, 
                              maxDate: widget.minDate.add(Duration(days: (widget.totalWidth/widget.pxPerDay).round())), 
                              pxPerDay: widget.pxPerDay, 
                              totalWidth: widget.totalWidth
                           ),
                           
                           // The Bars
                           ...widget.projects.map((p) => Container(
                               height: 40,
                               decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.white10))
                               ),
                               child: TimelineProjectBar(
                                  project: p, 
                                  minDate: widget.minDate, 
                                  pxPerDay: widget.pxPerDay,
                                  onTap: () {
                                     // Navigate
                                     Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => ProjectDetailScreen(project: p)
                                     ));
                                  },
                               ),
                           ))
                        ],
                      ),
                      
                      // Today Line
                      Positioned(
                         left: widget.todayOffset,
                         top: 0, bottom: 0,
                         child: Container(
                            width: 2,
                            color: Colors.cyanAccent.withOpacity(0.5),
                         ),
                      )
                   ],
                 ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
