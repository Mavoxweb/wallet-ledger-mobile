import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/launch_gate.dart';
import 'package:wallet_ledger_mobile/app/router.dart';
import 'package:wallet_ledger_mobile/app/scroll_behavior.dart';
import 'package:wallet_ledger_mobile/app/use_case_scope.dart';
import 'package:wallet_ledger_mobile/core/events/account_events.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/storage/prefs_store.dart';
import 'package:wallet_ledger_mobile/core/theme/app_theme.dart';
import 'package:wallet_ledger_mobile/core/widgets/device_frame.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/charge_repository.dart';
import 'package:wallet_ledger_mobile/features/deposit/domain/deposit_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_repository.dart';

/// Recebe as dependências prontas: do bootstrap em produção, dublês nos testes.
class WalletLedgerApp extends StatefulWidget {
  const new({
    required this.authRepository,
    required this.sessionBloc,
    required this.biometricGate,
    required this.accountRepository,
    required this.keysRepository,
    required this.pixRepository,
    required this.chargeRepository,
    required this.depositRepository,
    required this.prefsStore,
    super.key,
  });

  final AuthRepository authRepository;
  final SessionBloc sessionBloc;
  final BiometricGate biometricGate;
  final AccountRepository accountRepository;
  final KeysRepository keysRepository;
  final PixRepository pixRepository;
  final ChargeRepository chargeRepository;
  final DepositRepository depositRepository;
  final PrefsStore prefsStore;

  @override
  State<WalletLedgerApp> createState() => _WalletLedgerAppState();
}

class _WalletLedgerAppState extends State<WalletLedgerApp> {
  // O roteador é criado uma vez só: recriá-lo a cada build perderia a pilha.
  final _launch = LaunchGate();
  late final GoRouter _router = createRouter(widget.sessionBloc, _launch);
  final _accountEvents = AccountEvents();

  @override
  void dispose() {
    unawaited(_accountEvents.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BiometricGate>.value(value: widget.biometricGate),
        RepositoryProvider<AccountEvents>.value(value: _accountEvents),
        RepositoryProvider<PrefsStore>.value(value: widget.prefsStore),
        RepositoryProvider<LaunchOpener>.value(
          value: LaunchOpener(_launch.open),
        ),
      ],
      child: UseCaseScope(
        auth: widget.authRepository,
        account: widget.accountRepository,
        keys: widget.keysRepository,
        pix: widget.pixRepository,
        charge: widget.chargeRepository,
        deposit: widget.depositRepository,
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
            scrollBehavior: const AppScrollBehavior(),
            builder: (context, child) => DeviceFrame(child: child!),
          ),
        ),
      ),
    );
  }
}
