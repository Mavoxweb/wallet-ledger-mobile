import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

/// Cadastra uma chave, respeitando o limite antes de chamar a API.
class AddPixKey {
  const new(this._repository);

  final KeysRepository _repository;

  /// Limite do Banco Central para pessoa física.
  static const maxKeys = 5;

  /// A mesma falha que a API daria: o limite é avisado sem ida à rede.
  static const limitFailure = ApiFailure(
    code: 'pix_key_limit',
    message: '',
    status: 422,
  );

  /// Para a aleatória, [value] é nulo: a API gera o UUID.
  Future<PixKeyItem> call(
    PixKeyKind kind,
    String? value, {
    required int currentCount,
  }) {
    if (currentCount >= maxKeys) return Future.error(limitFailure);
    return _repository.create(kind, value);
  }
}
