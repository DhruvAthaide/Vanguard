import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TimelineHeader extends StatelessWidget {
  final DateTime minDate;
  final DateTime maxDate;
  final double pxPerDay;
  final double totalWidth;

  const TimelineHeader({
    super.key,
    required this.minDate,
    required this.maxDate,
    required this.pxPerDay,
    required this.totalWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Generate Week Markers
    // We iterate by 7 days from minDate
    final weeks = <Widget>[];
    
    // Safety check
    if (totalWidth <= 0 || pxPerDay <= 0) return const SizedBox();

    DateTime cursor = minDate;
    double currentX = 0;
    
    // Buffer
    final safeMax = maxDate.add(const Duration(days: 30));

    while (cursor.isBefore(safeMax)) {
      final dateStr = DateFormat('MMM dd').format(cursor);
      final nextWeek = cursor.add(const Duration(days: 7));
      
      weeks.add(
        Positioned(
          left: currentX,
          top: 0,
          child: Container(
            width: pxPerDay * 7,
            height: 40,
            decoration: const BoxDecoration(
               border: Border(left: BorderSide(color: Colors.white10))
            ),
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(dateStr, style: GoogleFonts.inter(fontSize: 10, color: Colors.white54)),
          ),
        )
      );
      
      cursor = nextWeek;
      currentX += pxPerDay * 7;
    }

    return Container(
      height: 40,
      width: totalWidth < currentX ? currentX : totalWidth, // Ensure wrapping
      color: Colors.black26,
      child: Stack(
        children: weeks,
      ),
    );
  }
}
