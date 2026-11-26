import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

Future<void> _openHome(
  WidgetTester tester, {
  double textScale = 1,
  FakeAccountRepository? accounts,
}) async {
  await pumpApp(
    tester,
    repository: authRepository(),
    textScale: textScale,
    accounts: accounts,
  );
  await finishIntro(tester);
}

void main() {
  testWidgets('mostra o saldo e as últimas movimentações', (tester) async {
    await _openHome(tester);

    expect(find.text('2.474'), findsOneWidget);
    expect(find.text('Bruno C. D.'), findsOneWidget);
    expect(find.text('Últimas movimentações'), findsOneWidget);
  });

  testWidgets('saldo oculto some também para o leitor de tela', (tester) async {
    final semantics = tester.ensureSemantics();
    await _openHome(tester);

    await tester.tap(find.byTooltip('Ocultar saldo'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('2.474')), findsNothing);
    expect(find.bySemanticsLabel('Saldo oculto'), findsOneWidget);
    expect(find.byTooltip('Mostrar saldo'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('cabe com texto em 200%', (tester) async {
    await _openHome(tester, textScale: 2);

    expect(tester.takeException(), isNull);
  });

  testWidgets('puxar para baixo atualiza', (tester) async {
    final accounts = FakeAccountRepository();
    await _openHome(tester, accounts: accounts);
    final before = accounts.accountCalls;

    await tester.fling(
      find.text('Últimas movimentações'),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    expect(accounts.accountCalls, greaterThan(before));
  });

  testWidgets('conta sem movimentações mostra como começar', (tester) async {
    await _openHome(tester, accounts: FakeAccountRepository(empty: true));

    expect(find.textContaining('Nenhuma movimentação ainda'), findsOneWidget);
  });
}
