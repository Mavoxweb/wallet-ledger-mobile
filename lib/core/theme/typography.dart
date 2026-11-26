import 'package:flutter/painting.dart';
import 'package:wallet_ledger_mobile/core/theme/tokens.dart';

/// Famílias embutidas em assets/fonts (declaradas no pubspec.yaml).
abstract final class AppFonts {
  static const display = 'SpaceGrotesk';
  static const text = 'Inter';
}

/// Estilos de texto do app. A regra do protótipo: tracking (letter-spacing)
/// negativo em texto grande, neutro em texto pequeno.
abstract final class AppText {
  static const display = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.1,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink,
  );

  static const bodyStrong = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.inkMuted,
  );

  /// Valores em dinheiro: algarismos de largura fixa, para os centavos
  /// alinharem uns embaixo dos outros no extrato.
  static TextStyle money(double size, {Color color = AppColors.ink}) =>
      TextStyle(
        fontFamily: AppFonts.display,
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: size >= 28 ? -0.03 * size : -0.1,
        height: 1.05,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
