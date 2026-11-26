import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_ledger_mobile/app/app.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

import 'fakes.dart';

class MockAuthRepository extends Mock implements AuthRepository;

/// Biometria controlada pelo teste.
class FakeBiometricGate implements BiometricGate {
  new({this.available = false, this.approve = true});

  bool available;
  bool approve;
  int asked = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> confirm(String reason) async {
    asked++;
    return approve;
  }
}

const anaMe = Me(
  userId: 'u1',
  name: 'Ana Beatriz Lima',
  role: 'Customer',
  accountId: 'a1',
);

/// Repositório com ou sem sessão salva.
MockAuthRepository authRepository({
  bool hasSession = true,
  Completer<bool>? sessionCheck,
}) {
  final repository = MockAuthRepository();
  when(repository.hasSession)
      .thenAnswer((_) => sessionCheck?.future ?? Future.value(hasSession));
  when(repository.me).thenAnswer((_) async => anaMe);
  when(repository.logout).thenAnswer((_) async {});
  when(repository.clearSession).thenAnswer((_) async {});
  return repository;
}

/// Sobe o app inteiro, como o usuário veria.
Future<void> pumpApp(
  WidgetTester tester, {
  required AuthRepository repository,
  BiometricGate? biometrics,
  double textScale = 1,
  bool reduceMotion = false,
  FakeAccountRepository? accounts,
}) async {
  final session = SessionBloc(repository)..add(const SessionStarted());
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        textScaler: TextScaler.linear(textScale),
        disableAnimations: reduceMotion,
      ),
      child: WalletLedgerApp(
        authRepository: repository,
        sessionBloc: session,
        biometricGate: biometrics ?? FakeBiometricGate(),
        accountRepository: accounts ?? FakeAccountRepository(),
        keysRepository: FakeKeysRepository(),
        pixRepository: FakePixRepository(),
        chargeRepository: FakeChargeRepository(),
        prefsStore: InMemoryPrefsStore(),
      ),
    ),
  );
}

/// Deixa a animação de entrada terminar e o app assentar.
Future<void> finishIntro(WidgetTester tester) async {
  await tester.pump(AppMotion.intro);
  await tester.pumpAndSettle();
}
