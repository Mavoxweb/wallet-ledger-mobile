import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/login/login_page.dart';
import 'package:wallet_ledger_mobile/features/auth/register/register_page.dart';
import 'package:wallet_ledger_mobile/features/home/home_placeholder.dart';
import 'package:wallet_ledger_mobile/features/splash/splash_page.dart';

const _publicRoutes = {'/login', '/register'};

/// Para onde mandar a pessoa, dado o estado da sessão. Função pura: fácil de
/// testar sem montar o app.
String? sessionRedirect(SessionState session, String location) =>
    switch (session) {
      SessionUnknown() => location == '/splash' ? null : '/splash',
      SessionUnauthenticated() =>
        _publicRoutes.contains(location) ? null : '/login',
      SessionAuthenticated() =>
        (location == '/splash' || _publicRoutes.contains(location))
            ? '/'
            : null,
    };

GoRouter createRouter(SessionBloc session) => GoRouter(
  initialLocation: '/splash',
  // Toda mudança de sessão reavalia o redirect
  // (login, logout, sessão expirada).
  refreshListenable: _StreamListenable(session.stream),
  redirect: (context, state) =>
      sessionRedirect(session.state, state.matchedLocation),
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
    GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
    GoRoute(path: '/', builder: (_, _) => const HomePlaceholder()),
  ],
);

/// Adapta um Stream (o do Bloc) para o Listenable que o GoRouter entende.
class _StreamListenable extends ChangeNotifier {
  new(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
