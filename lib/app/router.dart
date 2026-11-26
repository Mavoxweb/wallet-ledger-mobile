import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/launch_gate.dart';
import 'package:wallet_ledger_mobile/app/shell.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/auth/login/login_page.dart';
import 'package:wallet_ledger_mobile/features/auth/register/register_page.dart';
import 'package:wallet_ledger_mobile/features/charge/charge_page.dart';
import 'package:wallet_ledger_mobile/features/charge/scan_page.dart';
import 'package:wallet_ledger_mobile/features/home/view/home_page.dart';
import 'package:wallet_ledger_mobile/features/pix/pix_page.dart';
import 'package:wallet_ledger_mobile/features/profile/profile_page.dart';
import 'package:wallet_ledger_mobile/features/splash/splash_page.dart';
import 'package:wallet_ledger_mobile/features/statement/statement_page.dart';

const _publicRoutes = {'/login', '/register'};

/// Para onde mandar a pessoa. Função pura: fácil de testar sem montar o app.
///
/// Enquanto a entrada não terminou (`launchReady` falso), tudo fica na
/// `/splash`. Depois, quem decide é a sessão.
String? sessionRedirect(
  SessionState session,
  String location, {
  required bool launchReady,
}) {
  if (!launchReady || session is SessionUnknown) {
    return location == '/splash' ? null : '/splash';
  }
  return switch (session) {
    SessionUnauthenticated() =>
      _publicRoutes.contains(location) ? null : '/login',
    _ =>
      (location == '/splash' || _publicRoutes.contains(location)) ? '/' : null,
  };
}

GoRouter createRouter(SessionBloc session, LaunchGate launch) => GoRouter(
  initialLocation: '/splash',
  // Reavalia o redirect quando a sessão muda ou a entrada termina.
  refreshListenable: Listenable.merge([
    _StreamListenable(session.stream),
    launch,
  ]),
  redirect: (context, state) => sessionRedirect(
    session.state,
    state.matchedLocation,
    launchReady: launch.ready,
  ),
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
    GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
    // Pix: folha que sobe de baixo e volta pelo mesmo caminho.
    GoRoute(
      path: '/pix',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: PixPage(prefill: state.extra as PixPrefill?),
        transitionDuration: AppMotion.sheet,
        reverseTransitionDuration: AppMotion.tab,
        transitionsBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppCurves.sheet,
          );
          if (AppMotion.reduced(context)) {
            return FadeTransition(opacity: curved, child: child);
          }
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    ),
    // Leitor de QR code: tela cheia, fora das abas.
    GoRoute(
      path: '/scan',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const ScanPage(),
        transitionDuration: AppMotion.tab,
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),
    StatefulShellRoute(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      navigatorContainerBuilder: (_, shell, children) =>
          AnimatedBranchContainer(
            currentIndex: shell.currentIndex,
            children: children,
          ),
      branches: [
        _branch('/', const HomePage()),
        _branch('/extrato', const StatementPage()),
        _branch('/cobrar', const ChargePage()),
        _branch('/perfil', const ProfilePage()),
      ],
    ),
  ],
);

StatefulShellBranch _branch(String path, Widget page) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => page)],
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
