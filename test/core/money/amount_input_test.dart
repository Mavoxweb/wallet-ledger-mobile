import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/core/money/amount_input.dart';

AmountInput _type(String digits) =>
    digits.split('').fold(const AmountInput(), (a, d) => a.digit(int.parse(d)));

void main() {
  group('AmountInput', () {
    test('os dígitos entram pela direita, como numa maquininha', () {
      expect(_type('1').cents, 1);
      expect(_type('12').cents, 12);
      expect(_type('1234').cents, 1234);
    });

    test('zero à esquerda não conta', () {
      expect(_type('0').cents, 0);
      expect(_type('005').cents, 5);
    });

    test('apagar tira o último dígito', () {
      expect(_type('1234').backspace().cents, 123);
      expect(const AmountInput().backspace().cents, 0);
    });

    test('zero não é válido', () {
      expect(const AmountInput().isValid, isFalse);
      expect(_type('1').isValid, isTrue);
    });

    test(r'acima de R$ 100 milhões não é válido', () {
      expect(const AmountInput(cents: 10000000000).isValid, isTrue);
      expect(const AmountInput(cents: 10000000001).isValid, isFalse);
      expect(const AmountInput(cents: 10000000001).isOverLimit, isTrue);
    });

    test('para de aceitar dígitos antes de estourar', () {
      final full = _type('999999999999');
      expect(full.digit(9).cents, full.cents);
    });

    group('parsePasted', () {
      test('formato brasileiro', () {
        expect(AmountInput.parsePasted('1.234,56')?.cents, 123456);
        expect(AmountInput.parsePasted(r'R$ 1.234,56')?.cents, 123456);
        expect(AmountInput.parsePasted('10,5')?.cents, 1050);
      });

      test('ponto como decimal', () {
        expect(AmountInput.parsePasted('1234.56')?.cents, 123456);
      });

      test('pontos de milhar sem centavos', () {
        expect(AmountInput.parsePasted('1.234.567')?.cents, 123456700);
      });

      test('só dígitos são centavos, como no teclado', () {
        expect(AmountInput.parsePasted('00012')?.cents, 12);
      });

      test('lixo vira nulo', () {
        expect(AmountInput.parsePasted('abc'), isNull);
        expect(AmountInput.parsePasted(''), isNull);
        expect(AmountInput.parsePasted('1,2,3'), isNull);
        expect(AmountInput.parsePasted('-5'), isNull);
      });
    });
  });
}
