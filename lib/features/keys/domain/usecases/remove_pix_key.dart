import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';

class RemovePixKey {
  const new(this._repository);

  final KeysRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
