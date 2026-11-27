import 'package:dio/dio.dart';
import 'package:wallet_ledger_mobile/core/config/env.dart';

/// Cliente HTTP base; o cliente gerado recebe este Dio pronto.
Dio createDio(Env env) {
  return Dio(
    BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );
}
