import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/money/money_format.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';

/// "R$" pequeno, reais grandes e centavos menores.
class MoneyText extends StatelessWidget {
  const new({
    required this.cents,
    required this.color,
    required this.mutedColor,
    super.key,
    this.size = 42,
  });

  final int cents;
  final double size;
  final Color color;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final (:reais, cents: centsPart) = splitCents(cents);
    return Semantics(
      container: true,
      label: formatCents(cents),
      excludeSemantics: true,
      // Encolhe para caber se a fonte do sistema estiver muito grande.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              r'R$ ',
              style: AppText.body.copyWith(
                fontSize: size * 0.4,
                color: mutedColor,
              ),
            ),
            Text(reais, style: AppText.money(size, color: color)),
            Text(
              centsPart,
              style: AppText.money(size * 0.62, color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}
