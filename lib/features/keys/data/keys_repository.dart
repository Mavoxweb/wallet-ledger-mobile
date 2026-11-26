import 'package:equatable/equatable.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

enum PixKeyKind { email, phone, evp }

class PixKeyItem extends Equatable {
  const new({required this.id, required this.kind, required this.value});

  final String id;
  final PixKeyKind kind;
  final String value;

  /// Como a chave aparece para a pessoa.
  String get label => switch (kind) {
    PixKeyKind.email => value,
    PixKeyKind.phone => value,
    PixKeyKind.evp => 'aleatória',
  };

  @override
  List<Object?> get props => [id, kind, value];
}

/// Chaves Pix da conta. Cadastrar e remover chegam no PR 9.
abstract interface class KeysRepository {
  Future<List<PixKeyItem>> list();
}

class ApiKeysRepository implements KeysRepository {
  const new(this._api);

  final api.WalletLedgerApi _api;

  @override
  Future<List<PixKeyItem>> list() => guard(() async {
    final keys = (await _api.getPixKeysApi().apiV1PixKeysGet()).data!;
    return [
      for (final k in keys)
        PixKeyItem(
          id: k.id,
          kind: switch (k.type) {
            api.PixKeyType.email => PixKeyKind.email,
            api.PixKeyType.phone => PixKeyKind.phone,
            api.PixKeyType.evp => PixKeyKind.evp,
          },
          value: k.value,
        ),
    ];
  });
}
