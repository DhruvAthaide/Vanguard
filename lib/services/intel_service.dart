import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';
import '../models/intel_item.dart';
import 'intel_sources.dart';

class IntelService {
  /// Streams IntelItems as they are fetched and parsed.
  /// Uses a broadcast stream so multiple listeners can attach if needed.
  Stream<List<IntelItem>> streamIntel() async* {
    final List<IntelItem> accumulatedItems = [];
    final List<Future<void>> fetchFutures = [];

    // Flatten all sources into a list of (Category, URL) tuples
    final List<MapEntry<String, String>> allFeeds = [];
    for (final entry in intelSources.entries) {
      for (final url in entry.value) {
        allFeeds.add(MapEntry(entry.key, url));
      }
    }

    // Process feeds in batches to avoid overwhelming the network or CPU
    // (Optional: simply firing all at once is okay for < 50 feeds, but let's be safe)
    // For now, we'll fire them all but await them individually to yield results as they come.

    final controller = StreamController<List<IntelItem>>();

    for (final feed in allFeeds) {
      final category = feed.key;
      final url = feed.value;

      final future = _fetchAndParseFeed(url, category).then((items) {
        if (items.isNotEmpty) {
          accumulatedItems.addAll(items);
          // Sort continuously so the UI always shows the latest on top
          accumulatedItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
          controller.add(List.from(accumulatedItems));
        }
      }).catchError((e) {
        log('Error processing feed: $url', error: e);
      });

      fetchFutures.add(future);
    }

    // Wait for all to complete, but don't block the stream
    Future.wait(fetchFutures).then((_) {
      controller.close();
    });

    yield* controller.stream;
  }

  Future<List<IntelItem>> _fetchAndParseFeed(String url, String category) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        log('Failed to load feed: $url, Status: ${response.statusCode}');
        return [];
      }

      // Offload parsing to a background isolate
      return await compute(_parseFeedIsolate, _ParseArgs(response.body, url, category));
    } catch (e) {
      log('Error fetching feed: $url', error: e);
      return [];
    }
  }
}

// Arguments for the isolate
class _ParseArgs {
  final String responseBody;
  final String url;
  final String category;

  _ParseArgs(this.responseBody, this.url, this.category);
}

// Top-level function for isolate
List<IntelItem> _parseFeedIsolate(_ParseArgs args) {
  final items = <IntelItem>[];
  bool parsed = false;

  // Try RSS
  try {
    final feed = RssFeed.parse(args.responseBody);
    parsed = true;
    for (final item in feed.items ?? []) {
      items.add(
        IntelItem(
          title: item.title ?? "Untitled",
          summary: item.description ?? item.content?.value ?? "",
          category: args.category,
          source: feed.title ?? "Unknown Source",
          url: item.link ?? "",
          feedUrl: args.url,
          publishedAt: item.pubDate ?? DateTime.now(),
        ),
      );
    }
  } catch (_) {}

  if (parsed) return items;

  // Try Atom
  try {
    final feed = AtomFeed.parse(args.responseBody);
    for (final item in feed.items ?? []) {
      String urlLink = "";
      if (item.links != null && item.links!.isNotEmpty) {
        urlLink = item.links!
            .firstWhere(
              (l) => l.rel == "alternate",
              orElse: () => item.links!.first,
            )
            .href ??
            "";
      }

      items.add(
        IntelItem(
          title: item.title ?? "Untitled",
          summary: item.summary ?? item.content ?? "",
          category: args.category,
          source: feed.title ?? "Unknown Source",
          url: urlLink,
          feedUrl: args.url,
          publishedAt: item.updated ?? item.published ?? DateTime.now(),
        ),
      );
    }
  } catch (e) {
    // Log in isolate might not show up clearly, but we catch it
  }

  return items;
}
