import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

DioException _response(int status, Object body) {
  final request = RequestOptions(path: '/api/v1/transfers/pix');
  return DioException(
    requestOptions: request,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: request, statusCode: status, data: body),
  );
}

void main() {
  test('regra de negócio vira ApiFailure com o code da API', () {
    final failure = mapDioError(
      _response(422, {
        'code': 'insufficient_funds',
        'title': 'Saldo insuficiente.',
      }),
    );

    expect(
      failure,
      isA<ApiFailure>().having((f) => f.code, 'code', 'insufficient_funds'),
    );
    expect(
      messageFor(failure),
      'Saldo insuficiente para este Pix. Confira o valor e tente de novo.',
    );
  });

  test('400 com erros por campo vira ValidationFailure', () {
    final failure = mapDioError(
      _response(400, {
        'errors': {
          'cpf': ['CPF inválido.'],
        },
      }),
    );

    expect(failure, isA<ValidationFailure>());
    expect((failure as ValidationFailure).errors['cpf'], ['CPF inválido.']);
  });

  test('sem conexão vira NetworkFailure com mensagem de rede', () {
    final failure = mapDioError(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
    );

    expect(failure, isA<NetworkFailure>());
    expect(messageFor(failure), contains('conexão'));
  });

  test('código desconhecido tem mensagem genérica, nunca vazia', () {
    final failure = mapDioError(_response(500, {'title': 'Erro interno'}));

    expect(messageFor(failure), isNotEmpty);
  });
}
