import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/ids/uuid.dart';
import 'package:wallet_ledger_mobile/core/money/amount_input.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_key_detector.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_transfer.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/usecases/lookup_pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/usecases/send_pix.dart';

sealed class PixEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class KeySubmitted extends PixEvent {
  const new(this.raw);

  final String raw;

  @override
  List<Object?> get props => [raw];
}

final class DescriptionChanged extends PixEvent {
  const new(this.description);

  final String description;

  @override
  List<Object?> get props => [description];
}

final class AmountSubmitted extends PixEvent {
  const new(this.cents);

  final int cents;

  @override
  List<Object?> get props => [cents];
}

final class ConfirmRequested extends PixEvent {
  const new();
}

final class RetryRequested extends PixEvent {
  const new();
}

/// Volta uma etapa (seta de voltar, ou "Alterar valor" depois de uma falha).
final class BackRequested extends PixEvent {
  const new();
}

final class Reset extends PixEvent {
  const new();
}

/// Tudo o que vai para a API num envio. A [idempotencyKey] nasce junto com o
/// pedido, na etapa de confirmação.
class PixOrder extends Equatable {
  const new({
    required this.recipient,
    required this.amountCents,
    required this.description,
    required this.idempotencyKey,
  });

  final PixRecipient recipient;
  final int amountCents;
  final String? description;
  final String idempotencyKey;

  /// Mesmo destino, valor e mensagem: é o mesmo pedido.
  bool sameRequestAs(PixRecipient r, int cents, String? d) =>
      recipient == r && amountCents == cents && description == d;

  @override
  List<Object?> get props => [recipient, amountCents, description];
}

sealed class PixState extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

final class PixKeyStep extends PixState {
  const new({
    this.rawKey = '',
    this.looking = false,
    this.invalidFormat = false,
    this.failure,
  });

  /// O que estava digitado (ao voltar, o campo vem preenchido).
  final String rawKey;
  final bool looking;
  final bool invalidFormat;
  final Failure? failure;

  @override
  List<Object?> get props => [rawKey, looking, invalidFormat, failure];
}

final class PixAmountStep extends PixState {
  const new({
    required this.recipient,
    this.amountCents = 0,
    this.description,
    this.locked = false,
  });

  final PixRecipient recipient;

  /// Valor já digitado (ao voltar da confirmação) ou vindo do QR code.
  final int amountCents;
  final String? description;

  final bool locked;

  @override
  List<Object?> get props => [recipient, amountCents, description, locked];
}

final class PixConfirmStep extends PixState {
  const new(this.order);

  final PixOrder order;

  PixRecipient get recipient => order.recipient;
  int get amountCents => order.amountCents;
  String get idempotencyKey => order.idempotencyKey;

  @override
  List<Object?> get props => [order, order.idempotencyKey];
}

final class PixSending extends PixState {
  const new(this.order);

  final PixOrder order;

  @override
  List<Object?> get props => [order];
}

final class PixDone extends PixState {
  const new(this.receipt);

  final PixReceipt receipt;

  @override
  List<Object?> get props => [receipt];
}

final class PixFailed extends PixState {
  const new({
    required this.order,
    required this.failure,
    required this.canRetry,
  });

  final PixOrder order;
  final Failure failure;

  /// Só faz sentido tentar de novo quando o problema pode ter sido passageiro
  /// (rede, servidor). Saldo insuficiente não muda tentando de novo.
  final bool canRetry;

  @override
  List<Object?> get props => [order, failure, canRetry];
}

/// Eventos processados um de cada vez (`sequential`): um segundo toque em
/// "Confirmar" espera o primeiro e, como a etapa já mudou, não faz nada.
class PixTransferBloc extends Bloc<PixEvent, PixState> {
  new({
    required this._lookup,
    required this._sendPix,
    this._biometrics,
    String Function()? newIdempotencyKey,
    int? lockedAmountCents,
  }) : _newKey = newIdempotencyKey ?? uuidV4,
       _locked = lockedAmountCents,
       super(const PixKeyStep()) {
    on<PixEvent>(_onEvent, transformer: sequential());
  }

  final LookupPixKey _lookup;
  final SendPix _sendPix;
  final BiometricGate? _biometrics;
  final String Function() _newKey;

  /// Valor fixo de um QR code lido (nulo = a pessoa digita o valor).
  int? _locked;

  /// O último pedido montado. Se a pessoa voltar e confirmar exatamente o
  /// mesmo pedido, a chave é reaproveitada: se a rede caiu depois de a API
  /// gravar o Pix, uma chave nova enviaria o dinheiro duas vezes.
  PixOrder? _lastOrder;

