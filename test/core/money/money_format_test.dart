import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/money/money_format.dart';

void main() {
  test('formata centavos em reais, padrão brasileiro', () {
    expect(formatCents(0), r'R$ 0,00');
    expect(formatCents(5), r'R$ 0,05');
    expect(formatCents(100), r'R$ 1,00');
    expect(formatCents(247410), r'R$ 2.474,10');
    expect(formatCents(1000000000), r'R$ 10.000.000,00');
  });

  test('com sinal: + para entrada e − (menos tipográfico) para saída', () {
    expect(formatCents(12000, signed: true), r'+ R$ 120,00');
    expect(formatCents(-2590, signed: true), r'− R$ 25,90');
  });

  test('separa reais e centavos para exibir os centavos menores', () {
    expect(splitCents(247410), (reais: '2.474', cents: ',10'));
    expect(splitCents(7), (reais: '0', cents: ',07'));
  });
}
