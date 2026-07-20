import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/adaptive/adaptive_widgets.dart';
import '../../core/adaptive/platform.dart';
import '../news/presentation/article_card.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FavoritesController>();
    final favorites = controller.items;
    return AdaptivePageScaffold(
      title: 'Favoritos',
      actions: [
        if (favorites.isNotEmpty)
          AdaptiveIconButton(
            tooltip: 'Remover todos',
            materialIcon: Icons.delete_outline,
            cupertinoIcon: CupertinoIcons.trash,
            onPressed: () async {
              final confirmed = await showAdaptiveConfirmation(
                context,
                title: 'Remover favoritos?',
                message:
                    'Todas as notícias salvas serão removidas deste aparelho.',
                confirmLabel: 'Remover',
                destructive: true,
              );
              if (confirmed) await controller.clear();
            },
          ),
      ],
      body: favorites.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.bookmark, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'As notícias que você salvar aparecerão aqui e ficarão disponíveis offline.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final article = favorites[index];
                return Dismissible(
                  key: ValueKey(article.url),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => showAdaptiveConfirmation(
                    context,
                    title: 'Remover favorito?',
                    message: article.title,
                    confirmLabel: 'Remover',
                    destructive: true,
                  ),
                  onDismissed: (_) {
                    controller.toggle(article);
                    if (!isCupertinoPlatform(context)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Favorito removido.'),
                          action: SnackBarAction(
                            label: 'Desfazer',
                            onPressed: () => controller.toggle(article),
                          ),
                        ),
                      );
                    }
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: CupertinoColors.systemRed,
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: CupertinoColors.white,
                    ),
                  ),
                  child: ArticleCard(article: article),
                );
              },
            ),
    );
  }
}
