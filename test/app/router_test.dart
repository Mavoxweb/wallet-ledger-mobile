import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/app/router.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/data/auth_repository.dart';

const _authenticated = SessionAuthenticated(
  Me(userId: 'u1', name: 'Ana', role: 'Customer', accountId: 'a1'),
);

void main() {
  test('verificando a sessão: fica na entrada', () {
    expect(sessionRedirect(const SessionUnknown(), '/'), '/splash');
    expect(sessionRedirect(const SessionUnknown(), '/splash'), isNull);
  });

  test('sem sessão: só login e cadastro', () {
    expect(sessionRedirect(const SessionUnauthenticated(), '/'), '/login');
    expect(
      sessionRedirect(const SessionUnauthenticated(), '/splash'),
      '/login',
    );
    expect(
      sessionRedirect(const SessionUnauthenticated(), '/register'),
      isNull,
    );
  });

  test('com sessão: sai do login e da entrada para o início', () {
    expect(sessionRedirect(_authenticated, '/login'), '/');
    expect(sessionRedirect(_authenticated, '/splash'), '/');
    expect(sessionRedirect(_authenticated, '/'), isNull);
  });
}
