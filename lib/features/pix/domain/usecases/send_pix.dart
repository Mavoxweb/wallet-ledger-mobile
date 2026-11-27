import 'package:wallet_ledger_mobile/features/pix/domain/pix_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_transfer.dart';

/// Envia o Pix. Quem chama decide a chave de idempotência: repetir a mesma
/// chave devolve o comprovante da primeira vez, sem enviar de novo.
class SendPix {
  const new(this._repository);

  final PixRepository _repository;

  Future<PixReceipt> call({
    required PixRecipient recipient,
    required int amountCents,
    required String? description,
    required String idempotencyKey,
  }) => _repository.transfer(
    recipient: recipient,
    amountCents: amountCents,
    description: description,
    idempotencyKey: idempotencyKey,
  );
}
