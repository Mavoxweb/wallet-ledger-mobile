import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/add_pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/list_pix_keys.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/remove_pix_key.dart';

enum KeysStatus { loading, ready, failure }

class KeysState extends Equatable {
  const new({
    this.status = KeysStatus.loading,
    this.keys = const [],
    this.busy = false,
    this.failure,
    this.deleteFailure,
  });

  final KeysStatus status;
  final List<PixKeyItem> keys;

  /// Cadastrando ou removendo.
  final bool busy;

  /// Falha do carregamento (status `failure`) ou do último cadastro, que
  /// aparece dentro da folha de cadastro.
  final Failure? failure;

  /// Falha ao remover, que aparece na própria tela de chaves.
  final Failure? deleteFailure;

  bool get atLimit => keys.length >= AddPixKey.maxKeys;

  @override
  List<Object?> get props => [status, keys, busy, failure, deleteFailure];
}

class KeysCubit extends Cubit<KeysState> {
  new({required this._list, required this._add, required this._remove})
    : super(const KeysState());

  final ListPixKeys _list;
  final AddPixKey _add;
  final RemovePixKey _remove;

  Future<void> load() async {
    emit(const KeysState());
    try {
      emit(KeysState(status: KeysStatus.ready, keys: await _list()));
    } on Failure catch (failure) {
      emit(KeysState(status: KeysStatus.failure, failure: failure));
    }
  }

  /// Cadastra e devolve se deu certo (a folha fecha só nesse caso).
  Future<bool> create(PixKeyKind kind, String? value) async {
    if (state.busy) return false;
    emit(_ready(busy: true));
    try {
      final key = await _add(kind, value, currentCount: state.keys.length);
      emit(_ready(keys: [...state.keys, key]));
      return true;
    } on Failure catch (failure) {
      emit(_ready(failure: failure));
      return false;
    }
  }

  /// Remove. A confirmação é da tela: o Cubit só executa.
  Future<void> delete(String id) async {
    if (state.busy) return;
    emit(_ready(busy: true));
    try {
      await _remove(id);
      emit(
        _ready(
          keys: [
            for (final k in state.keys)
              if (k.id != id) k,
          ],
        ),
      );
    } on Failure catch (failure) {
      emit(_ready(deleteFailure: failure));
    }
  }

  void clearFailure() => emit(_ready());

  KeysState _ready({
    List<PixKeyItem>? keys,
    bool busy = false,
    Failure? failure,
    Failure? deleteFailure,
  }) => KeysState(
    status: KeysStatus.ready,
    keys: keys ?? state.keys,
    busy: busy,
    failure: failure,
    deleteFailure: deleteFailure,
  );
}
