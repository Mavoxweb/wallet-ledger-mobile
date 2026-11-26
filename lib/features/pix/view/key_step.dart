import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/bloc/pix_transfer_bloc.dart';
import 'package:wallet_ledger_mobile/features/pix/pix_key_detector.dart';
import 'package:wallet_ledger_mobile/features/pix/view/step_layout.dart';

/// Etapa 1: a chave de quem vai receber.
class KeyStep extends StatefulWidget {
  const new({required this.state, super.key});

  final PixKeyStep state;

  @override
  State<KeyStep> createState() => _KeyStepState();
}

class _KeyStepState extends State<KeyStep> {
  late final _controller = TextEditingController(text: widget.state.rawKey);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() =>
      context.read<PixTransferBloc>().add(KeySubmitted(_controller.text));

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final detected = detectPixKey(_controller.text);
    final error = state.invalidFormat
        ? 'Use um e-mail, um celular com DDD ou uma chave aleatória.'
        : state.failure == null
        ? null
        : messageFor(state.failure!);

    return StepLayout(
      title: 'Para quem você quer enviar?',
      subtitle: 'Digite a chave Pix de quem vai receber.',
      bottom: PrimaryButton(
        label: 'Continuar',
        loading: state.looking,
        onPressed: _controller.text.trim().isEmpty ? null : _submit,
      ),
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.go,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Chave Pix',
            hintText: 'E-mail, celular ou chave aleatória',
            errorText: error,
            errorMaxLines: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        // O tipo reconhecido aparece enquanto a pessoa digita: ela sabe que
        // o app entendeu antes de tocar em continuar.
        AnimatedOpacity(
          opacity: detected == null ? 0 : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppMotion.press,
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(switch (detected?.type) {
                PixKeyKind.email => 'E-mail',
                PixKeyKind.phone => 'Celular',
                PixKeyKind.evp => 'Chave aleatória',
                null => '',
              }, style: AppText.caption.copyWith(color: AppColors.accent)),
            ],
          ),
        ),
      ],
    );
  }
}
