import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/config/app_info.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';
import 'package:wallet_ledger_mobile/core/widgets/pressable.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/deposit/deposit_sheet.dart';

class ProfilePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final me = session is SessionAuthenticated ? session.me : null;
    final name = me?.name ?? '';
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    final account = me?.accountId;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            GlassNavBar.reservedHeight,
          ),
          children: [
            Semantics(
              header: true,
              child: const Text('Perfil', style: AppText.display),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initials,
                      style: AppText.title.copyWith(color: AppColors.ground),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppText.title),
                      if (account != null && account.length >= 4)
                        Text(
                          'Conta •••• ${account.substring(account.length - 4)}',
                          style: AppText.caption,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _Group(
              children: [
                _Row(
                  icon: Icons.key_rounded,
                  label: 'Chaves Pix',
                  onTap: () => context.go('/perfil/chaves'),
                ),
                _Row(
                  icon: Icons.add_card_rounded,
                  label: 'Depósito simulado',
                  onTap: () => showDepositSheet(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.l),
            Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppColors.accent,
                  ),
                  SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      'Projeto de demonstração: o dinheiro é fictício e nenhum '
                      'Pix sai do app para um banco de verdade.',
                      style: AppText.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            _Group(
              children: [
                _Row(
                  icon: Icons.logout_rounded,
                  label: 'Sair',
                  // Sair não destrói nada (é só entrar de novo): não pede
                  // confirmação.
                  onTap: () =>
                      context.read<SessionBloc>().add(const SessionLoggedOut()),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Center(
              child: Text(
                'Wallet Ledger · versão $appVersion',
                style: AppText.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const new({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.ink),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: AppText.body)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}
