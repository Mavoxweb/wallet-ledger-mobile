import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';

/// Início provisório: a tela de verdade (cartões, extrato) chega no PR 5.
class HomePlaceholder extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final name = session is SessionAuthenticated ? session.me.firstName : '';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Olá, $name', style: AppText.display),
              const Spacer(),
              OutlinedButton(
                onPressed: () =>
                    context.read<SessionBloc>().add(const SessionLoggedOut()),
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
