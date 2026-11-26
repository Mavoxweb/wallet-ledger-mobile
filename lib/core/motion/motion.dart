import 'package:material_ui/material_ui.dart';

/// Tempos e curvas de movimento do app (especificação aprovada no protótipo).
abstract final class AppMotion {
  /// Troca de aba: curta, porque acontece muitas vezes por dia.
  static const tab = Duration(milliseconds: 220);

  /// Ocultar/mostrar saldo.
  static const hide = Duration(milliseconds: 180);

  /// Resposta ao toque: tem que parecer instantânea.
  static const press = Duration(milliseconds: 120);

  /// Folhas que sobem de baixo (fluxo Pix).
  static const sheet = Duration(milliseconds: 360);

  /// Animação de entrada completa.
  static const intro = Duration(milliseconds: 1100);

  /// A pessoa pediu menos movimento nas configurações de acessibilidade?
  /// Se sim, deslizes viram fades simples.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);
}

/// Curvas fortes: as do sistema são tímidas demais.
abstract final class AppCurves {
  /// Saída forte: começa rápido (resposta imediata) e assenta suave.
  static const easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Folhas e gavetas (curva no estilo iOS).
  static const sheet = Cubic(0.32, 0.72, 0, 1);

  /// Leve passada do ponto e volta, para o ponto do ícone na entrada.
  static const softBounce = Cubic(0.34, 1.56, 0.64, 1);
}
