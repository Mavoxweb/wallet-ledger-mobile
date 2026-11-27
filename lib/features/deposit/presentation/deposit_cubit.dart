import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/ids/uuid.dart';
import 'package:wallet_ledger_mobile/features/deposit/domain/deposit_repository.dart';

sealed class DepositState extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class DepositIdle extends DepositState {
  const new();
}

final class DepositSending extends DepositState {
  const new(this.amountCents);

  final int amountCents;

  @override
  List<Object?> get props => [amountCents];
}

final class DepositDone extends DepositState {
  const new({required this.amountCents, required this.balanceCents});

  final int amountCents;
  final int balanceCents;

  @override
  List<Object?> get props => [amountCents, balanceCents];
}

final class DepositFailed extends DepositState {
  const new({required this.amountCents, required this.failure});

  final int amountCents;
  final Failure failure;

  @override
  List<Object?> get props => [amountCents, failure];
}

/// Depósito simulado, com a mesma regra do Pix: a `Idempotency-Key` fica
/// presa ao valor. Tentar de novo o mesmo valor reusa a chave (nunca deposita
/// duas vezes); outro valor é outro depósito e ganha chave nova.
class DepositCubit extends Cubit<DepositState> {
  new({required this._deposits, String Function()? newIdempotencyKey})
    : _newKey = newIdempotencyKey ?? uuidV4,
      super(const DepositIdle());

  final DepositRepository _deposits;
  final String Function() _newKey;

  /// Teto da API por depósito: R$ 1.000,00.
  static const maxCents = 100000;

  int? _lastAmount;
  String? _lastKey;

  Future<void> submit(int amountCents) async {
    if (state is DepositSending) return;
    if (amountCents <= 0 || amountCents > maxCents) return;

    if (amountCents != _lastAmount || _lastKey == null) {
      _lastAmount = amountCents;
      _lastKey = _newKey();
    }

    emit(DepositSending(amountCents));
    try {
      final balance = await _deposits.simulated(
        amountCents: amountCents,
        idempotencyKey: _lastKey!,
      );
      // Concluído: o próximo depósito, mesmo de igual valor, é outro.
      _lastKey = null;
      emit(DepositDone(amountCents: amountCents, balanceCents: balance));
    } on Failure catch (failure) {
      emit(DepositFailed(amountCents: amountCents, failure: failure));
    }
  }
}
