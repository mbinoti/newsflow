import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../news/domain/article.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._preferences) {
    final raw = _preferences.getStringList(_storageKey);
    _items = raw == null
        ? []
        : raw
              .map((value) => jsonDecode(value))
              .whereType<Map<String, dynamic>>()
              .map(Article.fromStoredJson)
              .toList();
  }

  static const _storageKey = 'favoriteArticles';
  final SharedPreferences _preferences;
  late List<Article> _items;

  List<Article> get items => List.unmodifiable(_items);

  bool contains(Article article) =>
      _items.any((item) => item.url == article.url);

  Future<void> toggle(Article article) async {
    _items = contains(article)
        ? _items.where((item) => item.url != article.url).toList()
        : [article, ..._items];
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _items = [];
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() => _preferences.setStringList(
    _storageKey,
    _items.map((article) => jsonEncode(article.toStoredJson())).toList(),
  );
}
