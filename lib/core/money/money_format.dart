import 'package:intl/intl.dart';

final _thousands = NumberFormat.decimalPattern('pt_BR');

/// Reais e centavos separados, só com contas inteiras.
({String reais, String cents}) splitCents(int cents) {
  final absolute = cents.abs();
  final reais = _thousands.format(absolute ~/ 100);
  final rest = (absolute % 100).toString().padLeft(2, '0');
  return (reais: reais, cents: ',$rest');
}

/// `247410` → `R$ 2.474,10`. Com [signed], entradas ganham `+` e saídas o
/// sinal de menos tipográfico (−), que tem a largura certa ao lado do `+`.
String formatCents(int cents, {bool signed = false}) {
  final (:reais, cents: centsPart) = splitCents(cents);
  final amount = 'R\$ $reais$centsPart';
  if (!signed) return amount;
  return cents < 0 ? '− $amount' : '+ $amount';
}
