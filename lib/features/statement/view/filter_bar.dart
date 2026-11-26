import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/pressable.dart';
import 'package:wallet_ledger_mobile/features/statement/bloc/statement_bloc.dart';

/// Tudo · Entradas · Saídas. A opção escolhida fica escura, com a cor mudando
/// suavemente (ou na hora, com movimento reduzido).
class FilterBar extends StatelessWidget {
  const new({required this.selected, required this.onChanged, super.key});

  final StatementFilter selected;
  final ValueChanged<StatementFilter> onChanged;

  static const Map<StatementFilter, String> labels = {
    StatementFilter.all: 'Tudo',
    StatementFilter.incoming: 'Entradas',
    StatementFilter.outgoing: 'Saídas',
  };

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced ? Duration.zero : AppMotion.tab;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          for (final filter in StatementFilter.values)
            Expanded(
              child: Semantics(
                selected: filter == selected,
                child: Pressable(
                  onTap: () => onChanged(filter),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: AppCurves.easeOut,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: filter == selected
                          ? AppColors.ink
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.chip - 4),
                    ),
                    child: AnimatedDefaultTextStyle(
                      duration: duration,
                      curve: AppCurves.easeOut,
                      style: AppText.bodyStrong.copyWith(
                        fontSize: 14,
                        color: filter == selected
                            ? AppColors.ground
                            : AppColors.inkMuted,
                      ),
                      child: Text(
                        labels[filter]!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
