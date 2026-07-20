import 'package:dio/dio.dart';

import '../../../core/config/api_keys.dart';
import '../../../core/network/news_api_exception.dart';
import '../domain/article.dart';

class NewsApiClient {
  NewsApiClient(this._dio, {String? apiKey})
    : _apiKey = apiKey ?? ApiKeys.newsApiKey;

  final Dio _dio;
  final String _apiKey;

  Future<NewsPage> topHeadlines({
    String country = 'br',
    String? category,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) => _get(
    '/top-headlines',
    query: {
      'country': country,
      if (category != null && category != 'general') 'category': category,
      if (query != null && query.isNotEmpty) 'q': query,
      'page': page,
      'pageSize': pageSize,
    },
  );

  Future<NewsPage> everything({
    required String query,
    String language = 'pt',
    String sortBy = 'publishedAt',
    int page = 1,
    int pageSize = 20,
  }) => _get(
    '/everything',
    query: {
      'q': query,
      'language': language,
      'sortBy': sortBy,
      'page': page,
      'pageSize': pageSize,
    },
  );

  Future<NewsPage> _get(
    String path, {
    required Map<String, dynamic> query,
  }) async {
    if (_apiKey.isEmpty) {
      throw const NewsApiException(
        'Informe a chave da NewsAPI em lib/core/config/api_keys.dart.',
      );
    }
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
        options: Options(headers: {'X-Api-Key': _apiKey}),
      );
      final data = response.data;
      if (data == null || data['status'] != 'ok') {
        throw const NewsApiException(
          'A NewsAPI retornou uma resposta inválida.',
        );
      }
      final rawArticles = data['articles'] as List<dynamic>? ?? const [];
      final articles = rawArticles
          .whereType<Map<String, dynamic>>()
          .map(Article.fromJson)
          .where((article) => article.url.isNotEmpty)
          .toList();
      return NewsPage(
        articles: articles,
        totalResults: data['totalResults'] as int? ?? articles.length,
      );
    } on DioException catch (error) {
      throw NewsApiException.fromDio(error);
    }
  }
}
