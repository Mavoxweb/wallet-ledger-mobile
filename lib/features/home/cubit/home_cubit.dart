import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/storage/prefs_store.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';

sealed class HomeState extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class HomeLoading extends HomeState {
  const new();
}

final class HomeLoaded extends HomeState {
  const new({
    required this.account,
    required this.recent,
    required this.keys,
    required this.balanceHidden,
  });

  final AccountSummary account;
  final List<Movement> recent;
  final List<PixKeyItem> keys;
  final bool balanceHidden;

  int get keyCount => keys.length;

  HomeLoaded copyWith({bool? balanceHidden}) => HomeLoaded(
    account: account,
    recent: recent,
    keys: keys,
    balanceHidden: balanceHidden ?? this.balanceHidden,
  );

  @override
  List<Object?> get props => [account, recent, keys, balanceHidden];
}

final class HomeError extends HomeState {
  const new(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class HomeCubit extends Cubit<HomeState> {
  new({
    required this._accounts,
    required this._keys,
    required this._prefs,
    Stream<void>? accountChanges,
  }) : super(const HomeLoading()) {
    // Depois de um Pix, atualiza sem voltar ao esqueleto.
    _changes = accountChanges?.listen((_) => refresh());
  }

  StreamSubscription<void>? _changes;

  @override
  Future<void> close() async {
    await _changes?.cancel();
    await super.close();
  }

  final AccountRepository _accounts;
  final KeysRepository _keys;
  final PrefsStore _prefs;

  static const recentCount = 3;

  Future<void> load() async {
    emit(const HomeLoading());
    await _fetch();
  }

  /// Puxar para atualizar: busca de novo sem voltar ao "carregando", para a
  /// tela não piscar. Se falhar, mantém o que já estava na tela.
  Future<void> refresh() => _fetch(keepOnFailure: true);

  Future<void> toggleBalance() async {
    final current = state;
    if (current is! HomeLoaded) return;
    final hidden = !current.balanceHidden;
    emit(current.copyWith(balanceHidden: hidden));
    await _prefs.setBalanceHidden(hidden: hidden);
  }

  Future<void> _fetch({bool keepOnFailure = false}) async {
    try {
      // As quatro buscas saem ao mesmo tempo; o record espera todas.
      final (account, page, keys, hidden) = await (
        _accounts.account(),
        _accounts.statement(limit: recentCount),
        _keys.list(),
        _prefs.balanceHidden(),
      ).wait;

      emit(
        HomeLoaded(
          account: account,
          recent: page.items,
          keys: keys,
          balanceHidden: hidden,
        ),
      );
      // `.wait` num record dispara as buscas juntas e, se alguma falhar,
      // agrupa os erros num ParallelWaitError. Pegar esse Error aqui é o uso
      // documentado da API; dentro dele está a nossa Failure.
      // ignore: avoid_catching_errors
    } on ParallelWaitError<dynamic, dynamic> catch (e) {
      final failure = _firstFailure(e) ?? const NetworkFailure();
      if (!(keepOnFailure && state is HomeLoaded)) emit(HomeError(failure));
    } on Failure catch (failure) {
      if (!(keepOnFailure && state is HomeLoaded)) emit(HomeError(failure));
    }
  }

  static Failure? _firstFailure(ParallelWaitError<dynamic, dynamic> e) {
    final errors = e.errors;
    if (errors is (Object?, Object?, Object?, Object?)) {
      for (final error in [errors.$1, errors.$2, errors.$3, errors.$4]) {
        if (error is AsyncError && error.error is Failure) {
          return error.error as Failure;
        }
      }
    }
    return null;
  }
}
