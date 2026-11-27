import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/network/api_guard.dart';
import 'package:wallet_ledger_mobile/features/deposit/domain/deposit_repository.dart';

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
