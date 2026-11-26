import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';

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

  bool get atLimit => keys.length >= KeysCubit.maxKeys;

  @override
  List<Object?> get props => [status, keys, busy, failure, deleteFailure];
}

class KeysCubit extends Cubit<KeysState> {
  new({required this._keys}) : super(const KeysState());

  final KeysRepository _keys;

  /// Limite do Banco Central para pessoa física: 5 chaves por conta.
  static const maxKeys = 5;

  /// A mesma falha que a API daria, para o limite ser avisado sem chamada.
  static const limitFailure = ApiFailure(
    code: 'pix_key_limit',
    message: '',
    status: 422,
  );

  Future<void> load() async {
    emit(const KeysState());
    try {
      emit(KeysState(status: KeysStatus.ready, keys: await _keys.list()));
    } on Failure catch (failure) {
      emit(KeysState(status: KeysStatus.failure, failure: failure));
    }
  }

  /// Cadastra e devolve se deu certo (a folha fecha só nesse caso).
  Future<bool> create(PixKeyKind kind, String? value) async {
    if (state.busy) return false;
    if (state.atLimit) {
      // Já sabemos a resposta: nem chama a API.
      emit(_ready(failure: limitFailure));
      return false;
    }
    emit(_ready(busy: true));
    try {
      final key = await _keys.create(kind, value);
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
      await _keys.delete(id);
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
