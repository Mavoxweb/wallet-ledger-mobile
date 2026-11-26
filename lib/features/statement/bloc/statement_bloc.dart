import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';

// ---------------------------------------------------------------- eventos

sealed class StatementEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Abriu a tela: carrega a primeira página.
final class StatementStarted extends StatementEvent {
  const new();
}

/// Chegou perto do fim da lista: pede a próxima página.
final class StatementNextPageRequested extends StatementEvent {
  const new();
}

/// Puxou para atualizar: busca a primeira página de novo, sem piscar.
///
/// [done] avisa a tela quando acabou, para o indicador parar de girar. Não dá
/// para esperar "o próximo estado": se nada mudou, o Bloc não emite nenhum.
final class StatementRefreshed extends StatementEvent {
  const new({this.done});

  final Completer<void>? done;
}

final class StatementFilterChanged extends StatementEvent {
  const new(this.filter);

  final StatementFilter filter;

  @override
  List<Object?> get props => [filter];
}

// ---------------------------------------------------------------- estado

enum StatementFilter { all, incoming, outgoing }

enum StatementStatus { loading, ready, failure }

class StatementState extends Equatable {
  const new({
    this.status = StatementStatus.loading,
    this.items = const [],
    this.nextCursor,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.loadMoreFailed = false,
    this.filter = StatementFilter.all,
    this.failure,
  });

  final StatementStatus status;

  /// Tudo o que já foi carregado, sem filtro.
  final List<Movement> items;

  /// Cursor da próxima página, como a API devolveu.
  final String? nextCursor;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  /// A última tentativa de carregar mais falhou: a lista continua na tela e
  /// aparece um "Tentar de novo" no rodapé.
  final bool loadMoreFailed;
  final StatementFilter filter;

  /// Falha da primeira página (tela de erro).
  final Failure? failure;

  /// O que a tela mostra: o filtro roda aqui, sobre o que já foi carregado.
  List<Movement> get visible => switch (filter) {
    StatementFilter.all => items,
    StatementFilter.incoming => [
      for (final m in items)
        if (m.isIncoming) m,
    ],
    StatementFilter.outgoing => [
      for (final m in items)
        if (!m.isIncoming) m,
    ],
  };

  /// Pode buscar mais agora? Esta é a proteção contra página duplicada.
  bool get canLoadMore =>
      status == StatementStatus.ready && !isLoadingMore && !hasReachedEnd;

  StatementState copyWith({
    StatementStatus? status,
    List<Movement>? items,
    String? Function()? nextCursor,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    bool? loadMoreFailed,
    StatementFilter? filter,
    Failure? Function()? failure,
  }) => StatementState(
    status: status ?? this.status,
    items: items ?? this.items,
    // Funções para poder trocar por `null` de propósito.
    nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    filter: filter ?? this.filter,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    nextCursor,
    isLoadingMore,
    hasReachedEnd,
    loadMoreFailed,
    filter,
    failure,
  ];
}

// ---------------------------------------------------------------- bloc

class StatementBloc extends Bloc<StatementEvent, StatementState> {
  new({required this._accounts, Stream<void>? accountChanges})
    : super(const StatementState()) {
    _changes = accountChanges?.listen((_) => add(const StatementRefreshed()));
    on<StatementStarted>(_onStarted);
    on<StatementRefreshed>(_onRefreshed);
    on<StatementNextPageRequested>(_onNextPage);
    on<StatementFilterChanged>(
      (event, emit) => emit(state.copyWith(filter: event.filter)),
    );
  }

  final AccountRepository _accounts;
  StreamSubscription<void>? _changes;

  @override
  Future<void> close() async {
    await _changes?.cancel();
    await super.close();
  }

  static const pageSize = 20;

  Future<void> _onStarted(
    StatementStarted event,
    Emitter<StatementState> emit,
  ) async {
    emit(StatementState(filter: state.filter));
    try {
      final first = await _accounts.statement();
      emit(_firstPage(first));
    } on Failure catch (failure) {
      emit(
        state.copyWith(status: StatementStatus.failure, failure: () => failure),
      );
    }
  }

  Future<void> _onRefreshed(
    StatementRefreshed event,
    Emitter<StatementState> emit,
  ) async {
    try {
      final first = await _accounts.statement();
      emit(_firstPage(first));
    } on Failure catch (failure) {
      // Com lista na tela, uma falha ao atualizar não apaga nada.
      if (state.status != StatementStatus.ready) {
        emit(
          state.copyWith(
            status: StatementStatus.failure,
            failure: () => failure,
          ),
        );
      }
    } finally {
      event.done?.complete();
    }
  }

  Future<void> _onNextPage(
    StatementNextPageRequested event,
    Emitter<StatementState> emit,
  ) async {
    // O segundo pedido chega enquanto o primeiro ainda espera a rede: o
    // `isLoadingMore` já está ligado e ele é ignorado.
    if (!state.canLoadMore) return;
    emit(state.copyWith(isLoadingMore: true, loadMoreFailed: false));

    try {
      final next = await _accounts.statement(cursor: state.nextCursor);
      // Por segurança, não repete um lançamento que já está na lista.
      final seen = {for (final m in state.items) m.postingId};
      emit(
        state.copyWith(
          items: [
            ...state.items,
            for (final m in next.items)
              if (seen.add(m.postingId)) m,
          ],
          nextCursor: () => next.nextCursor,
          hasReachedEnd: next.nextCursor == null,
          isLoadingMore: false,
        ),
      );
    } on Failure {
      emit(state.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  StatementState _firstPage(MovementPage page) => StatementState(
    status: StatementStatus.ready,
    items: page.items,
    nextCursor: page.nextCursor,
    hasReachedEnd: page.nextCursor == null,
    filter: state.filter,
  );
}
