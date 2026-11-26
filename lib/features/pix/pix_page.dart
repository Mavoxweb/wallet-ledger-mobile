import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/features/pix/bloc/pix_transfer_bloc.dart';
import 'package:wallet_ledger_mobile/features/pix/data/pix_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/view/amount_step.dart';
import 'package:wallet_ledger_mobile/features/pix/view/confirm_step.dart';
import 'package:wallet_ledger_mobile/features/pix/view/key_step.dart';
import 'package:wallet_ledger_mobile/features/pix/view/result_step.dart';

/// Fluxo Pix: abre como uma folha que sobe de baixo (rota `/pix`).
class PixPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PixTransferBloc(
        pix: context.read<PixRepository>(),
        biometrics: context.read<BiometricGate>(),
      ),
      child: const _PixFlow(),
    );
  }
}

class _PixFlow extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PixTransferBloc>();

    return BlocConsumer<PixTransferBloc, PixState>(
      listenWhen: (previous, current) =>
          current is PixDone && previous is! PixDone,
      listener: (context, state) {
        // Vibração curta junto com o check: o sucesso também se sente.
        unawaited(HapticFeedback.mediumImpact());
        context.read<AccountEvents?>()?.changed();
      },
      builder: (context, state) {
        final canGoBack =
            state is PixAmountStep ||
            state is PixConfirmStep ||
            state is PixFailed;

        // O "voltar" do sistema volta uma etapa em vez de fechar o fluxo.
        return PopScope(
          canPop: !canGoBack && state is! PixSending,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && canGoBack) bloc.add(const BackRequested());
          },
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    canGoBack: canGoBack,
                    busy: state is PixSending,
                    onBack: () => bloc.add(const BackRequested()),
                  ),
                  Expanded(child: _StepSwitcher(state: state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const new({
    required this.canGoBack,
    required this.busy,
    required this.onBack,
  });

  final bool canGoBack;
  final bool busy;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s, AppSpacing.s, 0, 0),
      child: Row(
        children: [
          if (canGoBack)
            IconButton(
              tooltip: 'Voltar',
              onPressed: busy ? null : onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            )
          else
            IconButton(
              tooltip: 'Fechar',
              onPressed: busy ? null : () => context.pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          const SizedBox(width: AppSpacing.xs),
          Text('Pix', style: AppText.title.copyWith(color: AppColors.inkMuted)),
        ],
      ),
    );
  }
}

/// Troca de etapa com fade e um deslize curto. Com movimento reduzido, só o
/// fade.
class _StepSwitcher extends StatelessWidget {
  const new({required this.state});

  final PixState state;

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);

    final (String key, Widget child) = switch (state) {
      final PixKeyStep s => ('key', KeyStep(state: s)),
      final PixAmountStep s => ('amount', AmountStep(state: s)),
      // Confirmar e "enviando" são a mesma tela: só o botão muda.
      PixConfirmStep(:final order) => (
        'confirm',
        ConfirmStep(order: order, sending: false),
      ),
      PixSending(:final order) => (
        'confirm',
        ConfirmStep(order: order, sending: true),
      ),
      final PixDone s => ('done', DoneStep(state: s)),
      final PixFailed s => ('failed', FailedStep(state: s)),
    };

    return AnimatedSwitcher(
      duration: reduced ? AppMotion.press : AppMotion.tab,
      switchInCurve: AppCurves.easeOut,
      switchOutCurve: AppCurves.easeOut,
      transitionBuilder: (child, animation) {
        final fade = FadeTransition(opacity: animation, child: child);
        if (reduced) return fade;
        return SlideTransition(
          position: Tween(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animation),
          child: fade,
        );
      },
      child: KeyedSubtree(key: ValueKey(key), child: child),
    );
  }
}
