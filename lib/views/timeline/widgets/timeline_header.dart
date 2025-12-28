import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../core/theme/cyber_theme.dart';

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
    if (totalWidth <= 0 || pxPerDay <= 0) return const SizedBox();

    final weeks = <Widget>[];
    DateTime cursor = minDate;
    double currentX = 0;
    final safeMax = maxDate.add(const Duration(days: 30));

    while (cursor.isBefore(safeMax)) {
      final dateStr = DateFormat('MMM dd').format(cursor);
      final weekOfYear = _getWeekOfYear(cursor);

      weeks.add(
        Positioned(
          left: currentX,
          top: 0,
          child: Container(
            width: pxPerDay * 7,
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'WEEK $weekOfYear',
                  style: GoogleFonts.robotoMono(
                    fontSize: 9,
                    color: CyberTheme.accent.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      cursor = cursor.add(const Duration(days: 7));
      currentX += pxPerDay * 7;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          width: totalWidth < currentX ? currentX : totalWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.03),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
          child: Stack(
            children: weeks,
          ),
        ),
      ),
    );
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(firstDayOfYear).inDays;
    return (daysSinceStart / 7).ceil() + 1;
  }
}