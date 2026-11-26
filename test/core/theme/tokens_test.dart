import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';

/// Contraste WCAG 2.x entre duas cores opacas.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);

  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('Contraste da paleta (WCAG AA = 4,5:1)', () {
    test('tinta sobre o fundo', () {
      expect(
        contrast(AppColors.ink, AppColors.ground),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('branco sobre o destaque (botões)', () {
      expect(
        contrast(AppColors.surface, AppColors.accent),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('texto secundário sobre a superfície', () {
      expect(
        contrast(AppColors.inkMuted, AppColors.surface),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('menta sobre a tinta (detalhes do cartão escuro)', () {
      expect(
        contrast(AppColors.mint, AppColors.ink),
        greaterThanOrEqualTo(4.5),
      );
    });
  });

  test('valores da paleta aprovada', () {
    expect(AppColors.ground, const Color(0xFFF4F5F1));
    expect(AppColors.ink, const Color(0xFF0F1413));
    expect(AppColors.accent, const Color(0xFF0B6B5D));
  });
}
