import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/amount_sheet.dart';
import 'package:wallet_ledger_mobile/core/widgets/empty_state.dart';
import 'package:wallet_ledger_mobile/core/widgets/glass_nav_bar.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/core/widgets/pressable.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/charge_repository.dart';
import 'package:wallet_ledger_mobile/features/charge/presentation/cubit/charge_cubit.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';

class ChargePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ChargeCubit(
          keys: context.read<KeysRepository>(),
          charges: context.read<ChargeRepository>(),
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const _ChargeView(),
    );
  }
}

class _ChargeView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChargeCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ChargeCubit, ChargeState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              GlassNavBar.reservedHeight,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: const Text('Cobrar', style: AppText.display),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Ler QR code',
                    onPressed: () => context.push('/scan'),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Mostre o QR code ou envie o código para receber um Pix.',
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpacing.xl),
              ...switch (state.status) {
                ChargeStatus.loading => [
                  const Center(child: CircularProgressIndicator()),
                ],
                ChargeStatus.failure => [
                  EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Não deu para carregar suas chaves',
                    message: messageFor(state.failure!),
                    action: OutlinedButton(
                      onPressed: cubit.load,
                      child: const Text('Tentar de novo'),
                    ),
                  ),
                ],
                ChargeStatus.ready when state.keys.isEmpty => [
                  const EmptyState(
                    icon: Icons.key_rounded,
                    title: 'Você ainda não tem chave Pix',
                    message:
                        'Cadastre uma chave no seu perfil para gerar QR codes '
                        'de cobrança.',
                  ),
                ],
                ChargeStatus.ready when state.payload != null => [
                  _QrCard(state: state),
                ],
                ChargeStatus.ready => [_Form(state: state)],
              },
            ],
          ),
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const new({required this.state});

  final ChargeState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChargeCubit>();
    final amount = state.amountCents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Receber na chave', style: AppText.bodyStrong),
        const SizedBox(height: AppSpacing.m),
        Wrap(
          spacing: AppSpacing.s,
          runSpacing: AppSpacing.s,
          children: [
            for (final key in state.keys)
              ChoiceChip(
                label: Text(key.label),
                selected: key.id == state.selectedKeyId,
                onSelected: (_) => cubit.selectKey(key.id),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('Valor', style: AppText.bodyStrong),
        const SizedBox(height: AppSpacing.m),
        Pressable(
          semanticLabel: amount == null
              ? 'Definir valor. Agora: qualquer valor'
              : 'Alterar valor',
          onTap: () async {
            final cents = await showAmountSheet(
              context,
              title: 'Valor da cobrança',
              confirmLabel: 'Definir valor',
              initialCents: amount ?? 0,
            );
            if (cents != null) cubit.setAmount(cents);
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.control),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                Expanded(
                  child: amount == null
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Qualquer valor', style: AppText.bodyStrong),
                            Text(
                              'Quem paga escolhe quanto enviar.',
                              style: AppText.caption,
                            ),
                          ],
                        )
                      : MoneyText(
                          cents: amount,
                          size: 28,
                          color: AppColors.ink,
                          mutedColor: AppColors.inkMuted,
                        ),
                ),
                if (amount != null)
                  IconButton(
                    tooltip: 'Tirar o valor',
                    onPressed: () => cubit.setAmount(null),
                    icon: const Icon(Icons.close_rounded),
                  )
                else
                  Text(
                    'Definir',
                    style: AppText.bodyStrong.copyWith(color: AppColors.accent),
                  ),
              ],
            ),
          ),
        ),
        if (state.failure != null) ...[
          const SizedBox(height: AppSpacing.l),
          Text(
            messageFor(state.failure!),
            style: AppText.caption.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Gerar QR code',
          icon: Icons.qr_code_2_rounded,
          loading: state.generating,
          onPressed: cubit.generate,
        ),
      ],
    );
  }
}

class _QrCard extends StatelessWidget {
  const new({required this.state});

  final ChargeState state;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: state.payload!));
    if (!context.mounted) return;
    // O SnackBar também é lido pelo leitor de tela.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Código Pix copiado'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChargeCubit>();
    final payload = state.payload!;
    final amount = state.amountCents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Semantics(
                label: 'QR code Pix para receber',
                image: true,
                container: true,
                excludeSemantics: true,
                child: QrImageView(
                  data: payload,
                  size: 220,
                  // Correção M: aguenta ~15% do código danificado ou com
                  // reflexo, sem deixar o QR denso demais.
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.ink,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              if (amount != null)
                MoneyText(
                  cents: amount,
                  size: 28,
                  color: AppColors.ink,
                  mutedColor: AppColors.inkMuted,
                )
              else
                const Text('Valor livre', style: AppText.title),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Chave: ${state.selectedKey?.label ?? ''}',
                style: AppText.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('Pix Copia e Cola', style: AppText.bodyStrong),
        const SizedBox(height: AppSpacing.s),
        Text(
          payload,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppText.caption.copyWith(fontFamily: 'monospace'),
        ),
        const SizedBox(height: AppSpacing.l),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copy(context),
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copiar código'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => SharePlus.instance.share(
                  ShareParams(text: payload, subject: 'Pix Copia e Cola'),
                ),
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Compartilhar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        TextButton(
          onPressed: cubit.newCharge,
          child: const Text('Nova cobrança'),
        ),
      ],
    );
  }
}
