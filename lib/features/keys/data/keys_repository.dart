import 'package:equatable/equatable.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

enum PixKeyKind { email, phone, evp }

class PixKeyItem extends Equatable {
  const new({required this.id, required this.kind, required this.value});

  final String id;
  final PixKeyKind kind;
  final String value;

  String get label => switch (kind) {
    PixKeyKind.email => value,
    PixKeyKind.phone => value,
    PixKeyKind.evp => 'aleatória',
  };

  @override
  List<Object?> get props => [id, kind, value];
}

abstract interface class KeysRepository {
  Future<List<PixKeyItem>> list();

  /// Cadastra uma chave. Para a aleatória, [value] é nulo: a API gera o UUID.
  Future<PixKeyItem> create(PixKeyKind kind, String? value);

  Future<void> delete(String id);
}

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
