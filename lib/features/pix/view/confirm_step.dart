import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/features/pix/bloc/pix_transfer_bloc.dart';
import 'package:wallet_ledger_mobile/features/pix/view/step_layout.dart';

/// Etapa 3: conferir tudo e confirmar. Também é a tela do "enviando".
class ConfirmStep extends StatefulWidget {
  const new({required this.order, required this.sending, super.key});

  final PixOrder order;
  final bool sending;

  @override
  State<ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends State<ConfirmStep> {
  late final Future<bool> _hasBiometrics = context
      .read<BiometricGate>()
      .isAvailable();

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final recipient = order.recipient;

    return StepLayout(
      title: 'Confira antes de enviar',
      bottom: FutureBuilder<bool>(
        future: _hasBiometrics,
        builder: (context, snapshot) {
          final biometric = snapshot.data ?? false;
          return PrimaryButton(
            label: biometric ? 'Confirmar com biometria' : 'Confirmar',
            icon: biometric ? Icons.fingerprint_rounded : null,
            loading: widget.sending,
            onPressed: () =>
                context.read<PixTransferBloc>().add(const ConfirmRequested()),
          );
        },
      ),
      children: [
        const Text('Você vai enviar', style: AppText.caption),
        const SizedBox(height: AppSpacing.xs),
        MoneyText(
          cents: order.amountCents,
          size: 40,
          color: AppColors.ink,
          mutedColor: AppColors.inkMuted,
        ),
        const SizedBox(height: AppSpacing.xl),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.tile),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              _Detail(label: 'Para', value: recipient.maskedName),
              _Detail(label: 'CPF', value: recipient.maskedCpf),
              _Detail(label: 'Chave', value: recipient.keyValue),
              if (order.description != null)
                _Detail(label: 'Mensagem', value: order.description!),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.bolt_rounded,
                size: 18,
                color: AppColors.inkMuted,
              ),
            ),
            SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                'O Pix cai na hora e não dá para cancelar depois.',
                style: AppText.caption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      // Wrap: em fonte grande, o valor desce para baixo do rótulo em vez de
      // espremer. A largura total é o que deixa o rótulo à esquerda e o valor
      // à direita (sem ela, o Wrap encolhe e fica centralizado).
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.l,
          runSpacing: AppSpacing.xs,
          children: [
            Text(label, style: AppText.caption),
            Text(value, style: AppText.bodyStrong),
          ],
        ),
      ),
    );
  }
}
