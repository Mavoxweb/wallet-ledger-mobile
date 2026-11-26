import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

/// Depósito simulado (só existe na demonstração): põe dinheiro fictício na
/// conta para testar o Pix.
abstract interface class DepositRepository {
  /// Devolve o saldo depois do depósito.
  Future<int> simulated({
    required int amountCents,
    required String idempotencyKey,
  });
}

class ApiDepositRepository implements DepositRepository {
  const new(this._api);

  final api.WalletLedgerApi _api;

  @override
  Future<int> simulated({
    required int amountCents,
    required String idempotencyKey,
  }) => guard(() async {
    final r = await _api.getDepositsApi().apiV1DepositsSimulatedPost(
      idempotencyKey: idempotencyKey,
      simulatedDepositRequest: api.SimulatedDepositRequest(
        amountCents: amountCents,
      ),
    );
    return r.data!.balanceCents;
  });
}
