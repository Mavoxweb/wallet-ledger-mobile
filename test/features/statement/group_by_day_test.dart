import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';
import 'package:wallet_ledger_mobile/features/statement/group_by_day.dart';

Movement _at(int id, DateTime createdAt) => Movement(
  postingId: id,
  transactionId: 't$id',
  kind: MovementKind.deposit,
  isIncoming: true,
  amountCents: 100,
  createdAt: createdAt,
);

void main() {
  // 26/11/2026 às 12:00 em Brasília (15:00 UTC).
  final now = DateTime.utc(2026, 11, 26, 15);

  test('agrupa em Hoje, Ontem e data por extenso', () {
    final groups = groupByDay([
      _at(3, DateTime.utc(2026, 11, 26, 14)),
      _at(2, DateTime.utc(2026, 11, 25, 20)),
      _at(1, DateTime.utc(2026, 11, 24, 10)),
    ], now);

    expect(groups.map((g) => g.label), ['Hoje', 'Ontem', '24 de novembro']);
    expect(groups.map((g) => g.items.length), [1, 1, 1]);
  });

  test('02:30 UTC ainda é o dia anterior em Brasília', () {
    // 26/11 02:30 UTC = 25/11 23:30 em Brasília.
    final groups = groupByDay([_at(1, DateTime.utc(2026, 11, 26, 2, 30))], now);

    expect(groups.single.label, 'Ontem');
  });

  test('a meia-noite de Brasília (03:00 UTC) já é Hoje', () {
    final groups = groupByDay([_at(1, DateTime.utc(2026, 11, 26, 3))], now);

    expect(groups.single.label, 'Hoje');
  });

  test('outro ano mostra o ano', () {
    final groups = groupByDay([_at(1, DateTime.utc(2025, 12, 31, 15))], now);

    expect(groups.single.label, '31 de dezembro de 2025');
  });

  test('itens do mesmo dia ficam juntos, na ordem recebida', () {
    final groups = groupByDay([
      _at(2, DateTime.utc(2026, 11, 26, 14)),
      _at(1, DateTime.utc(2026, 11, 26, 9)),
    ], now);

    expect(groups.single.items.map((m) => m.postingId), [2, 1]);
  });

  test('hora no fuso de Brasília', () {
    expect(timeOfDay(DateTime.utc(2026, 11, 26, 2, 5)), '23:05');
  });
}
