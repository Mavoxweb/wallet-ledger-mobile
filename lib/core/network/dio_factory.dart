import 'package:dio/dio.dart';
import 'package:wallet_ledger_mobile/core/config/env.dart';

/// Cliente HTTP base do app. O cliente gerado (`wallet_ledger_api`) recebe
/// este Dio pronto; os interceptors de autenticação entram depois (PR 3).
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
