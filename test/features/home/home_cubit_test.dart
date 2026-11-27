import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/account/domain/usecases/get_account.dart';
import 'package:wallet_ledger_mobile/features/account/domain/usecases/get_statement.dart';
import 'package:wallet_ledger_mobile/features/home/presentation/cubit/home_cubit.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/list_pix_keys.dart';

import '../../helpers/fakes.dart';

void main() {
  blocTest<HomeCubit, HomeState>(
    'carrega saldo, 3 movimentações e as chaves Pix',
    build: () => HomeCubit(
      getAccount: GetAccount(FakeAccountRepository()),
      getStatement: GetStatement(FakeAccountRepository()),
      listKeys: ListPixKeys(FakeKeysRepository()),
      prefs: InMemoryPrefsStore(),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [
      const HomeLoading(),
      isA<HomeLoaded>()
          .having((s) => s.account.balanceCents, 'saldo', 247410)
          .having((s) => s.recent.length, 'recentes', 3)
          .having((s) => s.keyCount, 'chaves', 2)
          .having((s) => s.balanceHidden, 'oculto', false),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'ocultar o saldo lembra a preferência',
    build: () => HomeCubit(
      getAccount: GetAccount(FakeAccountRepository()),
      getStatement: GetStatement(FakeAccountRepository()),
      listKeys: ListPixKeys(FakeKeysRepository()),
      prefs: prefs,
    ),
    act: (cubit) async {
      await cubit.load();
      await cubit.toggleBalance();
    },
    skip: 2,
    expect: () => [
      isA<HomeLoaded>().having((s) => s.balanceHidden, 'oculto', true),
    ],
    verify: (_) async => expect(await prefs.balanceHidden(), isTrue),
  );

  blocTest<HomeCubit, HomeState>(
    'falha ao carregar mostra o erro',
    build: () => HomeCubit(
      getAccount: GetAccount(
        FakeAccountRepository(failure: const NetworkFailure()),
      ),
      getStatement: GetStatement(
        FakeAccountRepository(failure: const NetworkFailure()),
      ),
      listKeys: ListPixKeys(FakeKeysRepository()),
      prefs: InMemoryPrefsStore(),
    ),
    act: (cubit) => cubit.load(),
    expect: () => [const HomeLoading(), const HomeError(NetworkFailure())],
  );

  test('atualizar consulta de novo sem passar pelo carregando', () async {
    final accounts = FakeAccountRepository();
    final cubit = HomeCubit(
      getAccount: GetAccount(accounts),
      getStatement: GetStatement(accounts),
      listKeys: ListPixKeys(FakeKeysRepository()),
      prefs: InMemoryPrefsStore(),
    );
    final states = <HomeState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.load();
    await cubit.refresh();
    await subscription.cancel();

    // Dados iguais não geram estado novo (o Bloc ignora estados repetidos),
    // e o mais importante: nenhum HomeLoading no meio da atualização.
    expect(states.whereType<HomeLoading>(), hasLength(1));
    expect(cubit.state, isA<HomeLoaded>());
    expect(accounts.accountCalls, 2);
  });
}

final prefs = InMemoryPrefsStore();
