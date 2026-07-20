import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/adaptive/platform.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/news/domain/article.dart';
import '../features/news/presentation/article_details_screen.dart';
import '../features/news/presentation/home_screen.dart';
import '../features/news/presentation/search_screen.dart';
import '../features/settings/settings_screen.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdaptiveNavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (_, _) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (_, _) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/article',
      builder: (context, state) {
        final article = state.extra;
        if (article is! Article) {
          return const HomeScreen();
        }
        return ArticleDetailsScreen(article: article);
      },
    ),
  ],
);

class AdaptiveNavigationShell extends StatelessWidget {
  const AdaptiveNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(context)) {
      return CupertinoPageScaffold(
        child: Column(
          children: [
            Expanded(child: navigationShell),
            CupertinoTabBar(
              currentIndex: navigationShell.currentIndex,
              onTap: _select,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.house),
                  activeIcon: Icon(CupertinoIcons.house_fill),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.search),
                  label: 'Pesquisa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.bookmark),
                  activeIcon: Icon(CupertinoIcons.bookmark_fill),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.settings),
                  activeIcon: Icon(CupertinoIcons.settings_solid),
                  label: 'Ajustes',
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Pesquisa'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Favoritos',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
