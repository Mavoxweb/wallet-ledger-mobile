import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/storage/prefs_store.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/home/cubit/home_cubit.dart';
import 'package:wallet_ledger_mobile/features/home/view/balance_card.dart';
import 'package:wallet_ledger_mobile/features/home/view/cards_carousel.dart';
import 'package:wallet_ledger_mobile/features/home/view/keys_card.dart';
import 'package:wallet_ledger_mobile/features/home/view/movement_tile.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';

class HomePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = HomeCubit(
          accounts: context.read<AccountRepository>(),
          keys: context.read<KeysRepository>(),
          prefs: context.read<PrefsStore>(),
          accountChanges: context.read<AccountEvents?>()?.changes,
        );
        // Começa a carregar sem esperar:
        // a tela mostra o esqueleto enquanto isso.
        unawaited(cubit.load());
        return cubit;
      },
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: cubit.refresh,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) => CustomScrollView(
              // Sempre rolável, para o "puxar para atualizar" funcionar mesmo
              // com pouco conteúdo.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _Greeting()),
                ...switch (state) {
                  HomeLoading() => [
                    const SliverToBoxAdapter(child: _Skeleton()),
                  ],
                  HomeError(:final failure) => [
                    SliverToBoxAdapter(
                      child: _ErrorBox(
                        message: messageFor(failure),
                        onRetry: cubit.load,
                      ),
                    ),
                  ],
                  HomeLoaded() => _loaded(context, state, cubit),
                },
                const SliverToBoxAdapter(
                  child: SizedBox(height: GlassNavBar.reservedHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _loaded(
    BuildContext context,
    HomeLoaded state,
    HomeCubit cubit,
  ) {
    return [
      SliverToBoxAdapter(
        child: CardsCarousel(
          cards: [
            BalanceCard(
              account: state.account,
              hidden: state.balanceHidden,
              onToggle: cubit.toggleBalance,
            ),
            KeysCard(keys: state.keys),
          ],
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: [
              const Expanded(
                child: Text('Últimas movimentações', style: AppText.title),
              ),
              TextButton(
                onPressed: () => context.go('/extrato'),
                child: const Text('Ver tudo'),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        sliver: SliverToBoxAdapter(
          child: state.recent.isEmpty
              ? const _EmptyMovements()
              : _Panel(
                  child: Column(
                    children: [
                      for (final m in state.recent) MovementTile(movement: m),
                    ],
                  ),
                ),
        ),
      ),
    ];
  }
}

/// Saudação pela hora do dia + avatar com as iniciais.
class _Greeting extends StatelessWidget {
  const new();

  static String greetingFor(int hour) => hour < 12
      ? 'Bom dia,'
      : hour < 18
      ? 'Boa tarde,'
      : 'Boa noite,';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final parts = session is SessionAuthenticated
        ? session.me.name.split(' ').where((p) => p.isNotEmpty).toList()
        : <String>[];
    final shortName = parts.take(2).join(' ');
    final initials = parts.take(2).map((p) => p[0]).join().toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.l,
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
              child: Text(
                initials,
                style: AppText.title.copyWith(
                  fontSize: 15,
                  color: AppColors.ground,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greetingFor(DateTime.now().hour), style: AppText.caption),
                Text(
                  shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Superfície branca com sombra macia (no lugar de bordas).
class _Panel extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.tile),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

class _EmptyMovements extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Nenhuma movimentação ainda. Faça um depósito simulado ou '
          'receba um Pix para começar.',
          style: AppText.body.copyWith(color: AppColors.inkMuted),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const new({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppText.body),
          const SizedBox(height: AppSpacing.l),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar de novo'),
          ),
        ],
      ),
    );
  }
}

/// Formas cinza no lugar do conteúdo enquanto carrega: a tela não "pula"
/// quando os dados chegam, porque o espaço já está reservado.
class _Skeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    Widget block(double height, double radius) => Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8E3),
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Semantics(
      label: 'Carregando',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 4, AppSpacing.xl, 0),
        child: Column(
          children: [
            block(196, AppRadii.card),
            const SizedBox(height: 64),
            block(220, AppRadii.tile),
          ],
        ),
      ),
    );
  }
}
