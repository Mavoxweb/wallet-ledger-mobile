import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/widgets/placeholder_page.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';

class ProfilePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => PlaceholderPage(
    title: 'Perfil',
    message: 'Seus dados e preferências.',
    action: OutlinedButton(
      onPressed: () =>
          context.read<SessionBloc>().add(const SessionLoggedOut()),
      child: const Text('Sair'),
    ),
  );
}
