import 'package:equatable/equatable.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';

/// Quem vai receber, como a API devolveu na consulta da chave (nome e CPF
/// mascarados: dá para conferir sem expor os dados da pessoa).
class PixRecipient extends Equatable {
  const new({
    required this.keyType,
    required this.keyValue,
    required this.maskedName,
    required this.maskedCpf,
  });

  final PixKeyKind keyType;
  final String keyValue;
  final String maskedName;
  final String maskedCpf;

  @override
  List<Object?> get props => [keyType, keyValue, maskedName, maskedCpf];
}

class PixReceipt extends Equatable {
  const new({
    required this.transactionId,
    required this.amountCents,
    required this.recipientMaskedName,
    required this.balanceCents,
    required this.createdAt,
  });

  final String transactionId;
  final int amountCents;
  final String recipientMaskedName;

  /// Saldo depois do envio.
  final int balanceCents;
  final DateTime createdAt;

  @override
  List<Object?> get props => [transactionId];
}

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
