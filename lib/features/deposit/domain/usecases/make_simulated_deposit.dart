import 'package:wallet_ledger_mobile/features/deposit/domain/deposit_repository.dart';

/// Depósito fictício da demonstração. Devolve o saldo depois dele.
class MakeSimulatedDeposit {
  const new(this._repository);

  final DepositRepository _repository;

  Future<int> call({
    required int amountCents,
    required String idempotencyKey,
  }) => _repository.simulated(
    amountCents: amountCents,
    idempotencyKey: idempotencyKey,
  );
}
