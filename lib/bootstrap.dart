import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart';
import 'package:wallet_ledger_mobile/app/app.dart';
import 'package:wallet_ledger_mobile/core/config/env.dart';
import 'package:wallet_ledger_mobile/core/network/auth_interceptor.dart';
import 'package:wallet_ledger_mobile/core/network/dio_factory.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/storage/prefs_store.dart';
import 'package:wallet_ledger_mobile/core/storage/token_store.dart';
import 'package:wallet_ledger_mobile/features/account/data/api_account_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/data/api_auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/charge/data/api_charge_repository.dart';
import 'package:wallet_ledger_mobile/features/deposit/data/api_deposit_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/data/api_keys_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/data/api_pix_repository.dart';

void bootstrap() {
  final env = Env.fromDefines();
  final store = SecureTokenStore();

  // Dio "cru", sem o interceptor: usado para renovar o token e repetir a
  // requisição. Passar pelo interceptor de novo travaria a fila dele.
  final rawDio = createDio(env);
  final refreshApi = WalletLedgerApi(
    dio: rawDio,
    interceptors: const [],
  ).getAuthApi();

  late final SessionBloc session;

  final dio = createDio(env)
    ..interceptors.add(
      AuthInterceptor(
        store: store,
        retryClient: rawDio,
        refresh: (refreshToken) async {
          final response = await refreshApi.apiV1AuthRefreshPost(
            refreshRequest: RefreshRequest(refreshToken: refreshToken),
          );
          return ApiAuthRepository.toTokens(response.data!, DateTime.now());
        },
        onSessionExpired: () => session.add(const SessionExpired()),
      ),
    );

  // `interceptors: const []`: sem isso o cliente gerado adiciona os
  // interceptors de autenticação dele, que disputariam o header com o nosso.
  final api = WalletLedgerApi(dio: dio, interceptors: const []);
  final auth = ApiAuthRepository(api: api, store: store);
  session = SessionBloc(auth)..add(const SessionStarted());

  runApp(
    WalletLedgerApp(
      authRepository: auth,
      sessionBloc: session,
      biometricGate: BiometricGate(),
      accountRepository: ApiAccountRepository(api),
      keysRepository: ApiKeysRepository(api),
      pixRepository: ApiPixRepository(api),
      chargeRepository: ApiChargeRepository(api),
      depositRepository: ApiDepositRepository(api),
      prefsStore: SharedPrefsStore(),
    ),
  );
}
