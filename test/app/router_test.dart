import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/app/router.dart';
import 'package:wallet_ledger_mobile/features/auth/domain/me.dart';
import 'package:wallet_ledger_mobile/features/auth/presentation/bloc/session_bloc.dart';

const _authenticated = SessionAuthenticated(
  Me(userId: 'u1', name: 'Ana', role: 'Customer', accountId: 'a1'),
);

void main() {
  test('antes de a entrada terminar, tudo fica na splash', () {
    expect(sessionRedirect(_authenticated, '/', launchReady: false), '/splash');
    expect(
      sessionRedirect(
        const SessionUnauthenticated(),
        '/login',
        launchReady: false,
      ),
      '/splash',
    );
    expect(
      sessionRedirect(_authenticated, '/splash', launchReady: false),
      isNull,
    );
  });

  test('sem sessão: só login e cadastro', () {
    expect(
      sessionRedirect(const SessionUnauthenticated(), '/', launchReady: true),
      '/login',
    );
    expect(
      sessionRedirect(
        const SessionUnauthenticated(),
        '/splash',
        launchReady: true,
      ),
      '/login',
    );
    expect(
      sessionRedirect(
        const SessionUnauthenticated(),
        '/register',
        launchReady: true,
      ),
      isNull,
    );
  });

  test('com sessão: sai do login e da entrada para o início', () {
    expect(sessionRedirect(_authenticated, '/login', launchReady: true), '/');
    expect(sessionRedirect(_authenticated, '/splash', launchReady: true), '/');
    expect(
      sessionRedirect(_authenticated, '/extrato', launchReady: true),
      isNull,
    );
  });
}
