import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/features/pix/data/pix_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/pix_page.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

Future<FakePixRepository> _pump(
  WidgetTester tester, {
  double textScale = 1,
  FakePixRepository? pix,
}) async {
  final repository = pix ?? FakePixRepository();
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 860),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        theme: buildAppTheme(),
        home: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<PixRepository>.value(value: repository),
            RepositoryProvider<BiometricGate>.value(value: FakeBiometricGate()),
          ],
          child: const PixPage(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _enterKey(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'bruno@walletledger.dev');
  await tester.pump();
  await tester.tap(find.text('Continuar'));
  await tester.pumpAndSettle();
}

Future<void> _typeAmount(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    final key = find.byKey(ValueKey('key-$d'));
    await tester.ensureVisible(key);
    await tester.tap(key);
    await tester.pump();
  }
}

FilledButton _continue(WidgetTester tester) => tester.widget<FilledButton>(
  find.ancestor(
    of: find.text('Continuar'),
    matching: find.byType(FilledButton),
  ),
);

void main() {
  testWidgets('continuar fica desligado com zero e acima do limite', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 860));
    await _pump(tester);
    await _enterKey(tester);

    expect(_continue(tester).onPressed, isNull);

    await _typeAmount(tester, '2590');
    expect(_continue(tester).onPressed, isNotNull);

    await _typeAmount(tester, '99999999');
    expect(_continue(tester).onPressed, isNull);
    expect(find.textContaining('valor máximo'), findsOneWidget);
  });

  testWidgets('a confirmação mostra o nome e o CPF mascarados da consulta', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 860));
    await _pump(tester);
    await _enterKey(tester);
    await _typeAmount(tester, '2590');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Confira antes de enviar'), findsOneWidget);
    expect(find.text('Bruno C. D.'), findsOneWidget);
    expect(find.text('***.456.789-**'), findsOneWidget);
    expect(find.bySemanticsLabel(r'R$ 25,90'), findsOneWidget);
  });

  testWidgets('enviar mostra o comprovante', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 860));
    final pix = await _pump(tester);
    await _enterKey(tester);
    await _typeAmount(tester, '2590');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Pix enviado'), findsOneWidget);
    expect(pix.sentKeys, hasLength(1));
  });

  testWidgets('chave inválida mostra a ajuda sem chamar a API', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'bruno');
    await tester.pump();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('celular com DDD'), findsOneWidget);
  });

  testWidgets('a confirmação cabe com texto em 200%', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 860));
    await _pump(tester, textScale: 2);
    await _enterKey(tester);
    await _typeAmount(tester, '2590');
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Confira antes de enviar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
