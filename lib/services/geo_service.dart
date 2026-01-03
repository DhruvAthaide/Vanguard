import 'package:latlong2/latlong.dart';

class GeoService {
  /// Extracts a location coordinate from text by matching country names.
  /// Returns the first match found, or null if no match.
  static LatLng? extractLocation(String text) {
    if (text.isEmpty) return null;
    final lowerText = text.toLowerCase();

    for (final entry in _countryCoordinates.entries) {
      if (lowerText.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return null;
  }

  // A selected list of major countries and tech hubs for threat mapping.
  // Coordinates are roughly central.
  static const Map<String, LatLng> _countryCoordinates = {
    'United States': LatLng(37.0902, -95.7129),
    'USA': LatLng(37.0902, -95.7129),
    'China': LatLng(35.8617, 104.1954),
    'Russia': LatLng(61.5240, 105.3188),
    'Germany': LatLng(51.1657, 10.4515),
    'United Kingdom': LatLng(55.3781, -3.4360),
    'UK ': LatLng(55.3781, -3.4360), // Space to avoid matching substring
    'Japan': LatLng(36.2048, 138.2529),
    'France': LatLng(46.2276, 2.2137),
    'India': LatLng(20.5937, 78.9629),
    'Brazil': LatLng(-14.2350, -51.9253),
    'Israel': LatLng(31.0461, 34.8516),
    'Iran': LatLng(32.4279, 53.6880),
    'North Korea': LatLng(40.3399, 127.5101),
    'South Korea': LatLng(35.9078, 127.7669),
    'Ukraine': LatLng(48.3794, 31.1656),
    'Canada': LatLng(56.1304, -106.3468),
    'Australia': LatLng(-25.2744, 133.7751),
    'Netherlands': LatLng(52.1326, 5.2913),
    'Sweden': LatLng(60.1282, 18.6435),
    'Switzerland': LatLng(46.8182, 8.2275),
    'Singapore': LatLng(1.3521, 103.8198),
    'Vietnam': LatLng(14.0583, 108.2772),
    'Taiwan': LatLng(23.6978, 120.9605),
  };
}
