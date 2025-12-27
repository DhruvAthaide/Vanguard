import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';
import '../models/intel_item.dart';
import 'intel_sources.dart';

class IntelService {
  Future<List<IntelItem>> fetchAllIntel() async {
    final List<IntelItem> items = [];

    for (final entry in intelSources.entries) {
      final category = entry.key;
      final feeds = entry.value;

      for (final url in feeds) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode != 200) continue;

          final feed = RssFeed.parse(response.body);

          for (final item in feed.items ?? []) {
            items.add(
              IntelItem(
                title: item.title ?? "Untitled",
                summary: item.description ?? "",
                category: category,
                source: feed.title ?? "Unknown Source",
                url: item.link ?? "",
                publishedAt: item.pubDate ?? DateTime.now(),
              ),
            );
          }
        } catch (_) {
          // Fail silently — intel feeds must be resilient
        }
      }
    }

    items.sort(
          (a, b) => b.publishedAt.compareTo(a.publishedAt),
    );

    return items;
  }
}
