import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/network/api_guard.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/charge_repository.dart';

class ApiChargeRepository implements ChargeRepository {
  const new(this._api);

  final api.WalletLedgerApi _api;

  @override
  Future<String> create({required String keyId, int? amountCents}) =>
      guard(() async {
        final r = await _api.getChargesApi().apiV1PixChargesPost(
          createChargeRequest: api.CreateChargeRequest(
            keyId: keyId,
            amountCents: amountCents,
          ),
        );
        return r.data!.payload;
      });
}
