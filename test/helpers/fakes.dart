import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';

export 'package:wallet_ledger_mobile/core/storage/prefs_store.dart'
    show InMemoryPrefsStore;

final _now = DateTime.utc(2026, 11, 26, 15);

/// Movimentações de exemplo, da mais nova para a mais antiga.
final sampleMovements = [
  Movement(
    postingId: 30,
    transactionId: 't3',
    kind: MovementKind.transfer,
    isIncoming: false,
    amountCents: 2590,
    counterparty: 'Bruno C. D.',
    description: 'Almoço',
    createdAt: _now,
  ),
  Movement(
    postingId: 20,
    transactionId: 't2',
    kind: MovementKind.transfer,
    isIncoming: true,
    amountCents: 12000,
    counterparty: 'Fabio N. C.',
    description: 'PIX',
    createdAt: _now.subtract(const Duration(hours: 2)),
  ),
  Movement(
    postingId: 10,
    transactionId: 't1',
    kind: MovementKind.deposit,
    isIncoming: true,
    amountCents: 50000,
    description: 'Depósito simulado',
    createdAt: _now.subtract(const Duration(days: 1)),
  ),
];

class FakeAccountRepository implements AccountRepository {
  new({this.failure, this.empty = false});

  final Failure? failure;
  final bool empty;
  int accountCalls = 0;

  @override
  Future<AccountSummary> account() async {
    accountCalls++;
    if (failure != null) throw failure!;
    return const AccountSummary(
      accountId: '01a2167c-ca7e-7c24-9e30-140568d67447',
      isActive: true,
      balanceCents: 247410,
    );
  }

  @override
  Future<MovementPage> statement({int limit = 20, String? cursor}) async {
    if (failure != null) throw failure!;
    return MovementPage(
      items: empty ? const [] : sampleMovements.take(limit).toList(),
      nextCursor: null,
    );
  }
}

class FakeKeysRepository implements KeysRepository {
  @override
  Future<List<PixKeyItem>> list() async => const [
    PixKeyItem(id: 'k1', kind: PixKeyKind.email, value: 'ana@walletledger.dev'),
    PixKeyItem(
      id: 'k2',
      kind: PixKeyKind.evp,
      value: '0b7a3c1e-1d2f-4a5b-8c9d-0e1f2a3b4c5d',
    ),
  ];
}
