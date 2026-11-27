import 'package:dio/dio.dart';
import 'package:wallet_ledger_mobile/core/storage/token_store.dart';

/// Troca o refresh token por um par novo (chama `POST /api/v1/auth/refresh`).
typedef RefreshTokens = Future<Tokens> Function(String refreshToken);

/// Põe o access token em cada requisição e, no `401`, renova e repete.
///
/// `QueuedInterceptor` trata um erro por vez: com três `401` simultâneos, só o
/// primeiro renova. A API trataria uma segunda renovação como reuso de token.
class AuthInterceptor extends QueuedInterceptor {
  new({
    required this._store,
    required this._refresh,
    required this._retryClient,
    required this._onSessionExpired,
  });

  static const _retriedFlag = 'auth_retried';

  final TokenStore _store;
  final RefreshTokens _refresh;
  final Dio _retryClient;
  final void Function() _onSessionExpired;

  static bool _isAuthRoute(RequestOptions options) =>
      options.path.contains('/api/v1/auth/');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthRoute(options)) {
      final tokens = await _store.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;

    if (!isUnauthorized ||
        _isAuthRoute(request) ||
        request.extra[_retriedFlag] == true) {
      return handler.next(err);
    }

    final current = await _store.read();
    if (current == null) {
      return handler.next(err);
    }

    try {
      // Outra requisição da fila já renovou enquanto esta esperava?
      final sentWith = request.headers['Authorization'];
      final tokens = sentWith == 'Bearer ${current.accessToken}'
          ? await _renew(current.refreshToken)
          : current;

      final retry = request.copyWith(
        headers: {
          ...request.headers,
          'Authorization': 'Bearer ${tokens.accessToken}',
        },
        extra: {...request.extra, _retriedFlag: true},
      );
      handler.resolve(await _retryClient.fetch<dynamic>(retry));
    } on DioException catch (e) {
      if (e.requestOptions == request) return handler.next(e);
      // A renovação não chegou na API (rede caiu, tempo esgotou): a
      // requisição original falha como erro de rede, não como 401.
      if (e.response == null) {
        return handler.next(
          DioException(
            requestOptions: request,
            type: e.type,
            error: e.error,
            message: e.message,
          ),
        );
      }
      handler.next(err);
    }
  }

  Future<Tokens> _renew(String refreshToken) async {
    try {
      final tokens = await _refresh(refreshToken);
      await _store.write(tokens);
      return tokens;
    } on Object catch (e) {
      // Só encerra a sessão quando a API **recusou** o refresh token (4xx).
      // Sem resposta (rede) ou com erro do servidor (5xx), o token pode
      // continuar válido: a pessoa segue logada e tenta de novo depois.
      if (!_sessionRejected(e)) rethrow;
      await _store.clear();
      _onSessionExpired();
      rethrow;
    }
  }

  static bool _sessionRejected(Object error) => switch (error) {
    DioException(:final response?) =>
      response.statusCode != null &&
          response.statusCode! >= 400 &&
          response.statusCode! < 500,
    DioException() => false,
    _ => true,
  };
}
