import 'package:wallet_ledger_mobile/features/account/domain/account.dart';

abstract interface class AccountRepository {
  Future<AccountSummary> account();
  Future<MovementPage> statement({int limit = 20, String? cursor});
}
