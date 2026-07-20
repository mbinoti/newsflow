import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/adaptive/adaptive_widgets.dart';
import '../../../core/adaptive/platform.dart';
import '../../favorites/favorites_controller.dart';
import '../domain/article.dart';
import 'article_card.dart';

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({required this.article, super.key});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<FavoritesController, bool>(
      (controller) => controller.contains(article),
    );
    return AdaptivePageScaffold(
      title: 'Notícia',
      previousPageTitle: 'Voltar',
      actions: [
        AdaptiveIconButton(
          tooltip: isFavorite
              ? 'Remover dos favoritos'
              : 'Salvar nos favoritos',
          materialIcon: isFavorite ? Icons.bookmark : Icons.bookmark_outline,
          cupertinoIcon: isFavorite
              ? CupertinoIcons.bookmark_fill
              : CupertinoIcons.bookmark,
          onPressed: () => context.read<FavoritesController>().toggle(article),
        ),
        AdaptiveIconButton(
          tooltip: 'Compartilhar',
          materialIcon: Icons.share_outlined,
          cupertinoIcon: CupertinoIcons.share,
          onPressed: () => SharePlus.instance.share(
            ShareParams(text: '${article.title}\n${article.url}'),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          NewsImage(url: article.imageUrl, width: double.infinity, height: 260),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.sourceName.toUpperCase(),
                  style: TextStyle(
                    color: isCupertinoPlatform(context)
                        ? CupertinoColors.systemTeal
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  [
                    if (article.author?.trim().isNotEmpty == true)
                      article.author!,
                    DateFormat('dd/MM/yyyy, HH:mm').format(article.publishedAt),
                  ].join(' • '),
                  style: const TextStyle(color: CupertinoColors.systemGrey),
                ),
                if (article.description?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 24),
                  Text(
                    article.description!,
                    style: const TextStyle(fontSize: 19, height: 1.45),
                  ),
                ],
                if (article.content?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 18),
                  Text(
                    article.content!,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: AdaptiveButton(
                    label: 'Ler matéria completa',
                    icon: isCupertinoPlatform(context)
                        ? CupertinoIcons.arrow_up_right_square
                        : Icons.open_in_new,
                    onPressed: () => _openArticle(context),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'O conteúdo completo é disponibilizado pelo site da fonte.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = Uri.tryParse(article.url);
    final opened =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      showAdaptiveMessage(context, 'Não foi possível abrir esta matéria.');
    }
  }
}
