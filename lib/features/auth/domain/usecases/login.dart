import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';

class Login {
  const new(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
