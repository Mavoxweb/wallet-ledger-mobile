import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';

/// Encerra a sessão no aparelho e avisa a API; funciona mesmo offline.
class Logout {
  const new(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
