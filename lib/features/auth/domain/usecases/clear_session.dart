import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';

/// Apaga a sessão local sem chamar a API (token já recusado).
class ClearSession {
  const new(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.clearSession();
}
