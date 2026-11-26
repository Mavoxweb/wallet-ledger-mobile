import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

class _MockAuthRepository extends Mock implements AuthRepository;

const _me = Me(
  userId: 'u1',
  name: 'Ana Beatriz Lima',
  role: 'Customer',
  accountId: 'a1',
);

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.clearSession()).thenAnswer((_) async {});
    when(() => repository.logout()).thenAnswer((_) async {});
  });

  blocTest<SessionBloc, SessionState>(
    'sessão guardada e /me ok: autenticado',
    setUp: () {
      when(() => repository.hasSession()).thenAnswer((_) async => true);
      when(() => repository.me()).thenAnswer((_) async => _me);
    },
    build: () => SessionBloc(repository),
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [const SessionAuthenticated(_me)],
  );

  blocTest<SessionBloc, SessionState>(
    'sem sessão guardada: não autenticado',
    setUp: () =>
        when(() => repository.hasSession()).thenAnswer((_) async => false),
    build: () => SessionBloc(repository),
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [const SessionUnauthenticated()],
  );

  blocTest<SessionBloc, SessionState>(
    'sessão guardada mas /me falha: limpa e não autenticado',
    setUp: () {
      when(() => repository.hasSession()).thenAnswer((_) async => true);
      when(() => repository.me()).thenThrow(const NetworkFailure());
    },
    build: () => SessionBloc(repository),
    act: (bloc) => bloc.add(const SessionStarted()),
    expect: () => [const SessionUnauthenticated()],
    verify: (_) => verify(() => repository.clearSession()).called(1),
  );

  blocTest<SessionBloc, SessionState>(
    'login concluído: busca o perfil e autentica',
    setUp: () => when(() => repository.me()).thenAnswer((_) async => _me),
    build: () => SessionBloc(repository),
    act: (bloc) => bloc.add(const SessionLoggedIn()),
    expect: () => [const SessionAuthenticated(_me)],
  );

  blocTest<SessionBloc, SessionState>(
    'sessão expirada: limpa e não autenticado',
    build: () => SessionBloc(repository),
    seed: () => const SessionAuthenticated(_me),
    act: (bloc) => bloc.add(const SessionExpired()),
    expect: () => [const SessionUnauthenticated()],
    verify: (_) => verify(() => repository.clearSession()).called(1),
  );

  blocTest<SessionBloc, SessionState>(
    'sair: faz logout na API e não autenticado',
    build: () => SessionBloc(repository),
    seed: () => const SessionAuthenticated(_me),
    act: (bloc) => bloc.add(const SessionLoggedOut()),
    expect: () => [const SessionUnauthenticated()],
    verify: (_) => verify(() => repository.logout()).called(1),
  );
}
