import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/money/amount_input.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/keypad.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';

/// Folha com o teclado de valor. Devolve os centavos, ou nulo se fechar.
///
/// [maxCents] permite um teto menor que o da API (o depósito simulado aceita
/// até R$ 1.000,00), com o aviso [overLimitMessage].
Future<int?> showAmountSheet(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  int initialCents = 0,
  int maxCents = AmountInput.maxCents,
  String? overLimitMessage,
}) => showModalBottomSheet<int>(
  context: context,
  // No navegador raiz: aberta de uma aba, a folha ficaria por baixo da barra
  // de navegação flutuante (que vive acima das abas).
  useRootNavigator: true,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: AppColors.ground,
  builder: (context) => _AmountSheet(
    title: title,
    confirmLabel: confirmLabel,
    initialCents: initialCents,
    maxCents: maxCents,
    overLimitMessage: overLimitMessage,
  ),
);

class _AmountSheet extends StatefulWidget {
  const new({
    required this.title,
    required this.confirmLabel,
    required this.initialCents,
    required this.maxCents,
    required this.overLimitMessage,
  });

  final String title;
  final String confirmLabel;
  final int initialCents;
  final int maxCents;
  final String? overLimitMessage;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late var _amount = AmountInput(cents: widget.initialCents);

  bool get _over => _amount.cents > widget.maxCents;
  bool get _valid => _amount.isValid && !_over;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: AppText.title),
            const SizedBox(height: AppSpacing.l),
            Center(
              child: MoneyText(
                cents: _amount.cents,
                size: 40,
                color: _amount.cents == 0 ? AppColors.inkMuted : AppColors.ink,
                mutedColor: AppColors.inkMuted,
              ),
            ),
            SizedBox(
              height: 24,
              child: _over && widget.overLimitMessage != null
                  ? Text(
                      widget.overLimitMessage!,
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : null,
            ),
            Keypad(
              onDigit: (d) => setState(() => _amount = _amount.digit(d)),
              onBackspace: () => setState(() => _amount = _amount.backspace()),
            ),
            const SizedBox(height: AppSpacing.l),
            PrimaryButton(
              label: widget.confirmLabel,
              onPressed: _valid
                  ? () => Navigator.of(context).pop(_amount.cents)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
