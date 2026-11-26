import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_ledger_mobile/app/app.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

void main() {
  testWidgets('sem sessão salva, o app abre no login', (tester) async {
    final repository = _MockAuthRepository();
    when(repository.hasSession).thenAnswer((_) async => false);
    final session = SessionBloc(repository)..add(const SessionStarted());

    await tester.pumpWidget(
      WalletLedgerApp(authRepository: repository, sessionBloc: session),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Wallet Ledger'), findsOneWidget);
  });
}
