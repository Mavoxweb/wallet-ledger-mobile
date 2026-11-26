import 'package:equatable/equatable.dart';
import 'package:wallet_ledger_api/wallet_ledger_api.dart';
import 'package:wallet_ledger_mobile/core/errors/failure.dart';
import 'package:wallet_ledger_mobile/core/storage/token_store.dart';

/// Quem está logado. `Equatable` faz dois objetos com os mesmos dados serem
/// iguais (`==`), o que o Bloc usa para não redesenhar à toa.
class Me extends Equatable {
  const new({
    required this.userId,
    required this.name,
    required this.role,
    required this.accountId,
  });

  final String userId;
  final String name;
  final String role;
  final String? accountId;

  String get firstName => name.split(' ').first;

  @override
  List<Object?> get props => [userId, name, role, accountId];
}

abstract interface class AuthRepository {
  Future<bool> hasSession();
  Future<Me> me();
  Future<void> login({required String email, required String password});
  Future<void> register({
    required String name,
    required String cpf,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<void> clearSession();
}

/// Implementação que fala com a API. Erros saem como [Failure].
class ApiAuthRepository implements AuthRepository {
  new({required this._api, required this._store, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final WalletLedgerApi _api;
  final TokenStore _store;
  final DateTime Function() _now;

  /// Converte a resposta de login/refresh em [Tokens].
  static Tokens toTokens(TokenResponse r, DateTime now) => Tokens(
    accessToken: r.accessToken,
    refreshToken: r.refreshToken,
    expiresAt: now.add(Duration(seconds: r.expiresIn)),
  );

  @override
  Future<bool> hasSession() async => await _store.read() != null;

  @override
  Future<Me> me() => guard(() async {
    final r = (await _api.getMeApi().apiV1MeGet()).data!;
    return Me(
      userId: r.userId,
      name: r.name,
      role: r.role,
      accountId: r.accountId,
    );
  });

  @override
  Future<void> login({required String email, required String password}) =>
      guard(() async {
        final response = await _api.getAuthApi().apiV1AuthLoginPost(
          loginRequest: LoginRequest(email: email.trim(), password: password),
        );
        await _store.write(toTokens(response.data!, _now()));
      });

  @override
  Future<void> register({
    required String name,
    required String cpf,
    required String email,
    required String password,
  }) async {
    await guard(
      () => _api.getAuthApi().apiV1AuthRegisterPost(
        registerRequest: RegisterRequest(
          name: name.trim(),
          cpf: cpf,
          email: email.trim(),
          password: password,
        ),
      ),
    );
    await login(email: email, password: password);
  }

  @override
  Future<void> logout() async {
    final tokens = await _store.read();
    await _store.clear();
    if (tokens == null) return;
    try {
      await _api.getAuthApi().apiV1AuthLogoutPost(
        refreshRequest: RefreshRequest(refreshToken: tokens.refreshToken),
      );
    } on Object {
      // Sair funciona mesmo offline: a sessão local já foi apagada.
    }
  }

  @override
  Future<void> clearSession() => _store.clear();
}
