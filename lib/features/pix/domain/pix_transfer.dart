import 'package:equatable/equatable.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

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
