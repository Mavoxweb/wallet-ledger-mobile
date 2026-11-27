import 'package:wallet_ledger_api/wallet_ledger_api.dart' as api;
import 'package:wallet_ledger_mobile/core/network/api_guard.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account_repository.dart';

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