  Future<void> _onEvent(PixEvent event, Emitter<PixState> emit) =>
      switch (event) {
        KeySubmitted() => _onKey(event, emit),
        DescriptionChanged() => _sync(() => _onDescription(event, emit)),
        AmountSubmitted() => _sync(() => _onAmount(event, emit)),
        ConfirmRequested() => _onConfirm(emit),
        RetryRequested() => _onRetry(emit),
        BackRequested() => _sync(() => _onBack(emit)),
        Reset() => _sync(() {
          _lastOrder = null;
          // "Enviar outro Pix" começa do zero, sem o valor do QR.
          _locked = null;
          emit(const PixKeyStep());
        }),
      };

  static Future<void> _sync(void Function() f) async => f();

  Future<void> _onKey(KeySubmitted event, Emitter<PixState> emit) async {
    if (state is! PixKeyStep) return;
    final key = detectPixKey(event.raw);
    if (key == null) {
      emit(PixKeyStep(rawKey: event.raw, invalidFormat: true));
      return;
    }

    emit(PixKeyStep(rawKey: event.raw, looking: true));
    try {
      final recipient = await _lookup(key.type, key.value);
      emit(
        PixAmountStep(
          recipient: recipient,
          amountCents: _locked ?? 0,
          locked: _locked != null,
        ),
      );
    } on Failure catch (failure) {
      emit(PixKeyStep(rawKey: event.raw, failure: failure));
    }
  }

  void _onDescription(DescriptionChanged event, Emitter<PixState> emit) {
    final current = state;
    if (current is! PixAmountStep) return;
    final text = event.description.trim();
    emit(
      PixAmountStep(
        recipient: current.recipient,
        amountCents: current.amountCents,
        description: text.isEmpty ? null : text,
        locked: current.locked,
      ),
    );
  }

  void _onAmount(AmountSubmitted event, Emitter<PixState> emit) {
    final current = state;
    if (current is! PixAmountStep) return;
    if (!AmountInput(cents: event.cents).isValid) return;
    // Valor do QR code: só aceita exatamente ele.
    if (_locked != null && event.cents != _locked) return;

    final last = _lastOrder;
    final reuse =
        last != null &&
        last.sameRequestAs(current.recipient, event.cents, current.description);
    final order = PixOrder(
      recipient: current.recipient,
      amountCents: event.cents,
      description: current.description,
      // A chave nasce aqui, ao entrar na confirmação.
      idempotencyKey: reuse ? last.idempotencyKey : _newKey(),
    );
    _lastOrder = order;
    emit(PixConfirmStep(order));
  }

  Future<void> _onConfirm(Emitter<PixState> emit) async {
    final current = state;
    if (current is! PixConfirmStep) return;
    final approved =
        await _biometrics?.confirm('Confirme para enviar o Pix') ?? true;
    if (!approved) return;
    await _send(current.order, emit);
  }

  Future<void> _onRetry(Emitter<PixState> emit) async {
    final current = state;
    if (current is! PixFailed || !current.canRetry) return;
    // Mesma chave da primeira tentativa: se aquela chegou na API, esta
    // devolve o mesmo resultado em vez de enviar de novo.
    await _send(current.order, emit);
  }

  Future<void> _send(PixOrder order, Emitter<PixState> emit) async {
    emit(PixSending(order));
    try {
      final receipt = await _sendPix(
        recipient: order.recipient,
        amountCents: order.amountCents,
        description: order.description,
        idempotencyKey: order.idempotencyKey,
      );
      // Pix concluído: o próximo pedido, mesmo igual, é um Pix novo.
      _lastOrder = null;
      emit(PixDone(receipt));
    } on Failure catch (failure) {
      emit(
        PixFailed(
          order: order,
          failure: failure,
          canRetry: _transient(failure),
        ),
      );
    }
  }

  static bool _transient(Failure failure) => switch (failure) {
    NetworkFailure() => true,
    ApiFailure(:final status) => status >= 500,
    ValidationFailure() => false,
  };

  void _onBack(Emitter<PixState> emit) {
    switch (state) {
      case PixAmountStep(:final recipient):
        emit(PixKeyStep(rawKey: recipient.keyValue));
      case PixConfirmStep(:final order) || PixFailed(:final order):
        emit(
          PixAmountStep(
            recipient: order.recipient,
            amountCents: order.amountCents,
            description: order.description,
            locked: _locked != null,
          ),
        );
      case PixKeyStep() || PixSending() || PixDone():
        break;
    }
  }
}
