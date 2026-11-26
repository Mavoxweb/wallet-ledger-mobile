import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

/// Cobranças Pix: a API monta o BR Code ("Pix Copia e Cola") de uma chave da
/// conta, com valor fixo ou livre.
abstract interface class ChargeRepository {
  Future<String> create({required String keyId, int? amountCents});
}

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
