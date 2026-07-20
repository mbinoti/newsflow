import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newsflow/core/network/news_api_exception.dart';
import 'package:newsflow/features/news/data/news_api_client.dart';

void main() {
  test('impede consulta quando a chave da NewsAPI não foi informada', () async {
    final client = NewsApiClient(Dio(), apiKey: '');

    expect(
      () => client.topHeadlines(),
      throwsA(
        isA<NewsApiException>().having(
          (error) => error.message,
          'message',
          contains('api_keys.dart'),
        ),
      ),
    );
  });
}
