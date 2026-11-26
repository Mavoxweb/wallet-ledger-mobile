import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/router.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

/// Raiz do app. Recebe as dependências prontas (do bootstrap em produção, de
/// dublês nos testes) e as entrega à árvore de widgets.
class WalletLedgerApp extends StatefulWidget {
  const new({
    required this.authRepository,
    required this.sessionBloc,
    super.key,
  });

  final AuthRepository authRepository;
  final SessionBloc sessionBloc;

  @override
  State<WalletLedgerApp> createState() => _WalletLedgerAppState();
}

class _WalletLedgerAppState extends State<WalletLedgerApp> {
  // O roteador é criado uma vez só: recriá-lo a cada build perderia a pilha.
  late final GoRouter _router = createRouter(widget.sessionBloc);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: widget.authRepository,
      child: BlocProvider.value(
        value: widget.sessionBloc,
        child: MaterialApp.router(
          title: 'Wallet Ledger',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
