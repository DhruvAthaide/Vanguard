import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/intel_item.dart';
import '../services/intel_service.dart';

final intelServiceProvider =
Provider((ref) => IntelService());

final selectedCategoryProvider =
StateProvider<String>((ref) => "All");

final intelFeedProvider =
FutureProvider<List<IntelItem>>((ref) async {
  final service = ref.watch(intelServiceProvider);
  return service.fetchAllIntel();
});

final filteredIntelProvider =
Provider<List<IntelItem>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final intelAsync = ref.watch(intelFeedProvider);

  return intelAsync.maybeWhen(
    data: (items) {
      if (category == "All") return items;
      return items
          .where((i) => i.category == category)
          .toList();
    },
    orElse: () => [],
  );
});
