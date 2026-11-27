import 'package:wallet_ledger_mobile/features/auth/domain/auth_repository.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/check_session.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/clear_session.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/get_me.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/usecases/logout.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/keys_repository.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/add_pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/list_pix_keys.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/usecases/remove_pix_key.dart';
import 'package:wallet_ledger_mobile/features/keys/presentation/cubit/keys_cubit.dart';

/// Blocs montados com os casos de uso reais sobre um repositório falso.
SessionBloc sessionBlocFor(AuthRepository repository) => SessionBloc(
  checkSession: CheckSession(repository),
  getMe: GetMe(repository),
  logout: Logout(repository),
  clearSession: ClearSession(repository),
);

KeysCubit keysCubitFor(KeysRepository repository) => KeysCubit(
  list: ListPixKeys(repository),
  add: AddPixKey(repository),
  remove: RemovePixKey(repository),
);
