import 'package:flutter/foundation.dart';

import '../data/news_repository.dart';
import '../domain/article.dart';

enum LoadStatus { initial, loading, success, error }

class HeadlinesController extends ChangeNotifier {
  HeadlinesController(this._repository, {required this.country});

  final NewsRepository _repository;
  String country;
  String category = 'general';
  LoadStatus status = LoadStatus.initial;
  NewsFeed feed = const NewsFeed();
  Object? error;

  Future<NewsFeed> _load(int page) async {
    final result = await _repository.headlines(
      country: country,
      category: category,
      page: page,
    );
    return NewsFeed(
      articles: _unique(result.articles),
      totalResults: result.totalResults,
      page: page,
      hasMore: result.articles.length == 20,
    );
  }

  Future<void> refresh() async {
    status = LoadStatus.loading;
    error = null;
    notifyListeners();
    try {
      feed = await _load(1);
      status = LoadStatus.success;
    } catch (caught) {
      error = caught;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> setCategory(String value) async {
    if (category == value) return;
    category = value;
    await refresh();
  }

  Future<void> setCountry(String value) async {
    if (country == value) return;
    country = value;
    await refresh();
  }

  Future<void> loadMore() async {
    if (!feed.hasMore || feed.isLoadingMore || status != LoadStatus.success) {
      return;
    }
    feed = feed.copyWith(isLoadingMore: true);
    notifyListeners();
    try {
      final next = await _load(feed.page + 1);
      feed = next.copyWith(
        articles: _unique([...feed.articles, ...next.articles]),
        isLoadingMore: false,
      );
    } catch (_) {
      feed = feed.copyWith(isLoadingMore: false);
    }
    notifyListeners();
  }

  List<Article> _unique(List<Article> articles) =>
      {for (final article in articles) article.url: article}.values.toList();
}

class SearchController extends ChangeNotifier {
  SearchController(this._repository);

  final NewsRepository _repository;
  String query = '';
  int _request = 0;
  LoadStatus status = LoadStatus.initial;
  NewsFeed feed = const NewsFeed(hasMore: false);
  Object? error;

  Future<void> search(String value) async {
    final normalized = value.trim();
    query = normalized;
    final request = ++_request;
    error = null;
    if (normalized.isEmpty) {
      feed = const NewsFeed(hasMore: false);
      status = LoadStatus.initial;
      notifyListeners();
      return;
    }
    status = LoadStatus.loading;
    notifyListeners();
    try {
      final result = await _repository.search(query: normalized, page: 1);
      if (request != _request) return;
      feed = NewsFeed(
        articles: result.articles,
        totalResults: result.totalResults,
        hasMore: result.articles.length == 20,
      );
      status = LoadStatus.success;
    } catch (caught) {
      if (request != _request) return;
      error = caught;
      status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (query.isEmpty ||
        !feed.hasMore ||
        feed.isLoadingMore ||
        status != LoadStatus.success) {
      return;
    }
    feed = feed.copyWith(isLoadingMore: true);
    notifyListeners();
    try {
      final result = await _repository.search(
        query: query,
        page: feed.page + 1,
      );
      final combined = {
        for (final article in [...feed.articles, ...result.articles])
          article.url: article,
      }.values.toList();
      feed = NewsFeed(
        articles: combined,
        totalResults: result.totalResults,
        page: feed.page + 1,
        hasMore: result.articles.length == 20,
      );
    } catch (_) {
      feed = feed.copyWith(isLoadingMore: false);
    }
    notifyListeners();
  }
}
