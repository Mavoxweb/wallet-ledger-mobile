import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_transfer.dart';

/// Mostra a quem pertence a chave antes do envio.
class LookupPixKey {
  const new(this._repository);

  final PixRepository _repository;

  Future<PixRecipient> call(PixKeyKind type, String value) =>
      _repository.lookup(type, value);
}
