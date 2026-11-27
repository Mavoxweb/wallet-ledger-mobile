import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

abstract interface class KeysRepository {
  Future<List<PixKeyItem>> list();

  /// Cadastra uma chave. Para a aleatória, [value] é nulo: a API gera o UUID.
  Future<PixKeyItem> create(PixKeyKind kind, String? value);

  Future<void> delete(String id);
}
