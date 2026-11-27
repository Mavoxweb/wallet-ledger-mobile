import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';

/// Cadastra e já entra na conta nova.
class Register {
  const new(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String name,
    required String cpf,
    required String email,
    required String password,
  }) => _repository.register(
    name: name,
    cpf: cpf,
    email: email,
    password: password,
  );
}
