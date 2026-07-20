import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/adaptive/adaptive_widgets.dart';
import '../../../core/network/news_api_exception.dart';
import 'article_card.dart';
import 'news_providers.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.extentAfter < 350) {
        context.read<SearchController>().loadMore();
      }
    });
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => context.read<SearchController>().search(value),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SearchController>();
    return AdaptivePageScaffold(
      title: 'Pesquisar',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AdaptiveSearchField(
              controller: _textController,
              onChanged: _onChanged,
            ),
          ),
          Expanded(child: _buildResult(controller)),
        ],
      ),
    );
  }

  Widget _buildResult(SearchController controller) {
    if (controller.status == LoadStatus.loading) {
      return const AdaptiveLoadingIndicator();
    }
    if (controller.status == LoadStatus.error) {
      return AdaptiveErrorView(
        message: controller.error is NewsApiException
            ? (controller.error! as NewsApiException).message
            : controller.error.toString(),
        onRetry: () => controller.search(_textController.text),
      );
    }
    final feed = controller.feed;
    if (_textController.text.trim().isEmpty) {
      return const _SearchEmpty(
        text: 'Digite um assunto para encontrar notícias.',
      );
    }
    if (feed.articles.isEmpty) {
      return const _SearchEmpty(text: 'Nenhum resultado encontrado.');
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: feed.articles.length + (feed.isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == feed.articles.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: AdaptiveLoadingIndicator(),
          );
        }
        return ArticleCard(article: feed.articles[index]);
      },
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
