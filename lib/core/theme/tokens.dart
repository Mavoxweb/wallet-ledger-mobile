import 'package:flutter/painting.dart';

/// Toda cor do app sai daqui: nenhuma tela usa `Color(0xFF…)` solto.
abstract final class AppColors {
  /// Fundo das telas.
  static const ground = Color(0xFFF4F5F1);

  /// Cartões e superfícies claras.
  static const surface = Color(0xFFFFFFFF);

  /// Texto principal e o cartão de saldo escuro.
  static const ink = Color(0xFF0F1413);

  /// Texto secundário.
  static const inkMuted = Color(0xFF5B6461);

  /// Destaque: botões, aba ativa, valores de entrada.
  static const accent = Color(0xFF0B6B5D);

  /// Fundo suave do destaque (ícones de entrada, cartão de chaves).
  static const accentSoft = Color(0xFFDDEEE9);

  /// Detalhes sobre fundo escuro (ícone, cartão de saldo).
  static const mint = Color(0xFF7FD3BF);

  /// Divisórias finas.
  static const line = Color(0xFFE3E6E1);

  /// Texto secundário sobre o cartão escuro.
  static const onInkMuted = Color(0xFFA9B2AE);
}

abstract final class AppRadii {
  static const card = 28.0;
  static const tile = 24.0;
  static const chip = 20.0;
  static const control = 16.0;
}

/// Espaçamentos em múltiplos de 4.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 12.0;
  static const l = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Sombras em camadas no lugar de bordas: uma curta e firme, outra longa.
abstract final class AppShadows {
  static const _ink = Color(0xFF0F1413);

  static final soft = [
    BoxShadow(
      color: _ink.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: _ink.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static final card = [
    BoxShadow(
      color: _ink.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: _ink.withValues(alpha: 0.07),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static final deep = [
    BoxShadow(
      color: _ink.withValues(alpha: 0.10),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: _ink.withValues(alpha: 0.26),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];
}
