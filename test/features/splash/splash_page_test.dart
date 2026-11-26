import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/features/splash/splash_page.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('sem sessão, a entrada termina no login', (tester) async {
    await pumpApp(tester, repository: authRepository(hasSession: false));
    await finishIntro(tester);

    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('a entrada espera a sessão mesmo depois da animação', (
    tester,
  ) async {
    final check = Completer<bool>();
    await pumpApp(tester, repository: authRepository(sessionCheck: check));

    await tester.pump(AppMotion.intro + const Duration(milliseconds: 300));
    expect(find.byType(SplashPage), findsOneWidget);

    check.complete(false);
    await tester.pumpAndSettle();
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('com sessão e biometria disponível, pede a biometria e entra', (
    tester,
  ) async {
    final biometrics = FakeBiometricGate(available: true);
    await pumpApp(tester, repository: authRepository(), biometrics: biometrics);
    await finishIntro(tester);

    expect(biometrics.asked, 1);
    expect(find.text('Últimas movimentações'), findsOneWidget);
  });

  testWidgets('biometria cancelada oferece entrar com senha', (tester) async {
    final biometrics = FakeBiometricGate(available: true, approve: false);
    final repository = authRepository();
    await pumpApp(tester, repository: repository, biometrics: biometrics);
    await finishIntro(tester);

    expect(find.text('Entrar com senha'), findsOneWidget);
    await tester.tap(find.text('Entrar com senha'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('sem biometria no aparelho, entra direto', (tester) async {
    final biometrics = FakeBiometricGate();
    await pumpApp(tester, repository: authRepository(), biometrics: biometrics);
    await finishIntro(tester);

    expect(biometrics.asked, 0);
    expect(find.byType(SplashPage), findsNothing);
  });
}
