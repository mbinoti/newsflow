import 'package:flutter/widgets.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'features/favorites/favorites_controller.dart';
import 'features/news/data/news_api_client.dart';
import 'features/news/data/news_repository.dart';
import 'features/news/presentation/news_providers.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: preferences),
        Provider<Dio>(
          create: (_) => Dio(
            BaseOptions(
              baseUrl: 'https://newsapi.org/v2',
              connectTimeout: const Duration(seconds: 12),
              receiveTimeout: const Duration(seconds: 15),
            ),
          ),
          dispose: (_, dio) => dio.close(),
        ),
        ProxyProvider<Dio, NewsApiClient>(
          update: (_, dio, _) => NewsApiClient(dio),
        ),
        ProxyProvider<NewsApiClient, NewsRepository>(
          update: (_, client, _) => RemoteNewsRepository(client),
        ),
        ChangeNotifierProvider(create: (_) => SettingsController(preferences)),
        ChangeNotifierProvider(create: (_) => FavoritesController(preferences)),
        ChangeNotifierProvider(
          create: (context) => HeadlinesController(
            context.read<NewsRepository>(),
            country: preferences.getString('country') ?? 'br',
          )..refresh(),
        ),
        ChangeNotifierProvider(
          create: (context) => SearchController(context.read<NewsRepository>()),
        ),
      ],
      child: const NewsFlowApp(),
    ),
  );
}
