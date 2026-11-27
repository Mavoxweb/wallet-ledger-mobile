import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/motion/motion.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/money_text.dart';
import 'package:wallet_ledger_mobile/features/account/data/account_repository.dart';

/// É um `Hero`: no Extrato, ele "voa" até o topo.
class BalanceCard extends StatelessWidget {
  const new({
    required this.account,
    required this.hidden,
    required this.onToggle,
    super.key,
  });

  static const heroTag = 'balance-card';

  final AccountSummary account;
  final bool hidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.caption.copyWith(color: AppColors.onInkMuted);

    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: 196,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.deep,
          ),
          child: Stack(
            children: [
              // Brilho menta no canto, numa camada própria: com `gradient` na
              // mesma decoração, a `color` escura seria ignorada.
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.1,
                      colors: [Color(0x337FD3BF), Color(0x007FD3BF)],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: CustomPaint(painter: _LedgerLines()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 8, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Saldo disponível', style: muted)),
                        IconButton(
                          tooltip: hidden ? 'Mostrar saldo' : 'Ocultar saldo',
                          onPressed: onToggle,
                          color: AppColors.onInkMuted,
                          icon: Icon(
                            hidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    _Amount(cents: account.balanceCents, hidden: hidden),
                    Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Row(
                        children: [
                          Text(
                            account.maskedNumber,
                            style: muted.copyWith(
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: account.isActive
                                  ? AppColors.mint
                                  : const Color(0xFFE8A07A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            account.isActive
                                ? 'Conta ativa'
                                : 'Conta bloqueada',
                            style: muted.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O valor ou os pontinhos. A troca usa desfoque + fade: o desfoque "funde"
/// os dois estados, e a troca parece uma coisa só, não duas sobrepostas.
class _Amount extends StatelessWidget {
  const new({required this.cents, required this.hidden});

  final int cents;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: AnimatedSwitcher(
        duration: AppMotion.hide,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final blur = 8 * (1 - animation.value);
              return ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: child,
              );
            },
          ),
        ),
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        child: hidden ? const _HiddenAmount() : _ShownAmount(cents: cents),
      ),
    );
  }
}

class _ShownAmount extends StatelessWidget {
  const new({required this.cents});

  final int cents;

  @override
  Widget build(BuildContext context) => MoneyText(
    key: const ValueKey('shown'),
    cents: cents,
    color: AppColors.ground,
    mutedColor: const Color(0xFFC7CFCB),
  );
}

class _HiddenAmount extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    // O leitor de tela também não lê o valor: anuncia só "Saldo oculto".
    return Semantics(
      container: true,
      label: 'Saldo oculto',
      excludeSemantics: true,
      child: Row(
        children: [
          Text(
            r'R$ ',
            style: AppText.body.copyWith(
              fontSize: 17,
              color: AppColors.onInkMuted,
            ),
          ),
          for (var i = 0; i < 5; i++)
            Container(
              margin: const EdgeInsets.only(right: 7),
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Color(0xFF3A4441),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _LedgerLines extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ground.withValues(alpha: 0.09)
      ..strokeWidth = 1.2;
    final left = size.width * 0.42;
    for (var i = 0; i < 6; i++) {
      final y = 40.0 + i * 24;
      final right = i == 5 ? size.width * 0.80 : size.width;
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }
  }

  @override
  bool shouldRepaint(_LedgerLines oldDelegate) => false;
}
