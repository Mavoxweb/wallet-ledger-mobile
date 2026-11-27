import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/use_case_scope.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account_repository.dart';
import 'package:wallet_ledger_mobile/features/statement/presentation/statement_page.dart';

import '../../helpers/fakes.dart';

Future<void> _pump(
  WidgetTester tester,
  AccountRepository accounts, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: MaterialApp(
        theme: buildAppTheme(),
        home: UseCaseScope(
          account: accounts,
          // 26/11/2026 às 12:00 em Brasília: as amostras são de hoje e ontem.
          child: StatementPage(clock: () => DateTime.utc(2026, 11, 26, 15)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('agrupa por dia, com a hora de cada movimentação', (
    tester,
  ) async {
    await _pump(tester, FakeAccountRepository());

    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Ontem'), findsOneWidget);
    expect(find.text('Bruno C. D.'), findsOneWidget);
    // O Pix do Fabio foi às 13:00 UTC = 10:00 em Brasília.
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Você chegou ao começo do extrato.'), findsOneWidget);
  });

  testWidgets('conta sem movimentações mostra o estado vazio', (tester) async {
    await _pump(tester, FakeAccountRepository(empty: true));

    expect(find.text('Nenhuma movimentação ainda'), findsOneWidget);
  });

  testWidgets('filtro de entradas esconde o que saiu', (tester) async {
    await _pump(tester, FakeAccountRepository());

    await tester.tap(find.text('Entradas'));
    await tester.pumpAndSettle();

    expect(find.text('Bruno C. D.'), findsNothing);
    expect(find.text('Fabio N. C.'), findsOneWidget);

    await tester.tap(find.text('Saídas'));
    await tester.pumpAndSettle();

    expect(find.text('Bruno C. D.'), findsOneWidget);
    expect(find.text('Fabio N. C.'), findsNothing);
  });

  testWidgets('rolar até perto do fim busca a próxima página', (tester) async {
    final accounts = PagedAccountRepository({
      null: page(List.generate(20, (i) => 100 - i), next: 'c1'),
      'c1': page([50], next: null),
    });
    await _pump(tester, accounts);
    expect(accounts.calls, [null]);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
    await tester.pumpAndSettle();

    expect(accounts.calls, [null, 'c1']);
    expect(find.text('Você chegou ao começo do extrato.'), findsOneWidget);
  });

  testWidgets('página curta que não enche a tela já pede a seguinte', (
    tester,
  ) async {
    final accounts = PagedAccountRepository({
      null: page([30], next: 'c1'),
      'c1': page([20], next: null),
    });
    await _pump(tester, accounts);

    expect(accounts.calls, [null, 'c1']);
  });

  testWidgets('falha ao abrir mostra erro com tentar de novo', (tester) async {
    await _pump(tester, FakeAccountRepository(failure: const NetworkFailure()));

    expect(find.text('Não deu para carregar o extrato'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('cabe com texto em 200%', (tester) async {
    await _pump(tester, FakeAccountRepository(), textScale: 2);

    expect(tester.takeException(), isNull);
  });
}
