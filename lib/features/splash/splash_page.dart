import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/app/launch_gate.dart';
import 'package:wallet_ledger_mobile/core/security/biometric_gate.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/features/auth/bloc/session_bloc.dart';
import 'package:wallet_ledger_mobile/features/splash/intro_animation.dart';

/// Entrada do app: roda a animação enquanto a sessão é verificada e só libera
/// quando **as duas coisas** terminaram. Com sessão salva e biometria
/// disponível, pede a digital/rosto antes de entrar.
class SplashPage extends StatefulWidget {
  const new({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _introDone = false;
  bool _unlocking = false;
  bool _unlockFailed = false;

  void _onIntroFinished() {
    setState(() => _introDone = true);
    unawaited(_tryFinish(context.read<SessionBloc>().state));
  }

  Future<void> _tryFinish(SessionState session) async {
    if (!_introDone || _unlocking || session is SessionUnknown) return;

    final gate = context.read<LaunchOpener>();
    if (session is SessionUnauthenticated) return gate.open();

    final biometrics = context.read<BiometricGate>();
    if (!await biometrics.isAvailable()) return gate.open();

    setState(() {
      _unlocking = true;
      _unlockFailed = false;
    });
    final ok = await biometrics.confirm('Desbloqueie para ver seu saldo');
    if (!mounted) return;
    setState(() => _unlocking = false);

    if (ok) {
      gate.open();
    } else {
      setState(() => _unlockFailed = true);
    }
  }

  void _usePassword() {
    // Sai da sessão salva. Quando a sessão vira "não autenticado", o
    // BlocListener abaixo libera a entrada e o roteador leva ao login.
    setState(() => _unlockFailed = false);
    context.read<SessionBloc>().add(const SessionLoggedOut());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listener: (context, state) => unawaited(_tryFinish(state)),
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(
          children: [
            // Brilho menta difuso atrás do ícone.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.7,
                    colors: [Color(0x297FD3BF), Color(0x007FD3BF)],
                  ),
                ),
              ),
            ),
            Center(child: IntroAnimation(onFinished: _onIntroFinished)),
            if (_unlockFailed)
              Positioned(
                left: 24,
                right: 24,
                bottom: 48 + MediaQuery.paddingOf(context).bottom,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () => unawaited(
                        _tryFinish(context.read<SessionBloc>().state),
                      ),
                      child: const Text('Tentar biometria de novo'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _usePassword,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ground,
                      ),
                      child: const Text('Entrar com senha'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
