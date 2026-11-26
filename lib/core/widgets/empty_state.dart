import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';

/// Estado vazio ou de erro: o que é, por que está assim e o que fazer.
class EmptyState extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(title, textAlign: TextAlign.center, style: AppText.title),
          const SizedBox(height: AppSpacing.s),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: AppColors.inkMuted),
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.l),
            action!,
          ],
        ],
      ),
    );
  }
}
