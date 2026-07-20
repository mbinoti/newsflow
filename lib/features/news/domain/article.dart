class Article {
  const Article({
    required this.sourceName,
    required this.title,
    required this.url,
    required this.publishedAt,
    this.sourceId,
    this.author,
    this.description,
    this.imageUrl,
    this.content,
  });

  final String? sourceId;
  final String sourceName;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? content;

  factory Article.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as Map<String, dynamic>? ?? const {};
    return Article(
      sourceId: source['id'] as String?,
      sourceName: (source['name'] as String?)?.trim().isNotEmpty == true
          ? source['name'] as String
          : 'Fonte desconhecida',
      author: json['author'] as String?,
      title: (json['title'] as String?) ?? 'Sem título',
      description: json['description'] as String?,
      url: (json['url'] as String?) ?? '',
      imageUrl: json['urlToImage'] as String?,
      publishedAt:
          DateTime.tryParse(
            (json['publishedAt'] as String?) ?? '',
          )?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      content: _cleanContent(json['content'] as String?),
    );
  }

  factory Article.fromStoredJson(Map<String, dynamic> json) => Article(
    sourceId: json['sourceId'] as String?,
    sourceName: json['sourceName'] as String? ?? 'Fonte desconhecida',
    author: json['author'] as String?,
    title: json['title'] as String? ?? 'Sem título',
    description: json['description'] as String?,
    url: json['url'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
    publishedAt:
        DateTime.tryParse(json['publishedAt'] as String? ?? '')?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0),
    content: json['content'] as String?,
  );

  Map<String, dynamic> toStoredJson() => {
    'sourceId': sourceId,
    'sourceName': sourceName,
    'author': author,
    'title': title,
    'description': description,
    'url': url,
    'imageUrl': imageUrl,
    'publishedAt': publishedAt.toUtc().toIso8601String(),
    'content': content,
  };

  static String? _cleanContent(String? value) {
    if (value == null || value == '[Removed]') return null;
    return value.replaceFirst(RegExp(r'\s*\[\+\d+ chars\]\s*$'), '').trim();
  }

  @override
  bool operator ==(Object other) => other is Article && other.url == url;

  @override
  int get hashCode => url.hashCode;
}

class NewsPage {
  const NewsPage({required this.articles, required this.totalResults});

  final List<Article> articles;
  final int totalResults;
}

class NewsFeed {
  const NewsFeed({
    this.articles = const [],
    this.totalResults = 0,
    this.page = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  final List<Article> articles;
  final int totalResults;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;

  NewsFeed copyWith({
    List<Article>? articles,
    int? totalResults,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
  }) => NewsFeed(
    articles: articles ?? this.articles,
    totalResults: totalResults ?? this.totalResults,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}
