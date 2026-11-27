import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/errors/error_messages.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/brand_mark.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/login/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(context.read<AuthRepository>()),
      child: BlocListener<LoginCubit, LoginState>(
        listenWhen: (previous, current) =>
            current.status == LoginStatus.success,
        listener: (context, _) =>
            context.read<SessionBloc>().add(const SessionLoggedIn()),
        child: const _LoginView(),
      ),
    );
  }
}

class _LoginView extends StatefulWidget {
  const new();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 56),
                    const Row(
                      children: [
                        BrandMark(),
                        SizedBox(width: 10),
                        Text('Wallet Ledger', style: AppText.title),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Seu dinheiro,\ncada centavo no lugar.',
                      style: AppText.display.copyWith(fontSize: 30),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Entre para ver seu saldo e fazer Pix.',
                      style: AppText.body.copyWith(color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 36),
                    TextField(
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      onChanged: cubit.emailChanged,
                    ),
                    const SizedBox(height: AppSpacing.l),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      obscureText: _obscure,
                      autofillHints: const [AutofillHints.password],
                      onChanged: cubit.passwordChanged,
                      onSubmitted: (_) => cubit.submit(),
                    ),
                    BlocBuilder<LoginCubit, LoginState>(
                      buildWhen: (a, b) => a.failure != b.failure,
                      builder: (context, state) => state.failure == null
                          ? const SizedBox(height: AppSpacing.xl)
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.m,
                              ),
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
                    ),
                    BlocBuilder<LoginCubit, LoginState>(
                      builder: (context, state) => FilledButton(
                        onPressed: state.canSubmit ? cubit.submit : null,
                        child: state.status == LoginStatus.submitting
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: AppColors.surface,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ainda não tem conta?',
                          style: AppText.caption.copyWith(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Criar conta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),
                    const _DemoNotice(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EBE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Projeto de demonstração. Nenhum dinheiro real é movimentado.',
        textAlign: TextAlign.center,
        style: AppText.caption.copyWith(
          fontSize: 12,
          color: const Color(0xFF3F4744),
        ),
      ),
    );
  }
}
