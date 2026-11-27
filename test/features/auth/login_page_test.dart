import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/login/login_page.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

Widget _app(AuthRepository repository) =>
    RepositoryProvider<AuthRepository>.value(
      value: repository,
      child: BlocProvider(
        create: (_) => SessionBloc(repository),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

void main() {
  testWidgets('e-mail ou senha errados mostram a mensagem certa', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(
      const ApiFailure(code: 'invalid_credentials', message: 'x', status: 401),
    );

    await tester.pumpWidget(_app(repository));
    await tester.enterText(
      find.bySemanticsLabel('E-mail'),
      'ana@walletledger.dev',
    );
    await tester.enterText(find.bySemanticsLabel('Senha'), 'errada123');
    // Redesenha com o estado novo: só então o botão fica habilitado.
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(
      find.text('E-mail ou senha incorretos. Confira e tente de novo.'),
      findsOneWidget,
    );
  });

  testWidgets('botão Entrar fica desabilitado com campos vazios', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_MockAuthRepository()));

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Entrar'),
    );
    expect(button.onPressed, isNull);
  });
}
