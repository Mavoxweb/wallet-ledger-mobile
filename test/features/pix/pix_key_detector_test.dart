import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_ledger_mobile/features/keys/domain/pix_key.dart';
import 'package:wallet_ledger_mobile/features/pix/domain/pix_key_detector.dart';

void main() {
  test('e-mail, mesmo com espaços em volta', () {
    final key = detectPixKey('  bruno@walletledger.dev ');
    expect(key?.type, PixKeyKind.email);
    expect(key?.value, 'bruno@walletledger.dev');
  });

  test('celular com máscara', () {
    final key = detectPixKey('(21) 99999-0000');
    expect(key?.type, PixKeyKind.phone);
    // Detecta, mas não normaliza: quem normaliza é a API.
    expect(key?.value, '(21) 99999-0000');
  });

  test('celular com +55', () {
    expect(detectPixKey('+55 21 99999-0000')?.type, PixKeyKind.phone);
  });

  test('celular de outro país não é aceito', () {
    expect(detectPixKey('+1 415 555 0100'), isNull);
  });

  test('chave aleatória (UUID), em maiúsculas ou minúsculas', () {
    const evp = '0B7A3C1E-1D2F-4A5B-8C9D-0E1F2A3B4C5D';
    expect(detectPixKey(evp)?.type, PixKeyKind.evp);
    expect(detectPixKey(evp.toLowerCase())?.type, PixKeyKind.evp);
  });

  test('lixo vira nulo', () {
    expect(detectPixKey(''), isNull);
    expect(detectPixKey('bruno'), isNull);
    expect(detectPixKey('bruno@'), isNull);
    expect(detectPixKey('12345'), isNull);
  });
}
