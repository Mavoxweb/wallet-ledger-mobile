import 'dart:async';

import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';
import 'package:wallet_ledger_mobile/features/charge/data/charge_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/data/pix_repository.dart';

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

/// Uma página de depósitos com os ids dados.
MovementPage page(List<int> ids, {required String? next}) => MovementPage(
  items: [
    for (final id in ids)
      Movement(
        postingId: id,
        transactionId: 't$id',
        kind: MovementKind.deposit,
        isIncoming: true,
        amountCents: 100,
        createdAt: _now,
      ),
  ],
  nextCursor: next,
);

/// Extrato paginado: cada cursor devolve uma página. [hold] segura a resposta
/// de um cursor até o teste liberar; [failOn] faz um cursor falhar.
class PagedAccountRepository extends FakeAccountRepository {
  new(this.pages, {this.hold = const {}, this.failOn = const {}});

  final Map<String?, MovementPage> pages;
  final Map<String, Completer<void>> hold;
  final Set<String> failOn;

  /// Cursores pedidos, na ordem.
  final calls = <String?>[];

  @override
  Future<MovementPage> statement({int limit = 20, String? cursor}) async {
    calls.add(cursor);
    await hold[cursor]?.future;
    if (failOn.contains(cursor)) throw const NetworkFailure();
    return pages[cursor] ?? const MovementPage(items: [], nextCursor: null);
  }
}

const notFound = ApiFailure(code: 'not_found', message: '', status: 404);
const noFunds = ApiFailure(
  code: 'insufficient_funds',
  message: '',
  status: 422,
);

/// Pix de mentira. As falhas de `transferFailures` são consumidas em ordem,
/// uma por envio; depois delas, o envio dá certo.
class FakePixRepository implements PixRepository {
  new({this.lookupFailure, List<Failure>? transferFailures})
    : _transferFailures = [...?transferFailures];

  final Failure? lookupFailure;
  final List<Failure> _transferFailures;

  /// Chaves de idempotência recebidas, na ordem.
  final sentKeys = <String>[];

  @override
  Future<PixRecipient> lookup(PixKeyKind type, String value) async {
    if (lookupFailure != null) throw lookupFailure!;
    return PixRecipient(
      keyType: type,
      keyValue: value,
      maskedName: 'Bruno C. D.',
      maskedCpf: '***.456.789-**',
    );
  }

  @override
  Future<PixReceipt> transfer({
    required PixRecipient recipient,
    required int amountCents,
    required String? description,
    required String idempotencyKey,
  }) async {
    sentKeys.add(idempotencyKey);
    if (_transferFailures.isNotEmpty) throw _transferFailures.removeAt(0);
    return PixReceipt(
      transactionId: 'tx-1',
      amountCents: amountCents,
      recipientMaskedName: recipient.maskedName,
      balanceCents: 247410 - amountCents,
      createdAt: _now,
    );
  }
}

class FakeChargeRepository implements ChargeRepository {
  /// Vetor oficial do Manual do BR Code.
  static const payload =
      '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d1-a456-426655440000'
      '5204000053039865802BR5913Fulano de Tal6008BRASILIA62070503***63041D3D';

  /// Pedidos recebidos: (chave, valor).
  final requests = <(String, int?)>[];

  @override
  Future<String> create({required String keyId, int? amountCents}) async {
    requests.add((keyId, amountCents));
    return payload;
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
