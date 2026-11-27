import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/money/money_format.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/pix/presentation/bloc/pix_transfer_bloc.dart';
import 'package:wallet_ledger_mobile/features/pix/presentation/view/check_mark.dart';
import 'package:wallet_ledger_mobile/features/statement/domain/group_by_day.dart';

class DoneStep extends StatelessWidget {
  const new({required this.state, super.key});

  final PixDone state;

  @override
  Widget build(BuildContext context) {
    final receipt = state.receipt;
    final when = receipt.createdAt.toUtc().add(brasiliaOffset);
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${two(when.day)}/${two(when.month)}/${when.year}';

    return _Centered(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(label: 'Concluir', onPressed: () => context.pop()),
          TextButton(
            onPressed: () => context.read<PixTransferBloc>().add(const Reset()),
            child: const Text('Enviar outro Pix'),
          ),
        ],
      ),
      children: [
        const CheckMark(),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            'Pix enviado',
            style: AppText.display.copyWith(fontSize: 26),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        MoneyText(
          cents: receipt.amountCents,
          size: 36,
          color: AppColors.ink,
          mutedColor: AppColors.inkMuted,
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'para ${receipt.recipientMaskedName}',
          textAlign: TextAlign.center,
          style: AppText.body,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$date às ${timeOfDay(receipt.createdAt)}',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Saldo atual: ${formatCents(receipt.balanceCents)}',
          style: AppText.caption,
        ),
      ],
    );
  }
}

/// Falha no envio. Se foi a rede, tentar de novo é seguro (mesma chave de
/// idempotência); se foi uma regra (saldo), a saída é mudar o valor.
class FailedStep extends StatelessWidget {
  const new({required this.state, super.key});

  final PixFailed state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PixTransferBloc>();
    final retry = state.canRetry;

    return _Centered(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: retry ? 'Tentar de novo' : 'Alterar valor',
            onPressed: () => bloc.add(
              retry ? const RetryRequested() : const BackRequested(),
            ),
          ),
          TextButton(
            onPressed: retry
                ? () => bloc.add(const BackRequested())
                : () => context.pop(),
            child: Text(retry ? 'Alterar valor' : 'Fechar'),
          ),
        ],
      ),
      children: [
        ExcludeSemantics(
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: Color(0xFFF6E3DF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              retry ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 36,
              color: const Color(0xFFA23B2A),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            retry
                ? 'Não conseguimos confirmar o envio'
                : 'O Pix não foi enviado',
            textAlign: TextAlign.center,
            style: AppText.display.copyWith(fontSize: 24),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          retry
              ? 'A conexão caiu antes da resposta. Tentar de novo é seguro: '
                    'o mesmo Pix nunca é enviado duas vezes.'
              : messageFor(state.failure),
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
  }
}

class _Centered extends StatelessWidget {
  const new({required this.children, required this.bottom});

  final List<Widget> children;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
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
