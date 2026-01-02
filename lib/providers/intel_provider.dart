import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/intel_item.dart';
import '../services/intel_service.dart';
import '../services/intel_sources.dart';

final intelServiceProvider =
Provider((ref) => IntelService());

final selectedCategoryProvider =
StateProvider<String>((ref) => "All");

// Initialize with all sources active by default
final selectedSourcesProvider =
StateProvider<Set<String>>((ref) {
  final allSources = <String>{};
  for (var list in intelSources.values) {
    allSources.addAll(list); 
  }
  return allSources;
}); 

// Helper to get all source URLs
final allSourceUrlsProvider = Provider<List<String>>((ref) {
  return intelSources.values.expand((element) => element).toList();
});

final intelFeedProvider =
FutureProvider<List<IntelItem>>((ref) async {
  final service = ref.watch(intelServiceProvider);
  return service.fetchAllIntel();
});

final filteredIntelProvider =
Provider<List<IntelItem>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final intelAsync = ref.watch(intelFeedProvider);
  final selectedSources = ref.watch(selectedSourcesProvider);

  return intelAsync.maybeWhen(
    data: (items) {
      var filtered = items;

      // Filter by Category
      if (category != "All") {
        filtered = filtered.where((i) => i.category == category).toList();
      }

      // Filter by Source
      if (selectedSources.isNotEmpty) {
        filtered = filtered.where((item) => selectedSources.contains(item.feedUrl)).toList();
      } else {
        // If nothing selected, show nothing
        return <IntelItem>[];
      }
      
      return filtered;
    },
    orElse: () => [],
  );
});
