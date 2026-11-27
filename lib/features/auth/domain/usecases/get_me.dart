import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/me.dart';

class GetMe {
  const new(this._repository);

  final AuthRepository _repository;

  Future<Me> call() => _repository.me();
}
