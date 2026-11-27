import 'package:dio/dio.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

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
