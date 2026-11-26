import 'package:wallet_ledger_api/src/model/account_response.dart';
import 'package:wallet_ledger_api/src/model/charge_response.dart';
import 'package:wallet_ledger_api/src/model/create_charge_request.dart';
import 'package:wallet_ledger_api/src/model/create_pix_key_request.dart';
import 'package:wallet_ledger_api/src/model/login_request.dart';
import 'package:wallet_ledger_api/src/model/me_response.dart';
import 'package:wallet_ledger_api/src/model/pix_key_lookup_response.dart';
import 'package:wallet_ledger_api/src/model/pix_key_response.dart';
import 'package:wallet_ledger_api/src/model/pix_transfer_request.dart';
import 'package:wallet_ledger_api/src/model/pix_transfer_response.dart';
import 'package:wallet_ledger_api/src/model/problem_details.dart';
import 'package:wallet_ledger_api/src/model/refresh_request.dart';
import 'package:wallet_ledger_api/src/model/register_request.dart';
import 'package:wallet_ledger_api/src/model/register_response.dart';
import 'package:wallet_ledger_api/src/model/simulated_deposit_request.dart';
import 'package:wallet_ledger_api/src/model/simulated_deposit_response.dart';
import 'package:wallet_ledger_api/src/model/statement_item.dart';
import 'package:wallet_ledger_api/src/model/statement_page.dart';
import 'package:wallet_ledger_api/src/model/token_response.dart';
import 'package:wallet_ledger_api/src/model/validation_problem_details.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AccountResponse':
      return AccountResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AccountStatus':
    case 'ChargeResponse':
      return ChargeResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateChargeRequest':
      return CreateChargeRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreatePixKeyRequest':
      return CreatePixKeyRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Direction':
    case 'LoginRequest':
      return LoginRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MeResponse':
      return MeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PixKeyLookupResponse':
      return PixKeyLookupResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PixKeyResponse':
      return PixKeyResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PixKeyType':
    case 'PixTransferRequest':
      return PixTransferRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PixTransferResponse':
      return PixTransferResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProblemDetails':
      return ProblemDetails.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshRequest':
      return RefreshRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterRequest':
      return RegisterRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterResponse':
      return RegisterResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SimulatedDepositRequest':
      return SimulatedDepositRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SimulatedDepositResponse':
      return SimulatedDepositResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StatementItem':
      return StatementItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'StatementPage':
      return StatementPage.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TokenResponse':
      return TokenResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TransactionType':
    case 'ValidationProblemDetails':
      return ValidationProblemDetails.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
