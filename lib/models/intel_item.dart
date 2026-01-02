class IntelItem {
  final String title;
  final String summary;
  final String category;
  final String source;
  final String url;
  final String feedUrl; // The RSS feed this item came from
  final DateTime publishedAt;

  IntelItem({
    required this.title,
    required this.summary,
    required this.category,
    required this.source,
    required this.url,
    required this.feedUrl,
    required this.publishedAt,
  });
}
