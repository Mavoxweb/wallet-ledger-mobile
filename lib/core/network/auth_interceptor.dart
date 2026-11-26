import 'package:dio/dio.dart';
import 'package:wallet_ledger_mobile/core/storage/token_store.dart';

/// Troca o refresh token por um par novo (chama `POST /api/v1/auth/refresh`).
typedef RefreshTokens = Future<Tokens> Function(String refreshToken);

/// Coloca o access token em cada requisição e, quando ele expira (`401`),
/// renova a sessão em silêncio e repete a requisição.
///
/// Por que `QueuedInterceptor`: ele trata um erro de cada vez. Se três telas
/// recebem `401` ao mesmo tempo, a primeira renova; quando chega a vez das
/// outras duas, o token já mudou, e elas só repetem a chamada com o token novo.
/// Assim nasce **uma** renovação, e não três (a API trataria a segunda como
/// reuso de token e derrubaria a sessão).
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
      handler.next(e.requestOptions == request ? e : err);
    }
  }

  Future<Tokens> _renew(String refreshToken) async {
    try {
      final tokens = await _refresh(refreshToken);
      await _store.write(tokens);
      return tokens;
    } on Object {
      // Não deu para renovar: a sessão acabou.
      // Limpa tudo e avisa o app uma vez.
      await _store.clear();
      _onSessionExpired();
      rethrow;
    }
  }
}
