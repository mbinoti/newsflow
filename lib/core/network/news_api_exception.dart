import 'package:dio/dio.dart';

class NewsApiException implements Exception {
  const NewsApiException(this.message);

  final String message;

  factory NewsApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final code = data is Map<String, dynamic> ? data['code'] as String? : null;

    if (status == 401 || code == 'apiKeyInvalid') {
      return const NewsApiException(
        'A chave da NewsAPI é inválida ou não foi informada.',
      );
    }
    if (status == 429 || code == 'rateLimited') {
      return const NewsApiException(
        'O limite de consultas foi atingido. Tente mais tarde.',
      );
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NewsApiException(
        'A conexão demorou demais. Tente novamente.',
      );
    }
    if (error.type == DioExceptionType.connectionError) {
      return const NewsApiException('Sem conexão com a internet.');
    }
    return const NewsApiException('Não foi possível carregar as notícias.');
  }

  @override
  String toString() => message;
}
