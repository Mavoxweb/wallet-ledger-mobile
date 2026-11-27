import 'package:wallet_ledger_mobile/features/charge/domain/charge_repository.dart';

/// Gera o "Pix Copia e Cola" de uma chave. Sem valor, quem paga escolhe.
class CreateCharge {
  const new(this._repository);

  final ChargeRepository _repository;

  Future<String> call({required String keyId, int? amountCents}) =>
      _repository.create(keyId: keyId, amountCents: amountCents);
}
