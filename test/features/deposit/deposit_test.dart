import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/features/deposit/domain/usecases/make_simulated_deposit.dart';
import 'package:wallet_ledger_mobile/features/deposit/presentation/deposit_cubit.dart';
import 'package:wallet_ledger_mobile/features/deposit/presentation/deposit_sheet.dart';

import '../../helpers/fakes.dart';

String Function() _keys() {
  var n = 0;
  return () => 'dep-${++n}';
}

void main() {
  group('DepositCubit', () {
    test('tentar de novo o mesmo valor reusa a chave', () async {
      final repository = FakeDepositRepository(
        failures: [const NetworkFailure()],
      );
      final cubit = DepositCubit(
        deposit: MakeSimulatedDeposit(repository),
        newIdempotencyKey: _keys(),
      );

      await cubit.submit(5000);
      expect(cubit.state, isA<DepositFailed>());
      await cubit.submit(5000);

      expect(cubit.state, isA<DepositDone>());
      expect(repository.calls, [(5000, 'dep-1'), (5000, 'dep-1')]);
      await cubit.close();
    });

    test('outro valor é outro depósito, com chave nova', () async {
      final repository = FakeDepositRepository(
        failures: [const NetworkFailure()],
      );
      final cubit = DepositCubit(
        deposit: MakeSimulatedDeposit(repository),
        newIdempotencyKey: _keys(),
      );

      await cubit.submit(5000);
      await cubit.submit(6000);

      expect(repository.calls.map((c) => c.$2), ['dep-1', 'dep-2']);
      await cubit.close();
    });

    test(r'acima de R$ 1.000,00 nem chega na API', () async {
      final repository = FakeDepositRepository();
      final cubit = DepositCubit(deposit: MakeSimulatedDeposit(repository));

      await cubit.submit(100001);

      expect(repository.calls, isEmpty);
      expect(cubit.state, isA<DepositIdle>());
      await cubit.close();
    });
  });

  testWidgets(r'na folha, acima de R$ 1.000,00 o botão desliga e avisa', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = FakeDepositRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: BlocProvider(
            create: (_) =>
                DepositCubit(deposit: MakeSimulatedDeposit(repository)),
            child: const DepositSheet(),
          ),
        ),
      ),
    );

    // 1000,01 = 100001 centavos.
    for (final d in '100001'.split('')) {
      await tester.tap(find.byKey(ValueKey('key-$d')));
      await tester.pump();
    }

    expect(find.textContaining('aceita até'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Depositar'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(repository.calls, isEmpty);
  });
}
