import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Resposta que o servidor falso devolve.
class FakeResponse {
  const new(this.status, [this.body]);

  final int status;
  final Object? body;
}

/// Decide a resposta a partir da requisição recebida.
typedef FakeHandler = Future<FakeResponse> Function(RequestOptions request);

/// Substitui a rede do Dio nos testes: nenhuma chamada sai do computador, e o
/// teste controla exatamente o que o "servidor" responde e em que ordem.
class FakeAdapter implements HttpClientAdapter {
  new(this.handler);

  final FakeHandler handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final response = await handler(options);
    return ResponseBody.fromString(
      response.body == null ? '' : jsonEncode(response.body),
      response.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
