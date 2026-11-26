import 'package:equatable/equatable.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/errors/failure.dart';

/// Modelos do próprio app. As telas não usam os tipos gerados da API: se o
/// contrato mudar, só este arquivo muda.
class AccountSummary extends Equatable {
  const new({
    required this.accountId,
    required this.isActive,
    required this.balanceCents,
  });

  final String accountId;
  final bool isActive;
  final int balanceCents;

  /// Final da conta para exibir: `•••• 7447`.
  String get maskedNumber =>
      '•••• ${accountId.substring(accountId.length - 4)}';

  @override
  List<Object?> get props => [accountId, isActive, balanceCents];
}

enum MovementKind { deposit, transfer, reversal }

class Movement extends Equatable {
  const new({
    required this.postingId,
    required this.transactionId,
    required this.kind,
    required this.isIncoming,
    required this.amountCents,
    required this.createdAt,
    this.counterparty,
    this.description,
  });

  final int postingId;
  final String transactionId;
  final MovementKind kind;
  final bool isIncoming;

  /// Sempre positivo; [isIncoming] diz a direção.
  final int amountCents;
  final String? counterparty;
  final String? description;
  final DateTime createdAt;

  /// Valor com sinal: negativo para saída.
  int get signedCents => isIncoming ? amountCents : -amountCents;

  @override
  List<Object?> get props => [postingId];
}

class MovementPage extends Equatable {
  const new({required this.items, required this.nextCursor});

  final List<Movement> items;

  /// Nulo quando não há mais páginas.
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}

abstract interface class AccountRepository {
  Future<AccountSummary> account();
  Future<MovementPage> statement({int limit = 20, String? cursor});
}

class ApiAccountRepository implements AccountRepository {
  const new(this._api);

  final api.WalletLedgerApi _api;

  @override
  Future<AccountSummary> account() => guard(() async {
    final r = (await _api.getAccountApi().apiV1AccountGet()).data!;
    return AccountSummary(
      accountId: r.accountId,
      isActive: r.status == api.AccountStatus.active,
      balanceCents: r.balanceCents,
    );
  });

  @override
  Future<MovementPage> statement({int limit = 20, String? cursor}) =>
      guard(() async {
        final r = (await _api.getAccountApi().apiV1AccountStatementGet(
          limit: limit,
          cursor: cursor,
        )).data!;
        return MovementPage(
          items: [for (final item in r.items) _toMovement(item)],
          nextCursor: r.nextCursor,
        );
      });

  static Movement _toMovement(api.StatementItem i) => Movement(
    postingId: i.postingId,
    transactionId: i.transactionId,
    kind: switch (i.type) {
      api.TransactionType.deposit => MovementKind.deposit,
      api.TransactionType.transfer => MovementKind.transfer,
      api.TransactionType.reversal => MovementKind.reversal,
    },
    isIncoming: i.direction == api.Direction.in_,
    amountCents: i.amountCents,
    counterparty: i.counterpartyMaskedName,
    description: i.description,
    createdAt: i.createdAt,
  );
}
