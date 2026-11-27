import 'package:dio/dio.dart';

/// Tudo o que pode dar errado ao falar com a API, já traduzido do HTTP.
sealed class Failure implements Exception {
  const new();
}

/// Regra de negócio ou erro da API, com o `code` estável do ProblemDetails
/// (por exemplo `insufficient_funds`). O app decide a mensagem pelo código.
final class ApiFailure extends Failure {
  const new({required this.code, required this.message, required this.status});

  final String code;
  final String message;
  final int status;
}

/// Dados de entrada recusados (`400`), com os erros por campo.
final class ValidationFailure extends Failure {
  const new(this.errors);

  final Map<String, List<String>> errors;
}

/// Sem conexão ou servidor fora do ar.
final class NetworkFailure extends Failure {
  const new();
}

Failure mapDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      break;
  }

  final status = error.response?.statusCode ?? 0;
  final data = error.response?.data;
  final body = data is Map<String, dynamic> ? data : const <String, dynamic>{};

  if (status == 400 && body['errors'] is Map) {
    final raw = body['errors'] as Map;
    return ValidationFailure({
      for (final entry in raw.entries)
        entry.key.toString(): [
          for (final m in entry.value as List) m.toString(),
        ],
    });
  }

  if (status == 0) {
    return const NetworkFailure();
  }

  return ApiFailure(
    code: body['code'] as String? ?? 'http_$status',
    message: body['title'] as String? ?? 'Erro $status',
    status: status,
  );
}

/// Executa uma chamada à API e troca o `DioException` por uma [Failure].
Future<T> guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw mapDioError(e);
  }
}
