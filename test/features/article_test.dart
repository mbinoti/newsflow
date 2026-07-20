import 'package:flutter_test/flutter_test.dart';
import 'package:newsflow/features/news/domain/article.dart';

void main() {
  test('converte resposta da NewsAPI e aceita campos opcionais nulos', () {
    final article = Article.fromJson({
      'source': {'id': null, 'name': 'Agência Teste'},
      'author': null,
      'title': 'Uma notícia',
      'description': null,
      'url': 'https://example.com/noticia',
      'urlToImage': null,
      'publishedAt': '2026-07-19T12:00:00Z',
      'content': 'Resumo disponível [+123 chars]',
    });

    expect(article.sourceName, 'Agência Teste');
    expect(article.author, isNull);
    expect(article.content, 'Resumo disponível');
    expect(article.publishedAt.isUtc, isFalse);
  });

  test('favorito mantém os dados após serialização local', () {
    final original = Article(
      sourceName: 'Fonte',
      title: 'Título',
      url: 'https://example.com/a',
      publishedAt: DateTime(2026, 7, 19, 10),
      description: 'Descrição',
    );

    final restored = Article.fromStoredJson(original.toStoredJson());
    expect(restored, original);
    expect(restored.title, original.title);
    expect(restored.description, original.description);
  });
}
