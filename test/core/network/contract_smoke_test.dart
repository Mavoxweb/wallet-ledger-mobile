import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart';
import 'package:wallet_ledger_mobile/core/config/env.dart';
import 'package:wallet_ledger_mobile/core/network/dio_factory.dart';

void main() {
  test('modelos gerados trazem centavos como int', () {
    final response = SimulatedDepositResponse.fromJson(const {
      'transactionId': '01a2167c-ca7e-7c24-9e30-140568d602c4',
      'balanceCents': 247410,
    });

    expect(response.balanceCents, isA<int>());
    expect(response.balanceCents, 247410);
  });

  test('enum de chave Pix lê o texto da API', () {
    final key = PixKeyResponse.fromJson(const {
      'id': '01a2167c-ca7e-7c24-9e30-140568d602c4',
      'type': 'phone',
      'value': '+5521999990000',
      'createdAt': '2026-11-26T12:00:00Z',
    });

    expect(key.type, PixKeyType.phone);
  });

  test('createDio usa a URL da API e aceita JSON', () {
    final dio = createDio(const Env(apiBaseUrl: 'http://api.teste'));

    expect(dio.options.baseUrl, 'http://api.teste');
    expect(dio.options.headers['Accept'], 'application/json');
    expect(dio.options.connectTimeout, const Duration(seconds: 15));
  });
}
