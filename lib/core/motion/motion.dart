import 'package:material_ui/material_ui.dart';

abstract final class AppMotion {
  /// Troca de aba: curta, porque acontece muitas vezes por dia.
  static const tab = Duration(milliseconds: 220);

  static const hide = Duration(milliseconds: 180);

  static const press = Duration(milliseconds: 120);

  static const sheet = Duration(milliseconds: 360);

  static const intro = Duration(milliseconds: 1100);

  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

/// Curvas fortes: as do sistema são tímidas demais.
abstract final class AppCurves {
  static const easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Folhas e gavetas (curva no estilo iOS).
  static const sheet = Cubic(0.32, 0.72, 0, 1);

  /// Leve passada do ponto e volta, para o ponto do ícone na entrada.
  static const softBounce = Cubic(0.34, 1.56, 0.64, 1);
}
