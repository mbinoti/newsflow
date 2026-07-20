import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/adaptive/adaptive_widgets.dart';
import '../../../core/adaptive/platform.dart';
import '../../../core/network/news_api_exception.dart';
import '../domain/article.dart';
import 'article_card.dart';
import 'news_providers.dart';

const categories = <String, String>{
  'general': 'Geral',
  'business': 'Negócios',
  'entertainment': 'Entretenimento',
  'health': 'Saúde',
  'science': 'Ciência',
  'sports': 'Esportes',
  'technology': 'Tecnologia',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 400) {
        context.read<HeadlinesController>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HeadlinesController>();
    return AdaptivePageScaffold(
      title: 'NewsFlow',
      body: switch (controller.status) {
        LoadStatus.initial ||
        LoadStatus.loading => const AdaptiveLoadingIndicator(),
        LoadStatus.error => AdaptiveErrorView(
          message: controller.error is NewsApiException
              ? (controller.error! as NewsApiException).message
              : controller.error.toString(),
          onRetry: controller.refresh,
        ),
        LoadStatus.success => _buildFeed(context, controller.feed, controller),
      },
    );
  }

  Widget _buildFeed(
    BuildContext context,
    NewsFeed data,
    HeadlinesController controller,
  ) {
    final children = <Widget>[
      SizedBox(
        height: 54,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final entry = categories.entries.elementAt(index);
            final selected = controller.category == entry.key;
            if (isCupertinoPlatform(context)) {
              return CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                color: selected
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemGrey5.resolveFrom(context),
                onPressed: () => controller.setCategory(entry.key),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected
                        ? CupertinoColors.white
                        : CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              );
            }
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (_) => controller.setCategory(entry.key),
            );
          },
        ),
      ),
      if (data.articles.isEmpty)
        const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text('Nenhuma notícia encontrada.')),
        )
      else ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ArticleCard(article: data.articles.first, featured: true),
        ),
        ...data.articles
            .skip(1)
            .map(
              (article) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: ArticleCard(article: article),
              ),
            ),
      ],
      if (data.isLoadingMore)
        const Padding(
          padding: EdgeInsets.all(24),
          child: AdaptiveLoadingIndicator(),
        ),
      const SizedBox(height: 24),
    ];

    if (isCupertinoPlatform(context)) {
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: controller.refresh),
          SliverList(delegate: SliverChildListDelegate(children)),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(controller: _scrollController, children: children),
    );
  }
}
