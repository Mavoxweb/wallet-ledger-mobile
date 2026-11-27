import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/features/account/domain/account_repository.dart';
import 'package:wallet_ledger_mobile/features/account/domain/usecases/get_account.dart';
import 'package:wallet_ledger_mobile/features/account/domain/usecases/get_statement.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/login.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/register.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/charge_repository.dart';
import 'package:wallet_ledger_mobile/features/charge/domain/usecases/create_charge.dart';
import 'package:wallet_ledger_mobile/features/deposit/domain/deposit_repository.dart';
import 'package:wallet_ledger_mobile/features/deposit/domain/usecases/make_simulated_deposit.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/add_pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/list_pix_keys.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/remove_pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_repository.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/usecases/lookup_pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/usecases/send_pix.dart';

/// Monta os casos de uso sobre os repositórios e os entrega à árvore. As telas
/// só leem casos de uso. Nos testes, basta passar os repositórios falsos que a
/// tela usa.
class UseCaseScope extends StatelessWidget {
  const new({
    required this.child,
    this.auth,
    this.account,
    this.keys,
    this.pix,
    this.charge,
    this.deposit,
    super.key,
  });

  final Widget child;
  final AuthRepository? auth;
  final AccountRepository? account;
  final KeysRepository? keys;
  final PixRepository? pix;
  final ChargeRepository? charge;
  final DepositRepository? deposit;

  @override
  Widget build(BuildContext context) {
    final auth = this.auth;
    final account = this.account;
    final keys = this.keys;
    final pix = this.pix;
    final charge = this.charge;
    final deposit = this.deposit;
    return MultiRepositoryProvider(
      providers: [
        if (auth != null) ...[
          RepositoryProvider(create: (_) => Login(auth)),
          RepositoryProvider(create: (_) => Register(auth)),
        ],
        if (account != null) ...[
          RepositoryProvider(create: (_) => GetAccount(account)),
          RepositoryProvider(create: (_) => GetStatement(account)),
        ],
        if (keys != null) ...[
          RepositoryProvider(create: (_) => ListPixKeys(keys)),
          RepositoryProvider(create: (_) => AddPixKey(keys)),
          RepositoryProvider(create: (_) => RemovePixKey(keys)),
        ],
        if (pix != null) ...[
          RepositoryProvider(create: (_) => LookupPixKey(pix)),
          RepositoryProvider(create: (_) => SendPix(pix)),
        ],
        if (charge != null)
          RepositoryProvider(create: (_) => CreateCharge(charge)),
        if (deposit != null)
          RepositoryProvider(create: (_) => MakeSimulatedDeposit(deposit)),
      ],
      child: child,
    );
  }
}
