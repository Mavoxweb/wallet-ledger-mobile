import 'package:wallet_ledger_mobile/features/account/domain/account.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account_repository.dart';

class GetStatement {
  const new(this._repository);

  final AccountRepository _repository;

  /// Sem [cursor], a primeira página (a mais recente).
  Future<MovementPage> call({int limit = 20, String? cursor}) =>
      _repository.statement(limit: limit, cursor: cursor);
}
