import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/charge_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

enum ChargeStatus { loading, ready, failure }

class ChargeState extends Equatable {
  const new({
    this.status = ChargeStatus.loading,
    this.keys = const [],
    this.selectedKeyId,
    this.amountCents,
    this.generating = false,
    this.payload,
    this.failure,
  });

  final ChargeStatus status;
  final List<PixKeyItem> keys;
  final String? selectedKeyId;

  /// Nulo = valor livre (quem paga escolhe).
  final int? amountCents;
  final bool generating;

  /// O "Pix Copia e Cola" gerado. Nulo enquanto está no formulário.
  final String? payload;
  final Failure? failure;

  PixKeyItem? get selectedKey {
    for (final k in keys) {
      if (k.id == selectedKeyId) return k;
    }
    return null;
  }

  ChargeState copyWith({
    ChargeStatus? status,
    List<PixKeyItem>? keys,
    String? selectedKeyId,
    int? Function()? amountCents,
    bool? generating,
    String? Function()? payload,
    Failure? Function()? failure,
  }) => ChargeState(
    status: status ?? this.status,
    keys: keys ?? this.keys,
    selectedKeyId: selectedKeyId ?? this.selectedKeyId,
    amountCents: amountCents != null ? amountCents() : this.amountCents,
    generating: generating ?? this.generating,
    payload: payload != null ? payload() : this.payload,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    keys,
    selectedKeyId,
    amountCents,
    generating,
    payload,
    failure,
  ];
}

class ChargeCubit extends Cubit<ChargeState> {
  new({required this._keys, required this._charges})
    : super(const ChargeState());

  final KeysRepository _keys;
  final ChargeRepository _charges;

  Future<void> load() async {
    emit(const ChargeState());
    try {
      final keys = await _keys.list();
      emit(
        ChargeState(
          status: ChargeStatus.ready,
          keys: keys,
          selectedKeyId: keys.isEmpty ? null : keys.first.id,
        ),
      );
    } on Failure catch (failure) {
      emit(ChargeState(status: ChargeStatus.failure, failure: failure));
    }
  }

  void selectKey(String id) => emit(
    state.copyWith(selectedKeyId: id, payload: () => null, failure: () => null),
  );

  void setAmount(int? cents) => emit(
    state.copyWith(
      amountCents: () => cents,
      payload: () => null,
      failure: () => null,
    ),
  );

  Future<void> generate() async {
    final keyId = state.selectedKeyId;
    if (keyId == null || state.generating) return;
    emit(state.copyWith(generating: true, failure: () => null));
    try {
      final payload = await _charges.create(
        keyId: keyId,
        amountCents: state.amountCents,
      );
      emit(state.copyWith(generating: false, payload: () => payload));
    } on Failure catch (failure) {
      emit(state.copyWith(generating: false, failure: () => failure));
    }
  }

  /// Volta ao formulário, mantendo a chave e o valor escolhidos.
  void newCharge() => emit(state.copyWith(payload: () => null));
}
