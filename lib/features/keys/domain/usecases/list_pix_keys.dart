import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';

class ListPixKeys {
  const new(this._repository);

  final KeysRepository _repository;

  Future<List<PixKeyItem>> call() => _repository.list();
}
