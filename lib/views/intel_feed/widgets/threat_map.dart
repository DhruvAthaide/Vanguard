import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/cyber_theme.dart';
import '../../../models/intel_item.dart';
import '../../../services/intel_service.dart';
import '../../../services/geo_service.dart';

class ThreatMapWidget extends StatefulWidget {
  final List<IntelItem> items;

  const ThreatMapWidget({super.key, required this.items});

  @override
  State<ThreatMapWidget> createState() => _ThreatMapWidgetState();
}

class _ThreatMapWidgetState extends State<ThreatMapWidget>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _generateMarkers();
  }

  @override
  void didUpdateWidget(covariant ThreatMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _generateMarkers();
    }
  }

  void _generateMarkers() {
    final newMarkers = <Marker>[];
    final Map<String, int> locationCounts = {};

    // 1. Entity Extraction & Grouping
     for (final item in widget.items) {
      // Check title and description for location
      final text = "${item.title} ${item.summary}";
      final latLng = GeoService.extractLocation(text);

      if (latLng != null) {
        final key = latLng.toString();
        locationCounts[key] = (locationCounts[key] ?? 0) + 1;
        
        // We only add one marker per location to avoid visual clutter,
        // but we could make it a "Cluster" in a future update.
         // For now, let's just add individual markers but offset them slightly if needed
         // actually, simpler to just map them.
      }
    }

    // Since we want to show individual items, let's iterate again
    // OR we can just visually map distinct locations.
    
    // Better approach: Iterate items, if match, add marker.
    // To avoid exact overlap, we can add a tiny random jitter or just stack them.
    // Stacking is fine.
    
    for (final item in widget.items) {
       final text = "${item.title} ${item.summary}";
       final latLng = GeoService.extractLocation(text);
       
       if (latLng != null) {
         final isCritical = text.toLowerCase().contains('critical') || 
                            text.toLowerCase().contains('exploit') ||
                            text.toLowerCase().contains('0-day');

         newMarkers.add(
           Marker(
             point: latLng,
             width: 40,
             height: 40,
             child: _PulsingMarker(
               isCritical: isCritical,
               count: 1, // Individual for now
               onTap: () {
                 _showIntelDetails(context, item);
               },
             ),
           ),
         );
       }
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  /*
    Dark Mode Matrix:
    - Invert colors (make white black, black white)
    - Apply a tint (make it cyan/greenish)
   */
  final _darkModeMatrix = <double>[
    // R  G  B  A  Const
    -1,  0,  0,  0, 255, // Red inverted
     0, -1,  0,  0, 255, // Green inverted
     0,  0, -1,  0, 255, // Blue inverted
     0,  0,  0,  1,   0, // Alpha unchanged
  ];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: LatLng(20.0, 0.0), // Center of world
        initialZoom: 2.0,
        minZoom: 2.0,
        maxZoom: 8.0,
        backgroundColor: Color(0xFF050510), // Deep space black
      ),
      children: [
        // 1. Dark Tile Layer
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFF0A1020), // Dark blue-ish tint
             BlendMode.saturation, // Desaturate first? No, let's try straight generic dark mode
          ),
          child: ColorFiltered(
             colorFilter: const ColorFilter.matrix([
                -0.8, 0, 0, 0, 255,
                0, -0.8, 0, 0, 255,
                0, 0, -0.8, 0, 255,
                0, 0, 0, 1, 0,
             ]), // Invert and Darken
             child: TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.dhruvathaide.vanguard',
             ),
          ),
        ),

        // 2. Scanlines / Grid overlay (Optional, adds cyber feel)
        // ...

        // 3. Markers
        MarkerLayer(markers: _markers),
      ],
    );
  }

  void _showIntelDetails(BuildContext context, IntelItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1525).withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CyberTheme.accent.withOpacity(0.3)),
          boxShadow: [
             BoxShadow(
               color: CyberTheme.accent.withOpacity(0.1),
               blurRadius: 20,
             )
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 children: [
                   Icon(LucideIcons.alertTriangle, color: CyberTheme.danger, size: 20),
                   const SizedBox(width: 10),
                   Expanded(
                     child: Text(
                       "THREAT DETECTED",
                       style: TextStyle(
                         color: CyberTheme.danger,
                         fontWeight: FontWeight.bold,
                         letterSpacing: 2,
                       ),
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 10),
               Text(
                 item.title,
                 style: const TextStyle(
                   color: Colors.white,
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 10),
                 Text(
                   item.summary,
                   maxLines: 4,
                   overflow: TextOverflow.ellipsis,
                   style: const TextStyle(
                     color: Colors.white70,
                     fontSize: 14,
                   ),
                 ),
               const SizedBox(height: 20),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: CyberTheme.accent,
                     foregroundColor: Colors.black,
                   ),
                   onPressed: () => Navigator.pop(context),
                   child: const Text("ACKNOWLEDGE"),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingMarker extends StatefulWidget {
  final bool isCritical;
  final VoidCallback onTap;
  final int count;

  const _PulsingMarker({
    required this.isCritical,
    required this.onTap,
    this.count = 1,
  });

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCritical ? CyberTheme.danger : CyberTheme.accent;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 40 * _controller.value,
                height: 40 * _controller.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(1 - _controller.value),
                    width: 2,
                  ),
                ),
              );
            },
          ),
          // Dot
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.6), blurRadius: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
