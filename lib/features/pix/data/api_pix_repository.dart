import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/network/api_guard.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_transfer.dart';

class ApiPixRepository implements PixRepository {
  const new(this._api);

  final api.WalletLedgerApi _api;

  static api.PixKeyType _toApi(PixKeyKind kind) => switch (kind) {
    PixKeyKind.email => api.PixKeyType.email,
    PixKeyKind.phone => api.PixKeyType.phone,
    PixKeyKind.evp => api.PixKeyType.evp,
  };

  @override
  Future<PixRecipient> lookup(PixKeyKind type, String value) => guard(() async {
    final r = (await _api.getPixKeysApi().apiV1PixKeysLookupGet(
      type: _toApi(type),
      value: value,
    )).data!;
    return PixRecipient(
      keyType: type,
      keyValue: value,
      maskedName: r.maskedName,
      maskedCpf: r.maskedCpf,
    );
  });

  @override
  Future<PixReceipt> transfer({
    required PixRecipient recipient,
    required int amountCents,
    required String? description,
    required String idempotencyKey,
  }) => guard(() async {
    final r = (await _api.getTransfersApi().apiV1TransfersPixPost(
      idempotencyKey: idempotencyKey,
      pixTransferRequest: api.PixTransferRequest(
        keyType: _toApi(recipient.keyType),
        keyValue: recipient.keyValue,
        amountCents: amountCents,
        description: description,
      ),
    )).data!;
    return PixReceipt(
      transactionId: r.transactionId,
      amountCents: r.amountCents,
      recipientMaskedName: r.recipientMaskedName,
      balanceCents: r.balanceCents,
      createdAt: r.createdAt,
    );
  });
}
