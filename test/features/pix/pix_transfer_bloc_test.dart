import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/features/pix/presentation/bloc/pix_transfer_bloc.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// Gera chaves previsíveis: key-1, key-2...
String Function() _keys() {
  var n = 0;
  return () => 'key-${++n}';
}

PixTransferBloc _bloc(FakePixRepository pix) =>
    PixTransferBloc(pix: pix, newIdempotencyKey: _keys());

void main() {
  blocTest<PixTransferBloc, PixState>(
    'caminho feliz: chave, valor, confirmação e comprovante',
    build: () => _bloc(FakePixRepository()),
    act: (bloc) => bloc
      ..add(const KeySubmitted('bruno@walletledger.dev'))
      ..add(const AmountSubmitted(2590))
      ..add(const ConfirmRequested()),
    expect: () => [
      isA<PixKeyStep>().having((s) => s.looking, 'looking', isTrue),
      isA<PixAmountStep>().having(
        (s) => s.recipient.maskedName,
        'nome',
        'Bruno C. D.',
      ),
      isA<PixConfirmStep>()
          .having((s) => s.amountCents, 'valor', 2590)
          .having((s) => s.idempotencyKey, 'chave', 'key-1'),
      isA<PixSending>(),
      isA<PixDone>().having((s) => s.receipt.amountCents, 'valor', 2590),
    ],
  );

  blocTest<PixTransferBloc, PixState>(
    'chave em formato inválido nem chega na API',
    build: () => _bloc(FakePixRepository()),
    act: (bloc) => bloc.add(const KeySubmitted('bruno')),
    expect: () => [
      isA<PixKeyStep>().having((s) => s.invalidFormat, 'formato', isTrue),
    ],
  );

  blocTest<PixTransferBloc, PixState>(
    'chave não encontrada fica na etapa da chave com o erro',
    build: () => _bloc(FakePixRepository(lookupFailure: notFound)),
    act: (bloc) => bloc.add(const KeySubmitted('ninguem@walletledger.dev')),
    expect: () => [
      isA<PixKeyStep>(),
      isA<PixKeyStep>().having((s) => s.failure, 'falha', notFound),
    ],
  );

  blocTest<PixTransferBloc, PixState>(
    'saldo insuficiente mostra a mensagem e não oferece tentar de novo',
    build: () => _bloc(FakePixRepository(transferFailures: [noFunds])),
    act: (bloc) => bloc
      ..add(const KeySubmitted('bruno@walletledger.dev'))
      ..add(const AmountSubmitted(999999))
      ..add(const ConfirmRequested()),
    skip: 4,
    expect: () => [
      isA<PixFailed>()
          .having((s) => s.failure, 'falha', noFunds)
          .having((s) => s.canRetry, 'pode tentar', isFalse),
    ],
  );

  test(
    'falha de rede e tentar de novo reusa a mesma chave de idempotência',
    () async {
      final pix = FakePixRepository(transferFailures: [const NetworkFailure()]);
      final bloc = _bloc(pix)
        ..add(const KeySubmitted('bruno@walletledger.dev'))
        ..add(const AmountSubmitted(2590))
        ..add(const ConfirmRequested());
      await expectLater(
        bloc.stream,
        emitsThrough(isA<PixFailed>().having((s) => s.canRetry, 'retry', true)),
      );

      bloc.add(const RetryRequested());
      await expectLater(bloc.stream, emitsThrough(isA<PixDone>()));

      expect(pix.sentKeys, ['key-1', 'key-1']);
      await bloc.close();
    },
  );

  test('valor novo depois da falha gera chave nova', () async {
    final pix = FakePixRepository(transferFailures: [const NetworkFailure()]);
    final bloc = _bloc(pix)
      ..add(const KeySubmitted('bruno@walletledger.dev'))
      ..add(const AmountSubmitted(2590))
      ..add(const ConfirmRequested());
    await expectLater(bloc.stream, emitsThrough(isA<PixFailed>()));

    bloc
      ..add(const BackRequested())
      ..add(const AmountSubmitted(3000))
      ..add(const ConfirmRequested());
    await expectLater(bloc.stream, emitsThrough(isA<PixDone>()));

    expect(pix.sentKeys, ['key-1', 'key-2']);
    await bloc.close();
  });

  test('voltar e confirmar o mesmo pedido mantém a chave', () async {
    // Se a rede caiu depois de a API gravar o Pix, mandar de novo com outra
    // chave enviaria o dinheiro duas vezes.
    final pix = FakePixRepository(transferFailures: [const NetworkFailure()]);
    final bloc = _bloc(pix)
      ..add(const KeySubmitted('bruno@walletledger.dev'))
      ..add(const AmountSubmitted(2590))
      ..add(const ConfirmRequested());
    await expectLater(bloc.stream, emitsThrough(isA<PixFailed>()));

    bloc
      ..add(const BackRequested())
      ..add(const AmountSubmitted(2590))
      ..add(const ConfirmRequested());
    await expectLater(bloc.stream, emitsThrough(isA<PixDone>()));

    expect(pix.sentKeys, ['key-1', 'key-1']);
    await bloc.close();
  });

  blocTest<PixTransferBloc, PixState>(
    'não dá para confirmar sem passar pelo valor',
    build: () => _bloc(FakePixRepository()),
    act: (bloc) => bloc.add(const ConfirmRequested()),
    expect: () => <PixState>[],
  );

  blocTest<PixTransferBloc, PixState>(
    'valor inválido é ignorado',
    build: () => _bloc(FakePixRepository()),
    act: (bloc) => bloc
      ..add(const KeySubmitted('bruno@walletledger.dev'))
      ..add(const AmountSubmitted(0)),
    skip: 2,
    expect: () => <PixState>[],
  );

  test('biometria recusada não envia', () async {
    final pix = FakePixRepository();
    final bloc =
        PixTransferBloc(
            pix: pix,
            biometrics: FakeBiometricGate(available: true, approve: false),
          )
          ..add(const KeySubmitted('bruno@walletledger.dev'))
          ..add(const AmountSubmitted(2590))
          ..add(const ConfirmRequested());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state, isA<PixConfirmStep>());
    expect(pix.sentKeys, isEmpty);
    await bloc.close();
  });

  blocTest<PixTransferBloc, PixState>(
    'QR com valor: o valor vem travado e outro valor é ignorado',
    build: () => PixTransferBloc(
      pix: FakePixRepository(),
      newIdempotencyKey: _keys(),
      lockedAmountCents: 1050,
    ),
    act: (bloc) => bloc
      ..add(const KeySubmitted('bruno@walletledger.dev'))
      ..add(const AmountSubmitted(2000))
      ..add(const AmountSubmitted(1050)),
    expect: () => [
      isA<PixKeyStep>(),
      isA<PixAmountStep>()
          .having((s) => s.amountCents, 'valor', 1050)
          .having((s) => s.locked, 'travado', isTrue),
      isA<PixConfirmStep>().having((s) => s.amountCents, 'valor', 1050),
    ],
  );
}
