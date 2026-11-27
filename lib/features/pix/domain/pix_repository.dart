import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_transfer.dart';

abstract interface class PixRepository {
  Future<PixRecipient> lookup(PixKeyKind type, String value);

  /// Envia o Pix. A mesma [idempotencyKey] nunca envia duas vezes: a API
  /// devolve a resposta da primeira vez.
  Future<PixReceipt> transfer({
    required PixRecipient recipient,
    required int amountCents,
    required String? description,
    required String idempotencyKey,
  });
}
