import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';

class CheckSession {
  const new(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasSession();
}
