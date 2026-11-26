import 'package:equatable/equatable.dart';

/// Valor digitado no teclado do Pix, sempre em centavos (nunca `double`).
///
/// Funciona como a maquininha de cartão: cada dígito entra pela direita e
/// empurra os outros. 1 → 0,01; 12 → 0,12; 1234 → 12,34.
class AmountInput extends Equatable {
  const new({this.cents = 0});

  /// Teto da API por operação: R$ 100.000.000,00.
  static const maxCents = 10000000000;

  /// O teclado para de aceitar dígitos aqui, um dígito acima do teto: dá para
  /// passar do limite (e ver o aviso), mas não estourar o número.
  static const _maxTypedCents = 999999999999;

  final int cents;

  bool get isValid => cents > 0 && cents <= maxCents;
  bool get isOverLimit => cents > maxCents;

  AmountInput digit(int d) {
    assert(d >= 0 && d <= 9, 'um dígito por vez');
    final next = cents * 10 + d;
    return next > _maxTypedCents ? this : AmountInput(cents: next);
  }

  AmountInput backspace() => AmountInput(cents: cents ~/ 10);

  /// Entende um valor colado: "1.234,56", "R$ 10,5", "1234.56" ou só dígitos
  /// (que viram centavos, como no teclado). Devolve nulo se não entender.
  static AmountInput? parsePasted(String raw) {
    final s = raw.replaceAll(RegExp(r'R\$|\s'), '');
    if (s.isEmpty || !RegExp(r'^[\d.,]+$').hasMatch(s)) return null;

    final String whole;
    var fraction = '';
    if (s.contains(',')) {
      // Brasileiro: vírgula decimal, pontos de milhar.
      final parts = s.split(',');
      if (parts.length != 2) return null;
      whole = parts[0].replaceAll('.', '');
      fraction = parts[1];
    } else if (RegExp(r'\.\d{1,2}$').hasMatch(s) &&
        '.'.allMatches(s).length == 1) {
      // Um só ponto, com 1 ou 2 casas no fim: ponto decimal.
      final parts = s.split('.');
      whole = parts[0];
      fraction = parts[1];
    } else if (s.contains('.')) {
      // Só pontos de milhar, sem centavos.
      whole = s.replaceAll('.', '');
      fraction = '00';
    } else {
      // Só dígitos: centavos, como no teclado.
      final cents = int.tryParse(s);
      return cents == null ? null : AmountInput(cents: cents);
    }

    if (fraction.length > 2 || !RegExp(r'^\d*$').hasMatch(whole)) return null;
    final reais = int.tryParse(whole.isEmpty ? '0' : whole);
    final centavos = int.tryParse(fraction.padRight(2, '0'));
    if (reais == null || centavos == null) return null;
    return AmountInput(cents: reais * 100 + centavos);
  }

  @override
  List<Object?> get props => [cents];
}
