import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/launch_gate.dart';
import 'package:wallet_ledger_mobile/app/router.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/core/widgets/device_frame.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

/// Raiz do app. Recebe as dependências prontas (do bootstrap em produção, de
/// dublês nos testes) e as entrega à árvore de widgets.
class WalletLedgerApp extends StatefulWidget {
  const new({
    required this.authRepository,
    required this.sessionBloc,
    required this.biometricGate,
    super.key,
  });

  final AuthRepository authRepository;
  final SessionBloc sessionBloc;
  final BiometricGate biometricGate;

  @override
  State<WalletLedgerApp> createState() => _WalletLedgerAppState();
}

class _WalletLedgerAppState extends State<WalletLedgerApp> {
  // O roteador é criado uma vez só: recriá-lo a cada build perderia a pilha.
  final _launch = LaunchGate();
  late final GoRouter _router = createRouter(widget.sessionBloc, _launch);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: widget.authRepository),
        RepositoryProvider<BiometricGate>.value(value: widget.biometricGate),
        RepositoryProvider<LaunchOpener>.value(
          value: LaunchOpener(_launch.open),
        ),
      ],
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
          builder: (context, child) => DeviceFrame(child: child!),
        ),
      ),
    );
  }
}
