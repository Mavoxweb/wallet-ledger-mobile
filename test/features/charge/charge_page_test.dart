import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/features/charge/charge_page.dart';
import 'package:wallet_ledger_mobile/features/charge/data/charge_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';

import '../../helpers/fakes.dart';

Future<FakeChargeRepository> _pump(WidgetTester tester) async {
  final charges = FakeChargeRepository();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<KeysRepository>.value(value: FakeKeysRepository()),
          RepositoryProvider<ChargeRepository>.value(value: charges),
        ],
        child: const ChargePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return charges;
}

void main() {
  testWidgets('gera o QR com a chave escolhida e valor livre', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final charges = await _pump(tester);

    await tester.tap(find.text('Gerar QR code'));
    await tester.pumpAndSettle();

    expect(charges.requests.single, ('k1', null));
    expect(find.text('Valor livre'), findsOneWidget);
    expect(find.bySemanticsLabel('QR code Pix para receber'), findsOneWidget);
  });

  testWidgets('copiar põe o código na área de transferência e avisa', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    await _pump(tester);
    await tester.tap(find.text('Gerar QR code'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Copiar código'));
    await tester.pump();

    expect(copied, FakeChargeRepository.payload);
    expect(find.text('Código Pix copiado'), findsOneWidget);
  });

  testWidgets('trocar a chave pede um QR novo', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final charges = await _pump(tester);

    await tester.tap(find.text('aleatória'));
    await tester.pump();
    await tester.tap(find.text('Gerar QR code'));
    await tester.pumpAndSettle();

    expect(charges.requests.single, ('k2', null));
  });
}
