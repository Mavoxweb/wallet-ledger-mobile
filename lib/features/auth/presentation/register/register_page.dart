import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/register.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/register/register_cubit.dart';

class RegisterPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(context.read<Register>()),
      child: BlocListener<RegisterCubit, RegisterState>(
        listenWhen: (_, current) => current.status == RegisterStatus.success,
        listener: (context, _) =>
            context.read<SessionBloc>().add(const SessionLoggedIn()),
        child: const _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ground,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<RegisterCubit, RegisterState>(
          builder: (context, state) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            children: [
              Text(
                'Criar conta',
                style: AppText.display.copyWith(fontSize: 30),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'Leva um minuto. Você já começa com uma conta '
                'pronta para fazer Pix.',
                style: AppText.body.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 28),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  errorText: state.fieldError('name'),
                ),
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                onChanged: cubit.nameChanged,
              ),
              const SizedBox(height: AppSpacing.l),
              TextField(
                decoration: InputDecoration(
                  labelText: 'CPF',
                  hintText: 'Só os números',
                  errorText: state.fieldError('cpf'),
                ),
                keyboardType: TextInputType.number,
                onChanged: cubit.cpfChanged,
              ),
              const SizedBox(height: AppSpacing.l),
              TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  errorText: state.fieldError('email'),
                ),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                onChanged: cubit.emailChanged,
              ),
              const SizedBox(height: AppSpacing.l),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Senha',
                  helperText: 'Pelo menos 8 caracteres, com letra e número.',
                  errorText: state.fieldError('password'),
                ),
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                onChanged: cubit.passwordChanged,
              ),
              if (state.failure != null && state.failure is! ValidationFailure)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.l),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      messageFor(state.failure!),
                      style: AppText.caption.copyWith(
                        color: const Color(0xFFB3261E),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: state.canSubmit ? cubit.submit : null,
                child: state.status == RegisterStatus.submitting
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColors.surface,
                        ),
                      )
                    : const Text('Criar conta'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
