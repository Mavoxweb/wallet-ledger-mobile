import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/money/amount_input.dart';
import 'package:wallet_ledger_mobile/core/money/money_format.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/keypad.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/pix/bloc/pix_transfer_bloc.dart';
import 'package:wallet_ledger_mobile/features/pix/view/step_layout.dart';

class AmountStep extends StatefulWidget {
  const new({required this.state, super.key});

  final PixAmountStep state;

  @override
  State<AmountStep> createState() => _AmountStepState();
}

class _AmountStepState extends State<AmountStep> {
  late var _amount = AmountInput(cents: widget.state.amountCents);
  late final _message = TextEditingController(
    text: widget.state.description ?? '',
  );

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _set(AmountInput value) => setState(() => _amount = value);

  /// Teclado físico (demo no computador): dígitos, apagar e colar.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final pressed = HardwareKeyboard.instance;
    if (key == LogicalKeyboardKey.keyV &&
        (pressed.isControlPressed || pressed.isMetaPressed)) {
      unawaited(_paste());
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      _set(_amount.backspace());
      return KeyEventResult.handled;
    }
    final digit = int.tryParse(event.character ?? '');
    if (digit != null) {
      _set(_amount.digit(digit));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final parsed = AmountInput.parsePasted(data?.text ?? '');
    if (parsed != null) _set(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PixTransferBloc>();
    final recipient = widget.state.recipient;

    final locked = widget.state.locked;

    return Focus(
      autofocus: true,
      onKeyEvent: locked ? null : _onKey,
      child: StepLayout(
        title: 'Quanto você quer enviar?',
        bottom: PrimaryButton(
          label: 'Continuar',
          onPressed: _amount.isValid
              ? () => bloc.add(AmountSubmitted(_amount.cents))
              : null,
        ),
        children: [
          RecipientRow(name: recipient.maskedName, cpf: recipient.maskedCpf),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: MoneyText(
              cents: _amount.cents,
              size: 44,
              color: _amount.cents == 0 ? AppColors.inkMuted : AppColors.ink,
              mutedColor: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          // Espaço reservado: o aviso aparece sem empurrar o teclado.
          SizedBox(
            height: 20,
            child: _amount.isOverLimit
                ? Text(
                    'O valor máximo por Pix é '
                    '${formatCents(AmountInput.maxCents)}.',
                    textAlign: TextAlign.center,
                    style: AppText.caption.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.m),
          TextField(
            controller: _message,
            maxLength: 140,
            textInputAction: TextInputAction.done,
            onChanged: (text) => bloc.add(DescriptionChanged(text)),
            decoration: const InputDecoration(
              labelText: 'Mensagem (opcional)',
              counterText: '',
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (locked)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.inkMuted,
                ),
                SizedBox(width: AppSpacing.s),
                Flexible(
                  child: Text(
                    'Valor definido pelo QR code.',
                    style: AppText.caption,
                  ),
                ),
              ],
            )
          else
            Keypad(
              onDigit: (d) => _set(_amount.digit(d)),
              onBackspace: () => _set(_amount.backspace()),
            ),
        ],
      ),
    );
  }
}
