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

class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AdaptiveNavigationShell> createState() =>
      _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  late final CupertinoTabController _tabController = CupertinoTabController(
    initialIndex: widget.navigationShell.currentIndex,
  );

  void _select(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant AdaptiveNavigationShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabController.index != widget.navigationShell.currentIndex) {
      _tabController.index = widget.navigationShell.currentIndex;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(context)) {
      return CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
          currentIndex: widget.navigationShell.currentIndex,
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
        tabBuilder: (_, _) => widget.navigationShell,
      );
    }
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
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
