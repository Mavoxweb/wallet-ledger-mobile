import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';

/// Esqueleto de cada etapa: título, conteúdo rolável e o botão principal
/// sempre visível no rodapé (ao alcance do polegar).
class StepLayout extends StatelessWidget {
  const new({
    required this.title,
    required this.children,
    required this.bottom,
    super.key,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.s,
              AppSpacing.xl,
              AppSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: AppText.display.copyWith(fontSize: 26),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: AppText.caption),
                ],
                const SizedBox(height: AppSpacing.xl),
                ...children,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.l,
          ),
          child: bottom,
        ),
      ],
    );
  }
}

class RecipientRow extends StatelessWidget {
  const new({required this.name, required this.cpf, super.key});

  final String name;
  final String cpf;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.control),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: AppText.bodyStrong.copyWith(color: AppColors.accent),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.bodyStrong),
                Text('CPF $cpf', style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
