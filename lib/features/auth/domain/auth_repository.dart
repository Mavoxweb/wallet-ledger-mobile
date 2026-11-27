import 'package:wallet_ledger_mobile/features/auth/domain/me.dart';

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
