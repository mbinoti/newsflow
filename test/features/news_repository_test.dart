import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newsflow/features/news/data/news_api_client.dart';
import 'package:newsflow/features/news/data/news_repository.dart';
import 'package:newsflow/features/news/domain/article.dart';

void main() {
  group('RemoteNewsRepository.headlines', () {
    test('mantém as manchetes quando a API retorna artigos', () async {
      final article = _article('https://example.com/manchete');
      final client = _FakeNewsApiClient(
        headlines: NewsPage(articles: [article], totalResults: 1),
      );
      final repository = RemoteNewsRepository(client);

      final result = await repository.headlines(
        country: 'br',
        category: 'general',
        page: 1,
      );

      expect(result.articles, [article]);
      expect(client.everythingCalls, isEmpty);
    });

    test(
      'busca notícias em português quando manchetes do Brasil vêm vazias',
      () async {
        final fallbackArticle = _article('https://example.com/brasil');
        final client = _FakeNewsApiClient(
          headlines: const NewsPage(articles: [], totalResults: 0),
          fallback: NewsPage(articles: [fallbackArticle], totalResults: 100),
        );
        final repository = RemoteNewsRepository(client);

        final result = await repository.headlines(
          country: 'br',
          category: 'technology',
          page: 2,
        );

        expect(result.articles, [fallbackArticle]);
        expect(client.everythingCalls.single, (
          query: 'Brasil AND (tecnologia)',
          language: 'pt',
          page: 2,
        ));
      },
    );
  });
}

class _FakeNewsApiClient extends NewsApiClient {
  _FakeNewsApiClient({required this.headlines, this.fallback})
    : super(Dio(), apiKey: 'teste');

  final NewsPage headlines;
  final NewsPage? fallback;
  final List<({String query, String language, int page})> everythingCalls = [];

  @override
  Future<NewsPage> topHeadlines({
    String country = 'br',
    String? category,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async => headlines;

  @override
  Future<NewsPage> everything({
    required String query,
    String language = 'pt',
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = 20,
  }) async {
    everythingCalls.add((query: query, language: language, page: page));
    return fallback ?? const NewsPage(articles: [], totalResults: 0);
  }
}

Article _article(String url) => Article(
  sourceName: 'Fonte',
  title: 'Título',
  url: url,
  publishedAt: DateTime(2026),
);
