import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/adaptive/platform.dart';
import '../domain/article.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({required this.article, this.featured = false, super.key});

  final Article article;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final content = Semantics(
      button: true,
      label: 'Abrir notícia: ${article.title}',
      child: Padding(
        padding: EdgeInsets.all(featured ? 0 : 12),
        child: featured
            ? _Featured(article: article)
            : _Compact(article: article),
      ),
    );
    void onTap() => context.push('/article', extra: article);

    if (isCupertinoPlatform(context)) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemGroupedBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          child: content,
        ),
      );
    }
    return Card(
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

class _Compact extends StatelessWidget {
  const _Compact({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: NewsImage(url: article.imageUrl, width: 112, height: 92),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.sourceName.toUpperCase(),
              maxLines: 1,
              style: TextStyle(
                color: isCupertinoPlatform(context)
                    ? CupertinoColors.systemTeal
                    : Theme.of(context).colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd/MM/yyyy • HH:mm').format(article.publishedAt),
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Featured extends StatelessWidget {
  const _Featured({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        child: NewsImage(
          url: article.imageUrl,
          width: double.infinity,
          height: 210,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.sourceName.toUpperCase(),
              style: const TextStyle(
                color: CupertinoColors.systemTeal,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              article.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ],
  );
}

class NewsImage extends StatelessWidget {
  const NewsImage({
    required this.url,
    required this.width,
    required this.height,
    super.key,
  });

  final String? url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: isCupertinoPlatform(context)
          ? CupertinoColors.systemGrey5.resolveFrom(context)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        width: width,
        height: height,
        child: const Icon(
          CupertinoIcons.news,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
    if (url == null || Uri.tryParse(url!)?.hasAbsolutePath != true) {
      return fallback;
    }
    return CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
