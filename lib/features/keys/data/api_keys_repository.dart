import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/network/api_guard.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

class ApiKeysRepository implements KeysRepository {
  const new(this._api);

  final api.WalletLedgerApi _api;

  @override
  Future<List<PixKeyItem>> list() => guard(() async {
    final keys = (await _api.getPixKeysApi().apiV1PixKeysGet()).data!;
    return [for (final k in keys) _fromApi(k)];
  });

  @override
  Future<PixKeyItem> create(PixKeyKind kind, String? value) => guard(() async {
    final r = await _api.getPixKeysApi().apiV1PixKeysPost(
      createPixKeyRequest: api.CreatePixKeyRequest(
        type: switch (kind) {
          PixKeyKind.email => api.PixKeyType.email,
          PixKeyKind.phone => api.PixKeyType.phone,
          PixKeyKind.evp => api.PixKeyType.evp,
        },
        value: value,
      ),
    );
    return _fromApi(r.data!);
  });

  @override
  Future<void> delete(String id) =>
      guard(() => _api.getPixKeysApi().apiV1PixKeysIdDelete(id: id));

  static PixKeyItem _fromApi(api.PixKeyResponse k) => PixKeyItem(
    id: k.id,
    kind: switch (k.type) {
      api.PixKeyType.email => PixKeyKind.email,
      api.PixKeyType.phone => PixKeyKind.phone,
      api.PixKeyType.evp => PixKeyKind.evp,
    },
    value: k.value,
  );
}
