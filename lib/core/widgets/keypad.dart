import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';
import 'package:wallet_ledger_mobile/core/theme/typography.dart';
import 'package:wallet_ledger_mobile/core/widgets/pressable.dart';

/// Teclado numérico próprio do valor: 1–9, 0 e apagar.
///
/// Próprio porque o teclado do sistema traz vírgula, ponto e sinal, e cada um
/// vira um caso para tratar. Aqui só existem dígitos.
class Keypad extends StatelessWidget {
  const new({required this.onDigit, required this.onBackspace, super.key});

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    Widget digit(int d) => _Key(
      key: ValueKey('key-$d'),
      onTap: () => onDigit(d),
      child: Text('$d', style: AppText.money(26)),
    );

    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(children: [for (final d in row) Expanded(child: digit(d))]),
        Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(child: digit(0)),
            Expanded(
              child: _Key(
                key: const ValueKey('key-back'),
                label: 'Apagar',
                onTap: onBackspace,
                child: const Icon(
                  Icons.backspace_outlined,
                  size: 22,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const new({required this.onTap, required this.child, super.key, this.label});

  final VoidCallback onTap;
  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      pressedScale: 0.92,
      semanticLabel: label,
      onTap: () {
        // Um "clique" leve a cada tecla, como num teclado de verdade.
        unawaited(HapticFeedback.selectionClick());
        onTap();
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        // Área de toque inteira, não só o número.
        color: Colors.transparent,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.4,
          child: child,
        ),
      ),
    );
  }
}
