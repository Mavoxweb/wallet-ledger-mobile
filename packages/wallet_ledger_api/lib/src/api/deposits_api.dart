//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

// ignore: unused_import
import 'dart:convert';
import 'package:wallet_ledger_api/src/deserialize.dart';
import 'package:dio/dio.dart';

import 'package:wallet_ledger_api/src/model/problem_details.dart';
import 'package:wallet_ledger_api/src/model/simulated_deposit_request.dart';
import 'package:wallet_ledger_api/src/model/simulated_deposit_response.dart';
import 'package:wallet_ledger_api/src/model/validation_problem_details.dart';

class DepositsApi {
  final Dio _dio;

  const DepositsApi(this._dio);

  /// Depósito de demonstração na própria conta (até R$ 1.000,00 por vez e R$ 5.000,00 por dia). Exige o header Idempotency-Key.
  ///
  ///
  /// Parameters:
  /// * [idempotencyKey] - Identificador único da operação (ex.: um UUID). Repetir a mesma chave devolve a mesma resposta sem executar de novo.
  /// * [simulatedDepositRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [SimulatedDepositResponse] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<SimulatedDepositResponse>> apiV1DepositsSimulatedPost({
    required String idempotencyKey,
    required SimulatedDepositRequest simulatedDepositRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/api/v1/deposits/simulated';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        r'Idempotency-Key': idempotencyKey,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {'type': 'http', 'scheme': 'bearer', 'name': 'Bearer'},
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      _bodyData = jsonEncode(simulatedDepositRequest);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(_dio.options, _path),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    SimulatedDepositResponse? _responseData;

    try {
      final rawData = _response.data;
      _responseData = rawData == null
          ? null
          : deserialize<SimulatedDepositResponse, SimulatedDepositResponse>(
              rawData,
              'SimulatedDepositResponse',
              growable: true,
            );
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<SimulatedDepositResponse>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
