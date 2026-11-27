import 'package:wallet_ledger_mobile/features/account/domain/account.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account_repository.dart';

class GetAccount {
  const new(this._repository);

  final AccountRepository _repository;

  Future<AccountSummary> call() => _repository.account();
}
