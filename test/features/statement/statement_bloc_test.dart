import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/statement/presentation/bloc/statement_bloc.dart';

import '../../helpers/fakes.dart';

void main() {
  group('StatementBloc', () {
    blocTest<StatementBloc, StatementState>(
      'junta as páginas sem repetir e para quando o cursor é nulo',
      build: () => StatementBloc(
        accounts: PagedAccountRepository({
          null: page([30, 20], next: 'c1'),
          // A página 2 repete o 20: não pode aparecer duas vezes.
          'c1': page([20, 10], next: null),
        }),
      ),
      act: (bloc) async {
        bloc.add(const StatementStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const StatementNextPageRequested());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.items.map((m) => m.postingId), [30, 20, 10]);
        expect(bloc.state.hasReachedEnd, isTrue);
        expect(bloc.state.nextCursor, isNull);
      },
    );

    test('pedir a próxima página duas vezes seguidas busca uma vez', () async {
      final gate = Completer<void>();
      final accounts = PagedAccountRepository(
        {
          null: page([30], next: 'c1'),
          'c1': page([20], next: 'c2'),
        },
        hold: {'c1': gate},
      );
      final bloc = StatementBloc(accounts: accounts)
        ..add(const StatementStarted());
      await Future<void>.delayed(Duration.zero);

      bloc
        ..add(const StatementNextPageRequested())
        ..add(const StatementNextPageRequested());
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      await Future<void>.delayed(Duration.zero);

      expect(accounts.calls.where((c) => c == 'c1').length, 1);
      expect(bloc.state.items.map((m) => m.postingId), [30, 20]);
      await bloc.close();
    });

    blocTest<StatementBloc, StatementState>(
      'filtro de entradas mostra só o que entrou',
      build: () => StatementBloc(accounts: FakeAccountRepository()),
      act: (bloc) async {
        bloc.add(const StatementStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const StatementFilterChanged(StatementFilter.incoming));
      },
      verify: (bloc) {
        expect(bloc.state.visible.every((m) => m.isIncoming), isTrue);
        expect(bloc.state.visible.length, 2);
        // O filtro não joga fora o que já foi carregado.
        expect(bloc.state.items.length, 3);
      },
    );

    blocTest<StatementBloc, StatementState>(
      'falha na primeira página vira erro de tela',
      build: () => StatementBloc(
        accounts: FakeAccountRepository(failure: const NetworkFailure()),
      ),
      act: (bloc) => bloc.add(const StatementStarted()),
      verify: (bloc) {
        expect(bloc.state.status, StatementStatus.failure);
        expect(bloc.state.failure, const NetworkFailure());
      },
    );

    blocTest<StatementBloc, StatementState>(
      'falha ao carregar mais mantém a lista e permite tentar de novo',
      build: () => StatementBloc(
        accounts: PagedAccountRepository(
          {
            null: page([30], next: 'c1'),
          },
          failOn: {'c1'},
        ),
      ),
      act: (bloc) async {
        bloc.add(const StatementStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const StatementNextPageRequested());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.status, StatementStatus.ready);
        expect(bloc.state.items.length, 1);
        expect(bloc.state.loadMoreFailed, isTrue);
        expect(bloc.state.hasReachedEnd, isFalse);
      },
    );

    blocTest<StatementBloc, StatementState>(
      'atualizar troca a lista pela primeira página nova',
      build: () => StatementBloc(
        accounts: PagedAccountRepository({
          null: page([30], next: null),
        }),
      ),
      seed: () => StatementState(
        status: StatementStatus.ready,
        items: page([5], next: null).items,
        hasReachedEnd: true,
      ),
      act: (bloc) => bloc.add(const StatementRefreshed()),
      verify: (bloc) {
        expect(bloc.state.items.map((m) => m.postingId), [30]);
      },
    );
  });
}
