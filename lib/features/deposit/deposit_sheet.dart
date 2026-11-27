import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/money/amount_input.dart';
import 'package:wallet_ledger_mobile/core/money/money_format.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/keypad.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/deposit/deposit_cubit.dart';
import 'package:wallet_ledger_mobile/features/deposit/deposit_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/view/check_mark.dart';

Future<void> showDepositSheet(BuildContext context) {
  final repository = context.read<DepositRepository>();
  final events = context.read<AccountEvents?>();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.ground,
    builder: (_) => BlocProvider(
      create: (_) => DepositCubit(deposits: repository),
      child: BlocListener<DepositCubit, DepositState>(
        listenWhen: (_, current) => current is DepositDone,
        listener: (_, _) => events?.changed(),
        child: const DepositSheet(),
      ),
    ),
  );
}

class DepositSheet extends StatefulWidget {
  const new({super.key});

  @override
  State<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends State<DepositSheet> {
  var _amount = const AmountInput();

  bool get _over => _amount.cents > DepositCubit.maxCents;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DepositCubit>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.l,
        ),
        child: BlocBuilder<DepositCubit, DepositState>(
          builder: (context, state) {
            if (state is DepositDone) return _Done(state: state);
            final sending = state is DepositSending;
            final failure = state is DepositFailed ? state.failure : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Depósito simulado', style: AppText.title),
                const SizedBox(height: AppSpacing.xs),
                const Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        'Demonstração · dinheiro fictício',
                        style: AppText.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                Center(
                  child: MoneyText(
                    cents: _amount.cents,
                    size: 40,
                    color: _amount.cents == 0
                        ? AppColors.inkMuted
                        : AppColors.ink,
                    mutedColor: AppColors.inkMuted,
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      _over
                          ? 'O depósito simulado aceita até '
                                '${formatCents(DepositCubit.maxCents)} '
                                'por vez.'
                          : failure != null
                          ? messageFor(failure)
                          : '',
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
                Keypad(
                  onDigit: sending
                      ? (_) {}
                      : (d) => setState(() => _amount = _amount.digit(d)),
                  onBackspace: sending
                      ? () {}
                      : () => setState(() => _amount = _amount.backspace()),
                ),
                const SizedBox(height: AppSpacing.l),
                PrimaryButton(
                  // Mesmo valor depois de uma falha = mesmo depósito.
                  label: failure != null ? 'Tentar de novo' : 'Depositar',
                  loading: sending,
                  onPressed: _amount.isValid && !_over
                      ? () => cubit.submit(_amount.cents)
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const new({required this.state});

  final DepositDone state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.l),
        const CheckMark(size: 72),
        const SizedBox(height: AppSpacing.l),
        Semantics(
          liveRegion: true,
          child: const Text('Depósito feito', style: AppText.title),
        ),
        const SizedBox(height: AppSpacing.s),
        MoneyText(
          cents: state.amountCents,
          size: 32,
          color: AppColors.ink,
          mutedColor: AppColors.inkMuted,
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Saldo atual: ${formatCents(state.balanceCents)}',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            label: 'Concluir',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
