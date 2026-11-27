import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/use_case_scope.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/add_pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/presentation/keys_page.dart';

import '../../helpers/blocs.dart';
import '../../helpers/fakes.dart';

List<PixKeyItem> _five() => [
  for (var i = 1; i <= 5; i++)
    PixKeyItem(id: 'k$i', kind: PixKeyKind.evp, value: 'evp-$i'),
];

Future<void> _pump(WidgetTester tester, FakeKeysRepository keys) async {
  await tester.binding.setSurfaceSize(const Size(400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: UseCaseScope(keys: keys, child: const KeysPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('KeysCubit', () {
    test('a sexta chave mostra o limite sem chamar a API', () async {
      final repository = FakeKeysRepository(keys: _five());
      final cubit = keysCubitFor(repository);
      await cubit.load();

      final ok = await cubit.create(PixKeyKind.evp, null);

      expect(ok, isFalse);
      expect(cubit.state.failure, AddPixKey.limitFailure);
      expect(repository.created, isEmpty);
      await cubit.close();
    });

    test('chave já cadastrada em outra conta vira erro na tela', () async {
      const taken = ApiFailure(code: 'pix_key_taken', message: '', status: 409);
      final cubit = keysCubitFor(FakeKeysRepository(createFailure: taken));
      await cubit.load();

      final ok = await cubit.create(PixKeyKind.email, 'bruno@walletledger.dev');

      expect(ok, isFalse);
      expect(cubit.state.failure, taken);
      expect(cubit.state.keys.length, 2);
      await cubit.close();
    });

    test('cadastrar acrescenta na lista', () async {
      final cubit = keysCubitFor(FakeKeysRepository());
      await cubit.load();

      expect(await cubit.create(PixKeyKind.evp, null), isTrue);
      expect(cubit.state.keys.length, 3);
      await cubit.close();
    });
  });

  group('KeysPage', () {
    testWidgets('remover pede confirmação antes', (tester) async {
      final repository = FakeKeysRepository();
      await _pump(tester, repository);

      await tester.tap(find.byTooltip('Remover chave').first);
      await tester.pumpAndSettle();

      expect(find.text('Remover esta chave?'), findsOneWidget);
      expect(repository.deleted, isEmpty);

      await tester.tap(find.text('Manter chave'));
      await tester.pumpAndSettle();
      expect(repository.deleted, isEmpty);

      await tester.tap(find.byTooltip('Remover chave').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover chave'));
      await tester.pumpAndSettle();

      expect(repository.deleted, ['k1']);
      expect(find.text('ana@walletledger.dev'), findsNothing);
    });

    testWidgets('com 5 chaves, cadastrar fica desligado e explica', (
      tester,
    ) async {
      await _pump(tester, FakeKeysRepository(keys: _five()));

      expect(find.textContaining('limite de 5 chaves'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Cadastrar chave'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('e-mail inválido é avisado na folha, sem chamar a API', (
      tester,
    ) async {
      final repository = FakeKeysRepository();
      await _pump(tester, repository);

      await tester.tap(find.text('Cadastrar chave'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ana@');
      await tester.tap(find.text('Cadastrar chave').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('e-mail válido'), findsOneWidget);
      expect(repository.created, isEmpty);
    });
  });
}
