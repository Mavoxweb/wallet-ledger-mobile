import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/empty_state.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';
import 'package:wallet_ledger_mobile/features/home/view/movement_tile.dart';
import 'package:wallet_ledger_mobile/features/statement/bloc/statement_bloc.dart';
import 'package:wallet_ledger_mobile/features/statement/group_by_day.dart';
import 'package:wallet_ledger_mobile/features/statement/view/filter_bar.dart';

class StatementPage extends StatelessWidget {
  const new({super.key, this.clock = DateTime.now});

  /// De onde vem o "agora" para os rótulos Hoje/Ontem. Os testes fixam a data.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatementBloc(
        accounts: context.read<AccountRepository>(),
        accountChanges: context.read<AccountEvents?>()?.changes,
      )..add(const StatementStarted()),
      child: _StatementView(clock: clock),
    );
  }
}

class _StatementView extends StatefulWidget {
  const new({required this.clock});

  final DateTime Function() clock;

  @override
  State<_StatementView> createState() => _StatementViewState();
}

class _StatementViewState extends State<_StatementView> {
  /// A próxima página é pedida quando faltam 300 dp para o fim: os itens
  /// chegam antes de o dedo alcançar o rodapé.
  static const _loadMoreThreshold = 300.0;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scroll.hasClients) return;
    final bloc = context.read<StatementBloc>();
    final state = bloc.state;
    // Depois de uma falha, só tenta de novo quando a pessoa tocar no botão:
    // senão cada pixel rolado viraria uma nova chamada.
    if (!state.canLoadMore || state.loadMoreFailed) return;

    final position = _scroll.position;
    if (position.maxScrollExtent - position.pixels <= _loadMoreThreshold) {
      bloc.add(const StatementNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StatementBloc>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        // Se a página que chegou não enche a tela (ou o filtro deixou pouca
        // coisa), não haverá rolagem para disparar o listener: confere de
        // novo depois de desenhar.
        child: BlocListener<StatementBloc, StatementState>(
          listener: (context, state) => WidgetsBinding.instance
              .addPostFrameCallback((_) => _maybeLoadMore()),
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () {
              final done = Completer<void>();
              bloc.add(StatementRefreshed(done: done));
              return done.future;
            },
            child: BlocBuilder<StatementBloc, StatementState>(
              builder: (context, state) => CustomScrollView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      filter: state.filter,
                      onFilter: (f) => bloc.add(StatementFilterChanged(f)),
                    ),
                  ),
                  ..._body(state, bloc),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: GlassNavBar.reservedHeight),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(StatementState state, StatementBloc bloc) {
    switch (state.status) {
      case StatementStatus.loading:
        return const [SliverToBoxAdapter(child: _Skeleton())];
      case StatementStatus.failure:
        return [
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Não deu para carregar o extrato',
              message: messageFor(state.failure!),
              action: OutlinedButton(
                onPressed: () => bloc.add(const StatementStarted()),
                child: const Text('Tentar de novo'),
              ),
            ),
          ),
        ];
      case StatementStatus.ready:
        final visible = state.visible;
        if (visible.isEmpty && state.hasReachedEnd) {
          return [SliverToBoxAdapter(child: _empty(state))];
        }
        final groups = groupByDay(visible, widget.clock());
        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            // `SliverList.builder` só constrói os dias que aparecem na tela.
            sliver: SliverList.builder(
              itemCount: groups.length,
              itemBuilder: (context, i) => _DaySection(group: groups[i]),
            ),
          ),
          SliverToBoxAdapter(
            child: _Footer(
              state: state,
              onRetry: () => bloc.add(const StatementNextPageRequested()),
            ),
          ),
        ];
    }
  }

  Widget _empty(StatementState state) => switch (state.filter) {
    StatementFilter.all when state.items.isEmpty => const EmptyState(
      icon: Icons.receipt_long_rounded,
      title: 'Nenhuma movimentação ainda',
      message:
          'Quando você receber ou enviar um Pix, ou fizer um depósito '
          'simulado, ele aparece aqui.',
    ),
    StatementFilter.incoming => const EmptyState(
      icon: Icons.south_west_rounded,
      title: 'Nenhuma entrada',
      message: 'Os Pix recebidos e os depósitos aparecem aqui.',
    ),
    _ => const EmptyState(
      icon: Icons.north_east_rounded,
      title: 'Nenhuma saída',
      message: 'Os Pix que você enviar aparecem aqui.',
    ),
  };
}

class _Header extends StatelessWidget {
  const new({required this.filter, required this.onFilter});

  final StatementFilter filter;
  final ValueChanged<StatementFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.s,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: const Text('Extrato', style: AppText.display),
          ),
          const SizedBox(height: AppSpacing.l),
          FilterBar(selected: filter, onChanged: onFilter),
        ],
      ),
    );
  }
}

/// Cabeçalho do dia + as movimentações dele num painel branco.
class _DaySection extends StatelessWidget {
  const new({required this.group});

  final DayGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, AppSpacing.xl, 4, AppSpacing.s),
          child: Semantics(
            header: true,
            child: Text(
              group.label,
              style: AppText.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.tile),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              for (final m in group.items)
                MovementTile(
                  movement: m,
                  trailingCaption: timeOfDay(m.createdAt),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rodapé da lista: carregando mais, falha com "tentar de novo" ou fim.
class _Footer extends StatelessWidget {
  const new({required this.state, required this.onRetry});

  final StatementState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (state.isLoadingMore) {
      child = Semantics(
        label: 'Carregando mais movimentações',
        child: const SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.accent,
          ),
        ),
      );
    } else if (state.loadMoreFailed) {
      child = Column(
        children: [
          const Text(
            'Não deu para carregar mais.',
            style: AppText.caption,
            textAlign: TextAlign.center,
          ),
          TextButton(onPressed: onRetry, child: const Text('Tentar de novo')),
        ],
      );
    } else if (state.hasReachedEnd) {
      child = const Text(
        'Você chegou ao começo do extrato.',
        style: AppText.caption,
        textAlign: TextAlign.center,
      );
    } else {
      child = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      child: Center(child: child),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    Widget block(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8E3),
        borderRadius: BorderRadius.circular(AppRadii.control),
      ),
    );

    return Semantics(
      label: 'Carregando',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            block(64, 14),
            const SizedBox(height: AppSpacing.m),
            block(double.infinity, 220),
            const SizedBox(height: AppSpacing.xl),
            block(64, 14),
            const SizedBox(height: AppSpacing.m),
            block(double.infinity, 140),
          ],
        ),
      ),
    );
  }
}
