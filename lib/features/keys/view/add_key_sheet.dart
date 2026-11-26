import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/primary_button.dart';
import 'package:wallet_ledger_mobile/features/keys/cubit/keys_cubit.dart';
import 'package:wallet_ledger_mobile/features/keys/data/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/pix_key_detector.dart';

/// Folha de cadastro. Abre no navegador raiz (acima da barra flutuante), por
/// isso recebe o Cubit da tela de chaves por `BlocProvider.value`.
Future<void> showAddKeySheet(BuildContext context, KeysCubit cubit) {
  cubit.clearFailure();
  final events = context.read<AccountEvents?>();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: AppColors.ground,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _AddKeySheet(onCreated: () => events?.changed()),
    ),
  );
}

class _AddKeySheet extends StatefulWidget {
  const new({required this.onCreated});

  final VoidCallback onCreated;

  @override
  State<_AddKeySheet> createState() => _AddKeySheetState();
}

class _AddKeySheetState extends State<_AddKeySheet> {
  PixKeyKind _kind = PixKeyKind.email;
  final _value = TextEditingController();
  String? _formatError;

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    String? value;
    if (_kind != PixKeyKind.evp) {
      final detected = detectPixKey(_value.text);
      if (detected == null || detected.type != _kind) {
        setState(
          () => _formatError = _kind == PixKeyKind.email
              ? 'Digite um e-mail válido, como nome@exemplo.com.'
              : 'Digite o celular com DDD, como (21) 99999-0000.',
        );
        return;
      }
      value = detected.value;
    }
    final ok = await context.read<KeysCubit>().create(_kind, value);
    if (ok && mounted) {
      widget.onCreated();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<KeysCubit>().state;
    final apiError = state.failure == null ? null : messageFor(state.failure!);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Cadastrar chave Pix', style: AppText.title),
              const SizedBox(height: AppSpacing.l),
              Wrap(
                spacing: AppSpacing.s,
                children: [
                  for (final (kind, label) in const [
                    (PixKeyKind.email, 'E-mail'),
                    (PixKeyKind.phone, 'Celular'),
                    (PixKeyKind.evp, 'Aleatória'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _kind == kind,
                      onSelected: (_) => setState(() {
                        _kind = kind;
                        _formatError = null;
                        _value.clear();
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              if (_kind == PixKeyKind.evp)
                const Text(
                  'O app gera um código aleatório. Serve para receber Pix sem '
                  'mostrar seu e-mail ou celular.',
                  style: AppText.caption,
                )
              else
                TextField(
                  controller: _value,
                  autofocus: true,
                  autocorrect: false,
                  keyboardType: _kind == PixKeyKind.email
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  onChanged: (_) => setState(() => _formatError = null),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: _kind == PixKeyKind.email ? 'E-mail' : 'Celular',
                    hintText: _kind == PixKeyKind.email
                        ? 'nome@exemplo.com'
                        : '(21) 99999-0000',
                    errorText: _formatError,
                    errorMaxLines: 2,
                  ),
                ),
              if (apiError != null) ...[
                const SizedBox(height: AppSpacing.m),
                Text(
                  apiError,
                  style: AppText.caption.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Cadastrar chave',
                loading: state.busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
