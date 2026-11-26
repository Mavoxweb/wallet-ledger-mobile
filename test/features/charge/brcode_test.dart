import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/features/charge/brcode.dart';

// Exemplo de QR estático do Manual do BR Code (Banco Central do Brasil).
// É o MESMO vetor dos testes da API: os dois lados conferem contra a mesma
// referência oficial, não um contra o outro.
const _reference =
    '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d1-a456-426655440000'
    '5204000053039865802BR5913Fulano de Tal6008BRASILIA62070503***63041D3D';

/// Gerado pela API para ana@walletledger.dev com R$ 10,50.
const _withAmount =
    '00020126420014br.gov.bcb.pix0120ana@walletledger.dev520400005303986'
    '540510.505802BR5916Ana Beatriz Lima6009SAO PAULO62070503***6304';

void main() {
  test('lê o vetor oficial do Manual do BR Code', () {
    final code = parseBrCode(_reference);

    expect(code.pixKey, '123e4567-e12b-12d1-a456-426655440000');
    expect(code.amountCents, isNull);
  });

  test('CRC16 do vetor oficial é 1D3D', () {
    expect(crc16(_reference.substring(0, _reference.length - 4)), '1D3D');
  });

  test('campo 54 com 10.50 vira 1050 centavos', () {
    final payload = _withAmount + crc16(_withAmount);

    expect(parseBrCode(payload).amountCents, 1050);
    expect(parseBrCode(payload).pixKey, 'ana@walletledger.dev');
  });

  test('CRC adulterado é recusado', () {
    final tampered = '${_reference.substring(0, _reference.length - 4)}1D3E';

    expect(() => parseBrCode(tampered), throwsFormatException);
  });

  test('um caractere trocado no meio também é pego pelo CRC', () {
    final tampered = _reference.replaceFirst('Fulano', 'Fulana');

    expect(() => parseBrCode(tampered), throwsFormatException);
  });

  test('texto qualquer é recusado', () {
    expect(() => parseBrCode(''), throwsFormatException);
    expect(() => parseBrCode('https://exemplo.com'), throwsFormatException);
  });

  test('sem a conta Pix (campo 26) é recusado', () {
    const noAccount = '000201520400005303986';
    const body = '${noAccount}6304';

    expect(() => parseBrCode(body + crc16(body)), throwsFormatException);
  });

  test('espaços e quebras de linha nas pontas são ignorados', () {
    expect(parseBrCode('  $_reference\n').amountCents, isNull);
  });
}
