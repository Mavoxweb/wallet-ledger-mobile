import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/network/auth_interceptor.dart';
import 'package:wallet_ledger_mobile/core/storage/token_store.dart';

import '../../helpers/fake_adapter.dart';

Tokens _tokens(String access, String refresh) => Tokens(
  accessToken: access,
  refreshToken: refresh,
  expiresAt: DateTime.utc(2030),
);

/// Monta um Dio com o interceptor e um servidor falso.
({
  Dio dio,
  FakeAdapter adapter,
  InMemoryTokenStore store,
  List<String> refreshed,
  List<int> expired,
})
_setup({
  required FakeHandler handler,
  Future<Tokens> Function(String refreshToken)? refresh,
}) {
  final adapter = FakeAdapter(handler);
  final store = InMemoryTokenStore(_tokens('a1', 'r1'));
  final refreshed = <String>[];
  final expired = <int>[];

  Dio build() =>
      Dio(BaseOptions(baseUrl: 'http://api.teste'))
        ..httpClientAdapter = adapter;

  final dio = build()
    ..interceptors.add(
      AuthInterceptor(
        store: store,
        retryClient: build(),
        refresh: (token) async {
          refreshed.add(token);
          if (refresh != null) return await refresh(token);
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return _tokens('a2', 'r2');
        },
        onSessionExpired: () => expired.add(1),
      ),
    );

  return (
    dio: dio,
    adapter: adapter,
    store: store,
    refreshed: refreshed,
    expired: expired,
  );
}

/// Servidor que só aceita o access token "a2".
Future<FakeResponse> _acceptsOnlyA2(RequestOptions r) async =>
    r.headers['Authorization'] == 'Bearer a2'
    ? const FakeResponse(200, {'ok': true})
    : const FakeResponse(401, {'title': 'expirado'});

void main() {
  test('anexa o access token em toda requisição', () async {
    final s = _setup(handler: (_) async => const FakeResponse(200, {}));

    await s.dio.get<void>('/api/v1/me');

    expect(s.adapter.requests.single.headers['Authorization'], 'Bearer a1');
  });

  test('com 401, renova uma vez e repete a requisição original', () async {
    final s = _setup(handler: _acceptsOnlyA2);

    final response = await s.dio.get<Map<String, dynamic>>('/api/v1/me');

    expect(response.statusCode, 200);
    expect(s.refreshed, ['r1']);
    expect((await s.store.read())!.accessToken, 'a2');
  });

  test('três 401 ao mesmo tempo disparam uma única renovação', () async {
    final s = _setup(handler: _acceptsOnlyA2);

    final responses = await Future.wait([
      s.dio.get<void>('/api/v1/me'),
      s.dio.get<void>('/api/v1/account'),
      s.dio.get<void>('/api/v1/account/statement'),
    ]);

    expect(responses.map((r) => r.statusCode), everyElement(200));
    expect(s.refreshed, hasLength(1));
  });

  test(
    'se a API recusar a renovação, encerra a sessão uma vez, sem laço',
    () async {
      final refresh = RequestOptions(path: '/api/v1/auth/refresh');
      final s = _setup(
        handler: (_) async => const FakeResponse(401, {}),
        refresh: (_) async => throw DioException(
          requestOptions: refresh,
          response: Response(requestOptions: refresh, statusCode: 401),
        ),
      );

      await expectLater(
        s.dio.get<void>('/api/v1/me'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );

      expect(s.expired, [1]);
      expect(await s.store.read(), isNull);
      expect(s.adapter.requests, hasLength(1));
    },
  );

  // Cair a rede durante a renovação não prova que a sessão acabou: o refresh
  // token pode estar válido. A pessoa continua logada e vê um erro de rede.
  test('se a rede cair durante a renovação, a sessão continua', () async {
    final s = _setup(
      handler: (_) async => const FakeResponse(401, {}),
      refresh: (_) async => throw DioException.connectionError(
        requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
        reason: 'sem rede',
      ),
    );

    await expectLater(
      s.dio.get<void>('/api/v1/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );

    expect(s.expired, isEmpty);
    expect((await s.store.read())!.refreshToken, 'r1');
  });

  test(
    'se a API falhar (5xx) durante a renovação, a sessão continua',
    () async {
      final refresh = RequestOptions(path: '/api/v1/auth/refresh');
      final s = _setup(
        handler: (_) async => const FakeResponse(401, {}),
        refresh: (_) async => throw DioException(
          requestOptions: refresh,
          response: Response(requestOptions: refresh, statusCode: 503),
        ),
      );

      await expectLater(s.dio.get<void>('/api/v1/me'), throwsA(anything));

      expect(s.expired, isEmpty);
      expect(await s.store.read(), isNotNull);
    },
  );

  test('não tenta renovar em rotas de autenticação', () async {
    final s = _setup(
      handler: (_) async =>
          const FakeResponse(401, {'code': 'invalid_credentials'}),
    );

    await expectLater(
      s.dio.post<void>('/api/v1/auth/login', data: {}),
      throwsA(isA<DioException>()),
    );

    expect(s.refreshed, isEmpty);
    expect(
      s.adapter.requests.single.headers.containsKey('Authorization'),
      isFalse,
    );
  });
}
