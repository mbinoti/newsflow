import '../domain/article.dart';
import 'news_api_client.dart';

abstract interface class NewsRepository {
  Future<NewsPage> headlines({
    required String country,
    required String category,
    required int page,
  });

  Future<NewsPage> search({required String query, required int page});
}

class RemoteNewsRepository implements NewsRepository {
  const RemoteNewsRepository(this._client);

  final NewsApiClient _client;

  @override
  Future<NewsPage> headlines({
    required String country,
    required String category,
    required int page,
  }) async {
    final headlines = await _client.topHeadlines(
      country: country,
      category: category,
      page: page,
    );
    if (headlines.articles.isNotEmpty) return headlines;

    final fallback = _fallbackFor(country, category);
    return _client.everything(
      query: fallback.query,
      language: fallback.language,
      page: page,
    );
  }

  @override
  Future<NewsPage> search({required String query, required int page}) =>
      _client.everything(query: query, page: page);

  ({String query, String language}) _fallbackFor(
    String country,
    String category,
  ) {
    final language = switch (country) {
      'br' || 'pt' => 'pt',
      _ => 'en',
    };
    final countryTerm = switch (country) {
      'br' => 'Brasil',
      'pt' => 'Portugal',
      'us' => '"United States"',
      'gb' => '"United Kingdom"',
      _ => country,
    };
    final categoryTerm = switch ((language, category)) {
      (_, 'general') => null,
      ('pt', 'business') => 'economia OR negócios',
      ('pt', 'entertainment') => 'entretenimento OR cultura',
      ('pt', 'health') => 'saúde',
      ('pt', 'science') => 'ciência',
      ('pt', 'sports') => 'esportes OR futebol',
      ('pt', 'technology') => 'tecnologia',
      (_, 'business') => 'business OR economy',
      (_, 'entertainment') => 'entertainment OR culture',
      (_, 'health') => 'health',
      (_, 'science') => 'science',
      (_, 'sports') => 'sports',
      (_, 'technology') => 'technology',
      _ => category,
    };
    final query = categoryTerm == null
        ? countryTerm
        : '$countryTerm AND ($categoryTerm)';
    return (query: query, language: language);
  }
}
