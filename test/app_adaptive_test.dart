import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_test/flutter_test.dart';
import 'package:newsflow/app/app.dart';
import 'package:newsflow/features/favorites/favorites_controller.dart';
import 'package:newsflow/features/news/data/news_repository.dart';
import 'package:newsflow/features/news/domain/article.dart';
import 'package:newsflow/features/news/presentation/news_providers.dart';
import 'package:newsflow/features/settings/settings_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNewsRepository implements NewsRepository {
  @override
  Future<NewsPage> headlines({
    required String country,
    required String category,
    required int page,
  }) async => const NewsPage(articles: [], totalResults: 0);

  @override
  Future<NewsPage> search({required String query, required int page}) async =>
      const NewsPage(articles: [], totalResults: 0);
}

void main() {
  Future<Widget> appFor(TargetPlatform platform) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = _FakeNewsRepository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController(preferences)),
        ChangeNotifierProvider(create: (_) => FavoritesController(preferences)),
        ChangeNotifierProvider(
          create: (_) =>
              HeadlinesController(repository, country: 'br')..refresh(),
        ),
        ChangeNotifierProvider(create: (_) => SearchController(repository)),
      ],
      child: NewsFlowApp(platformOverride: platform),
    );
  }

  testWidgets('usa CupertinoApp, página e abas Cupertino no iOS', (
    tester,
  ) async {
    await tester.pumpWidget(await appFor(TargetPlatform.iOS));
    await tester.pump();

    expect(find.byType(CupertinoApp), findsOneWidget);
    expect(find.byType(CupertinoTabScaffold), findsOneWidget);
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(find.byType(CupertinoPageScaffold), findsWidgets);
    expect(find.byType(MaterialApp), findsNothing);
  });

  testWidgets('usa MaterialApp, Scaffold e NavigationBar no Android', (
    tester,
  ) async {
    await tester.pumpWidget(await appFor(TargetPlatform.android));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(CupertinoTabScaffold), findsNothing);
  });
}
